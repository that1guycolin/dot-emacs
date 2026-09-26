;;; 04-code-assist.el --- Code Smarter, Not Harder -*- lexical-binding: t -*-

;;; Packages included:
;; adaptive-wrap, apheleia, comment-dwim-2, consult-eglot,
;; consult-eglot-embark, consult-flycheck, docstr, dumb-jump, editorconfig,
;; eglot, eglot-tempel, flycheck, flycheck-color-mode-line, flycheck-eask,
;; flycheck-eglot, flycheck-guile, flycheck-package, flyover, flyspell,
;; flyspell-correct, flyspell-correct-avy-menu, hideshow, kirigami,
;; lsp-snippet, outline, outline-indent, rainbow-delimiters, shfmt,
;; smartparens, treesit-fold, visual-regexp, visual-regexp-steroids

;;; Commentary:
;; Call packages that support efficient & productive coding at a global scope.
;; The packages configured in this file set up IDE-like features within Emacs.

;;; Code:
;;; Text manipulation:
;; Smart wrapping
(use-package adaptive-wrap
  :defer t
  :hook ((prog-mode text-mode conf-mode) . adaptive-wrap-prefix-mode))

;; Easily switch between comment types
(use-package comment-dwim-2
  :defer t
  :bind ([remap comment-dwim] . comment-dwim-2))

;; docstring support
(use-package docstr
  :defer t
  :commands (docstr-mode))

