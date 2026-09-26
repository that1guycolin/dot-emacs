;;; 04-code-assist.el --- Code Smarter, Not Harder -*- lexical-binding: t -*-

;;; Packages included:
;; adaptive-wrap, apheleia, comment-dwim-2, consult-eglot,
;; consult-eglot-embark, consult-flycheck, docstr, dumb-jump, editorconfig,
;; eglot, eglot-tempel, flycheck, flycheck-color-mode-line, flycheck-eglot,
;; flycheck-posframe, flycheck-relint, flyspell, flyspell-correct,
;; flyspell-correct-avy-menu, hideshow, kirigami, lsp-snippet, outline,
;; outline-indent, rainbow-delimiters, smartparens, treesit, treesit-fold,
;; visual-regexp, visual-regexp-steroids

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
  (defvar that1guycolin/eglot-non-defaults (list)
    "List of major-modes with a nonstandard `eglot' configuration.")
  
  (defun that1guycolin/eglot-remove-non-default-programs ()
    "Remove major-modes from `eglot-server-programs'.
All major-modes that are members of `that1guycolin/eglot-non-defaults' will have
their cons removed from `eglot-server-programs'."
    (setq eglot-server-programs
          (cl-remove-if
           (lambda (cell)
             (cl-some
              (lambda (mode)
                (memq mode that1guycolin/eglot-non-defaults
                      (ensure-list (car cell))))
              eglot-server-programs)))))
  :defer t
  :bind (:map ctl-x-map ("e" . eglot))
  :init (add-hook 'elpaca-after-init-hook #'
                  that1guycolin/eglot-remove-non-default-programs))

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
  :commands (hs-minor-mode))

;; Based on headings
(use-package outline
  :ensure nil
  :defer t
  :hook ((conf-mode diff-mode lisp-interaction-mode markdown-mode) .
         outline-minor-mode))

;; Based on indentation
(use-package outline-indent
  :defer t
  :commands (outline-indent-minor-mode)
  :custom (outline-indent-ellipsis " …"))

;; Based on treesit language syntax
(use-package treesit-fold
  :defer t
  :commands (treesit-fold-mode)
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
  :commands (kirigami-mode)
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


;;; Treesit:
(use-package treesit
  :ensure nil
  :demand t
  :preface (declare-function no-littering-expand-var-file-name "no-littering")
  :mode ("\\.tsx\\'" . tsx-ts-mode)
  :init (setq treesit-extra-load-path
              `(,(no-littering-expand-var-file-name "tree-sitter")))
  :custom
  (treesit-enabled-modes t)
  (treesit-font-lock-level 4)
  :config
  (setq
   treesit-language-source-alist
   '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
     (commonlisp . ("https://github.com/tree-sitter-grammars/tree-sitter-commonlisp"))
     (cmake . ("https://github.com/uyha/tree-sitter-cmake"))
     (css . ("https://github.com/tree-sitter/tree-sitter-css"))
     (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
     (dockerfile . ("https://github.com/camdencheek/tree-sitter-dockerfile"))
     (fish . ("https://github.com/ram02z/tree-sitter-fish"))
     (elisp . ("https://github.com/Wilfred/tree-sitter-elisp"))
     (gitcommit . ("https://github.com/gbprod/tree-sitter-gitcommit"))
     (go . ("https://github.com/tree-sitter/tree-sitter-go"))
     (html . ("https://github.com/tree-sitter/tree-sitter-html"))
     (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"
                    "master" "src"))
     (json . ("https://github.com/tree-sitter/tree-sitter-json"))
     (json5 . ("https://github.com/Joakker/tree-sitter-json5"))
     (kdl . ("https://github.com/tree-sitter-grammars/tree-sitter-kdl"))
     (lua . ("https://github.com/MunifTanjim/tree-sitter-lua"))
     (make . ("https://github.com/alemuller/tree-sitter-make"))
     (markdown . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown"
                  "split_parser" "tree-sitter-markdown/src"))
     (markdown-inline . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown"
                         "split_parser" "tree-sitter-markdown-inline/src"))
     (powershell . ("https://github.com/airbus-cert/tree-sitter-powershell"))
     (python . ("https://github.com/tree-sitter/tree-sitter-python"))
     (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))
     (toml . ("https://github.com/ikatyang/tree-sitter-toml"))
     (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript"
             "master" "tsx/src"))
     (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript"
                    "master" "typescript/src"))
     (xml . ("https://github.com/tree-sitter-grammars/tree-sitter-xml"))
     (yaml . ("https://github.com/ikatyang/tree-sitter-yaml"))
     (zsh . ("https://github.com/georgeharker/tree-sitter-zsh")))))


(provide '04-code-assist)
;;; 04-code-assist.el ends here