;; Jump-to-def/find-refs
(use-package dumb-jump
  :demand t
  :bind ("M-j" . dumb-jump-find-references)
  :functions (dumb-jump-xref-activate)
  :custom
  (dumb-jump-prefer-searcher 'ag)
  (xref-show-definitions-function #'consult-xref)
  :config (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

;; Integrate with editorconfig
(use-package editorconfig
  :ensure nil
  :defer t
  :hook ((prog-mode text-mode conf-mode) . editorconfig-mode))

;; Colorize "", {}, [], ()
(use-package rainbow-delimiters
  :defer t
  :hook ((prog-mode text-mode conf-mode) . rainbow-delimiters-mode))

;; Auto-close "", {}, [], ()
(use-package smartparens
  :defer t
  :hook ((prog-mode text-mode conf-mode) . smartparens-mode)
  :config (require 'smartparens-config))

;; Hl regexp while typing
(use-package visual-regexp
  :defer t
  :bind (("C-c r" . vr/replace)
         ("C-c q" . vr/query-replace)))

;; Python-style regexp over Emacs
(use-package visual-regexp-steroids
  :defer t
  :bind (([remap isearch-forward-regexp]  . vr/isearch-forward)
         ([remap isearch-backward-regexp] . vr/isearch-backward)))


;;; Linting (flycheck)
(use-package flycheck
  :defer t
  :preface
  (defvar minions-prominent-modes)
  (defun that1guycolin/flycheck-vale-setup ()
    "If not setup, install the vale from the .ini file in user-lisp-directory."
    (let* ((vale-config (expand-file-name ".vale.ini" user-lisp-directory))
           (command (format "vale --config %s sync >/dev/null 2>&1"
                            vale-config)))
      (shell-command command)))
  :hook ((prog-mode conf-mode text-mode) . flycheck-mode)
  :functions (flycheck-error-new-at flycheck-select-checker flycheck-add-mode)
  :custom
  (flycheck-disabled-checkers
   '(emacs-lisp-elsa rpm-rpmlint yaml-jsyaml yaml-ruby))
  :config
  (add-to-list 'minions-prominent-modes 'flycheck-mode)

  (flycheck-define-checker text-vale
    "Tool to bring code-like linting to prose.
See URL `https://vale.sh'."
    :command
    ("vale" "--config"
     (eval (expand-file-name ".vale.ini" user-lisp-directory))
     "--no-global" "--output" "line" source)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ":"
              (id (one-or-more (not (any ":")))) ":" (message) line-end))
    :modes (text-mode))
  (let ((vale-install (expand-file-name ".vale-styles" user-lisp-directory)))
    (unless (file-exists-p vale-install)
      (that1guycolin/flycheck-vale-setup)))
  (add-to-list 'flycheck-checkers 'text-vale)
  (add-hook 'org-mode-hook
            (lambda () (flycheck-select-checker 'org-lint))))

;; Display flycheck errors in buffer
(use-package flycheck-posframe
  :after (flycheck)
  :defer t
  :hook (flycheck-mode . flycheck-posframe-mode)
  :functions (flycheck-posframe-configure-pretty-defaults)
  :config (flycheck-posframe-configure-pretty-defaults))

;; Buffer status
(use-package flycheck-color-mode-line
  :after (flycheck)
  :defer t
  :hook (flycheck-mode . flycheck-color-mode-line-mode))

(use-package flycheck-relint
  :after (flycheck elisp-mode)
  :demand t
  :functions (flycheck-relint-setup)
  :config (flycheck-relint-setup))

(use-package consult-flycheck
  :after (consult flycheck)
  :demand t)


;;; Formatting (apheleia):
(use-package apheleia
  :defer t
  :bind ("C-c f" . apheleia-format-buffer)
  :hook ((prog-mode text-mode conf-mode) . apheleia-mode))


;;; Language-Server-Protocol (eglot):
(use-package eglot
  :ensure nil
  :preface
  (defcustom that1guycolin/eglot-lisp-alive-port 8006
    "Port used to connect to the alive-lsp Common Lisp language server."
    :type 'integer
    :group 'eglot)

  (defun that1guycolin/eglot-lisp-alive--port-available-p (port)
    "Return nil if PORT is not free to bind on localhost."
    (condition-case nil
        (let ((probe (make-network-process
                      :name "eglot-lisp-alive-port-probe"
                      :server t
                      :host "localhost"
                      :service port
                      :noquery t)))
          (delete-process probe)
          t)
      (file-error nil)))
  
  :defer t
  :bind (:map ctl-x-map ("e" . eglot))
  :config
  (setq eglot-server-programs
        (cl-remove-if
         (lambda (cell)
           (cl-some
            (lambda (mode)
              (memq mode '(css-mode
                           css-ts-mode dockerfile-ts-mode js-json-mode
                           json-ts-mode lisp-mode lisp-ts-mode markdown-mode
                           markdown-ts-mode python-mode python-ts-mode
                           yaml-ts-mode)))
            (ensure-list (car cell))))
         eglot-server-programs))

  (let ((lsp-cons-cells
         '(((css-mode css-ts-mode) .
            ("vscode-css-language-server" "--stdio"))
           ((dockerfile-ts-mode) . ("docker-language-server" "start" "--stdio"))
           ((fish-mode) . ("fish-lsp" "start"))
           ((js-json-mode json-ts-mode) .
            ("vscode-json-language-server" "--stdio"))
           ((lisp-mode lisp-ts-mode) .
            (lambda (_interactive _project)
              (unless (that1guycolin/eglot-lisp-alive--port-available-p
                       that1guycolin/eglot-lisp-alive-port)
                (error "Port %d is already in use"
                       that1guycolin/eglot-lisp-alive-port))
              (make-process
               :name "alive-lsp"
               :buffer (get-buffer-create "*alive-lsp*")
               :noquery t
               :sentinel #'ignore
               :filter #'ignore
               :command (list "sbcl"
                              "--eval" "(require :asdf)"
                              "--eval" "(asdf:load-system :alive-lsp)"
                              "--eval"
                              (format "(alive/server::start :port %d)"
                                      that1guycolin/eglot-lisp-alive-port)))
              (sleep-for 1)
              (list "localhost" that1guycolin/eglot-lisp-alive-port)))
           ((markdown-mode markdown-ts-mode) . ("rumdl" "server"))
           ((nxml-mode) . ("lemminx"))
           ((pkgbuild-mode) . ("termux-language-server", "--check" ))
           ((python-mode python-ts-mode) . ("uv" "run" "rass" "python"))
           ((yaml-ts-mode) .
            (lambda (_interactive _project)
              (if (string-match-p
                   "/\\(?:compose\\|docker-compose\\)\\.yam?ml\\'"
                   (buffer-file-name))
                  '("docker-compose-langserver" "--stdio")
                '("yaml-language-server" "--stdio")))))))
    (dolist (con lsp-cons-cells)
      (add-to-list 'eglot-server-programs con))))

(use-package consult-eglot
  :after (consult eglot)
  :demand t
  :commands (consult-eglot-symbols))

(use-package consult-eglot-embark
  :after (consult-eglot embark)
  :demand t
  :functions (consult-eglot-embark-mode)
  :config (consult-eglot-embark-mode 1))

(use-package flycheck-eglot
  :after (flycheck eglot)
  :demand t
  :functions (global-flycheck-eglot-mode)
  :config (global-flycheck-eglot-mode 1))

(use-package lsp-snippet
  :ensure (:id lsp-snippet :type git :host github
               :depth treeless :protocol https :autoloads t
               :repo "svaante/lsp-snippet" :main "lsp-snippet.el" :build t
               :files ("Makefile" "*.el") :autoloads t)
  :after (eglot tempel)
  :demand t
  :config
  (require 'lsp-snippet-tempel)
  (lsp-snippet-tempel-eglot-init))

(use-package eglot-tempel
  :after (eglot tempel)
  :demand t
  :functions (eglot-tempel-mode)
  :config (eglot-tempel-mode 1))


;;; Code Folding:
;; Based on buffer-syntax
(use-package hideshow
  :ensure nil
  :defer t
  :hook ((c-mode
          c++-mode css-mode html-mode java-mode js-mode js-json-mode lua-mode
          nxml-mode perl-mode ruby-mode rust-mode sh-mode) . hs-minor-mode))

;; Based on headings
(use-package outline
  :ensure nil
  :defer t
  :hook ((conf-mode
          diff-mode emacs-lisp-mode lisp-interaction-mode lisp-mode
          markdown-mode) . outline-minor-mode))

;; Based on indentation
(use-package outline-indent
  :defer t
  :hook ((python-mode python-ts-mode yaml-mode yaml-ts-mode) .
         outline-indent-minor-mode)
  :custom (outline-indent-ellipsis " …"))

;; Based on treesit language syntax
(use-package treesit-fold
  :defer t
  :hook ((bash-ts-mode
          cmake-ts-mode csharp-ts-mode css-ts-mode c++-ts-mode c-ts-mode
          dockerfile-ts-mode go-mod-ts-mode go-ts-mode java-ts-mode json-ts-mode
          lua-ts-mode markdown-ts-mode php-ts-mode ruby-ts-mode rust-ts-mode
          toml-ts-mode typescript-ts-mode) . treesit-fold-mode)
  :custom
  (treesit-fold-line-count-show t)
  (treesit-fold-line-count-format " …")
  :config (set-face-attribute
           'treesit-fold-replacement-face nil
           :foreground "#808080"
           :box nil
           :weight 'bold))

;; Allows use of same keybindings across backends
(use-package kirigami
  :defer t
  :hook ((bash-ts-mode
          cmake-ts-mode c++-mode c-mode conf-mode csharp-ts-mode css-mode
          css-ts-mode c++-ts-mode c-ts-mode diff-mode dockerfile-ts-mode
          emacs-lisp-mode go-mod-ts-mode go-ts-mode html-mode java-mode
          java-ts-mode js-mode js-json-mode json-ts-mode lisp-interaction-mode
          lisp-mode lua-mode lua-ts-mode markdown-mode markdown-ts-mode
          nxml-mode perl-mode php-ts-mode python-base-mode ruby-mode
          ruby-ts-mode rust-mode rust-ts-mode sh-mode toml-ts-mode
          typescript-ts-mode yaml-ts-mode) . kirigami-mode)
  :functions (kirigami-open-fold
              kirigami-open-fold-rec kirigami-open-folds kirigami-close-fold
              kirigami-close-folds kirigami-toggle-fold)
  :config
  (defvar-keymap that1guycolin/kirigami-functions-map
    :doc "Common code folding functions from `kirigami'."
    "o" #'kirigami-open-fold
    "r" #'kirigami-open-fold-rec
    "u" #'kirigami-open-folds
    "c" #'kirigami-close-fold
    "f" #'kirigami-close-folds
    "a" #'kirigami-toggle-fold)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      that1guycolin/kirigami-functions-map
      "o" "Open Fold"
      "r" "Recursively Open Fold"
      "u" "Open Folds"
      "c" "Close Fold"
      "f" "Close Folds"
      "a" "Toggle Folds"))
  (keymap-global-set "C-c z" that1guycolin/kirigami-functions-map))


;;; Spellcheck:
;; Backend:
(use-package flyspell
  :ensure nil
  :defer t
  :preface (declare-function embark-act "embark")
  :hook ((prog-mode conf-mode text-mode) . flyspell-mode)
  :config
  (keymap-unset flyspell-mode-map "C-.")
  (keymap-global-set "C-." #'embark-act))

;; Correct with flyspell...
(use-package flyspell-correct
  :after (flyspell)
  :demand t
  :bind (:map flyspell-mode-map ("C-&" . flyspell-correct-wrapper)))

;; ...and the avy interface
(use-package flyspell-correct-avy-menu
  :after (flyspell-correct avy)
  :demand t)


(provide '04-code-assist)
;;; 04-code-assist.el ends here
