;;; 03-idemacs.el --- Code Smarter, Not Harder -*- lexical-binding: t -*-

;;; Packages included:
;; adaptive-wrap, apheleia, comment-dwim-2, consult-eglot,
;; consult-eglot-embark, consult-flycheck, docstr, dumb-jump, editorconfig,
;; eglot, eglot-tempel, flycheck, flycheck-color-mode-line, flycheck-eglot,
;; flycheck-posframe, flycheck-relint, flyspell, flyspell-correct,
;; flyspell-correct-avy-menu, hideshow, kirigami, lsp-snippet, outline,
;; outline-indent, rainbow-delimiters, smartparens, treesit, treesit-fold,
;; visual-regexp, visual-regexp-steroids

;;; Commentary:
;; The purpose of this file is to define how Emacs should behave when actually
;; working with code. The packages at the top of the file apply to all
;; languages; later in the document, s-exps are separated into groups to
;; define packages and features unique to different languages. Ultimately, the
;; goal is to set up IDE-like features within Emacs, and thus, IDEmacs.

;;; Code:

(require '00-macros)
(declare-function no-littering-expand-var-file-name "no-littering")
(declare-function file-directory-p "emacs")
(declare-function embark-act "embark")
(declare-function corfu-mode "corfu")
(declare-function docstr-lua--before-insert "docstr")
(declare-function docstr-trigger-lua "docstr")
(defvar minions-prominent-modes)
(defvar docstr-lua-modes)
(defvar docstr-lua-style)
(defvar docstr-go-modes)
(defvar python-base-mode-map)
(defvar docstr-python-modes)
(defvar bash-ts-mode-map)
(defvar sh-mode-map)

;;; Treesit:
(use-package treesit
  :ensure nil
  :demand t
  :preface
  (defun that1guycolin/treesit-install-language-grammars ()
    "Install all language grammars."
    (interactive)
    (let ((ts-dir (car treesit-extra-load-path)))
      (unless (file-directory-p ts-dir)
        (mapc (lambda (g)
                (treesit-install-language-grammar g ts-dir))
              (mapcar #'car treesit-language-source-alist)))))
  
  :mode ("\\.tsx\\'" . tsx-ts-mode)
  :init (add-to-list 'treesit-extra-load-path
                     (no-littering-expand-var-file-name "tree-sitter"))
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
     (zsh . ("https://github.com/georgeharker/tree-sitter-zsh"))))
  
  (add-hook 'elpaca-after-init-hook
            (lambda ()
              (run-with-timer
               10 nil #'that1guycolin/treesit-install-language-grammars))))


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
  :demand t
  :functions (docstr-mode
              docstr--doc-valid-p docstr--looking-back docstr--insert-doc-string
              docstr--generic-search-string))

;; Jump-to-def/find-refs
(use-package dumb-jump
  :defer t
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
  :demand t
  :preface
  (defun that1guycolin/flycheck--parse-pretty-json (output)
    "Parse a linter's pretty-printed json OUTPUT.

Flycheck's native `flycheck-parse-json' only works if the json is a single line
string. The purpose of this function is to account for linters whose json output
is in rich text, printed over multiple lines, etc..."
    
    (with-temp-buffer
      (insert output)
      (goto-char (point-min))
      (json-parse-buffer :object-type 'alist :array-type 'list)))
  
  (defun that1guycolin/flycheck-vale-setup ()
    "If not setup, install the vale from the .ini file in user-lisp-directory."
    (let* ((vale-config (expand-file-name ".vale.ini" user-lisp-directory))
           (command (format "vale --config %s sync >/dev/null 2>&1"
                            (shell-quote-argument vale-config))))
      (shell-command command)))
  :hook ((prog-mode text-mode) . flycheck-mode)
  :functions (flycheck-error-new-at flycheck-select-checker flycheck-add-mode)
  :custom (flycheck-disabled-checkers
           '(emacs-lisp-elsa rpm-rpmlint yaml-jsyaml yaml-ruby))
  :config
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
  
  (with-eval-after-load 'minions
    (add-to-list 'minions-prominent-modes 'flycheck-mode))
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
  :demand t
  :bind ("C-c f" . apheleia-format-buffer)
  :hook ((prog-mode text-mode conf-mode) . apheleia-mode))


;;; Language-Server-Protocol (eglot):
(use-package eglot
  :ensure nil
  :demand t
  :preface
  (defun that1guycolin/eglot-remove-mode-servers (mode)
    "Remove servers for MODE from `eglot-server-programs'."
    (setq eglot-server-programs
          (cl-remove-if
           (lambda (cell)
             (memq mode(ensure-list (car cell))))
           eglot-server-programs)))
  :bind (:map ctl-x-map ("e" . eglot)))

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
  :commands (outline-minor-mode))

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
  :after (:any hideshow outline outline-indent treesit-fold)
  :demand t
  :preface
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
  :bind-keymap ("C-c z" . that1guycolin/kirigami-functions-map)
  :functions (kirigami-open-fold
              kirigami-open-fold-rec kirigami-open-folds kirigami-close-fold
              kirigami-close-folds kirigami-toggle-fold)
  :commands (kirigami-mode))


;;; Spellcheck:
;; Backend:
(use-package flyspell
  :ensure nil
  :defer t
  :hook ((prog-mode conf-mode text-mode) . flyspell-mode)
  :custom
  (ispell-program-name "hunspell")
  (ispell-dictionary "en_US")
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


;;; CSS:
(use-package css-mode
  :ensure nil
  :after (eglot)
  :defer t
  :hook (css-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                         (setq-local fill-column 80)))
  :mode "\\.css\\'"
  :init
  (add-to-list 'major-mode-remap-alist '(css-mode . css-ts-mode))
  :config
  (that1guycolin/eglot-remove-mode-servers 'css-mode)
  (add-to-list 'eglot-server-programs
               '((css-ts-mode) .
                 ("vscode-css-language-server" "--stdio"))))


;;; CSV:
(use-package csv-mode
  :defer t
  :hook (csv-mode . (lambda () (setq-local fill-column 1000)))
  :mode "\\.csv\\'")


;;; Containers:
(use-package dockerfile-ts-mode
  :ensure nil
  :after (eglot)
  :defer t
  :hook (dockerfile-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                                (setq-local fill-column 100)))
  :mode ("Dockerfile\\'" "Containerfile\\'")
  :config
  (that1guycolin/eglot-remove-mode-servers 'dockerfile-mode)
  (add-to-list 'eglot-server-programs
               '((dockerfile-ts-mode) .
                 ("docker-language-server" "start" "--stdio"))))


;;; Shaders:
(use-package glsl-mode
  :defer t
  :hook (glsl-mode . (lambda () (setq-local fill-column 100)))
  :mode "\\.glsl\\'")


;;; (E)Lisp:
;; Base packages
(use-package emacs-lisp-mode
  :ensure nil
  :defer t
  :hook (emacs-lisp-mode . (lambda () (outline-minor-mode) (kirigami-mode)
                             (setq-local fill-column 80)))
  :mode "\\.el\\'"
  :custom (flycheck-emacs-lisp-load-path 'inherit))

(use-package lisp-ts-mode
  :after (flycheck eglot)
  :defer t
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
  
  :hook (lisp-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                          (setq-local fill-column 80)))
  :interpreter "sbcl"
  :mode ("\\.lisp\\'" "\\.cl\\'" "\\.asd\\'")
  :init
  (add-to-list 'major-mode-remap-alist '(lisp-mode . lisp-ts-mode))
  :config
  (setf (alist-get 'lisp-ts-mode font-lock-ignore)
        lisp-ts-mode-font-lock-ignore-keywords)

  (flycheck-define-checker cl-mallet
    "A Common Lisp linter using Mallet.
See URL: \\='https://github.com/fukamachi/mallet'."
    :command ("mallet" source)
    :error-patterns
    ((error line-start (zero-or-more space)
            line ":" column
            (one-or-more space) "error" (one-or-more space)
            (message (minimal-match (one-or-more not-newline)))
            (one-or-more space) (id (one-or-more not-newline))
            line-end)

     (warning line-start (zero-or-more space)
              line ":" column
              (one-or-more space) "warning" (one-or-more space)
              (message (minimal-match (one-or-more not-newline)))
              (one-or-more space) (id (one-or-more not-newline))
              line-end)

     (info line-start (zero-or-more space)
           line ":" column
           (one-or-more space) "info" (one-or-more space)
           (message(minimal-match (one-or-more not-newline)))
           (one-or-more space) (id (one-or-more not-newline))
           line-end))
    :modes (lisp-mode lisp-ts-mode lisp-data-mode))
  (add-to-list 'flycheck-checkers 'cl-mallet)

  (that1guycolin/eglot-remove-mode-servers 'lisp-mode)
  (add-to-list 'eglot-server-programs
               '((lisp-mode lisp-ts-mode) .
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
                    :command
                    (list "sbcl"
                          "--eval" "(require :asdf)"
                          "--eval" "(asdf:load-system :alive-lsp)"
                          "--eval"
                          (format "(alive/server::start :port %d)"
                                  that1guycolin/eglot-lisp-alive-port)))
                   (sleep-for 1)
                   (list "localhost" that1guycolin/eglot-lisp-alive-port)))))

(use-package scheme
  :ensure nil
  :defer t
  :hook (scheme-mode . (lambda () (outline-minor-mode) (kirigami-mode)
                         (setq-local fill-column 80)))
  :mode "\\.scm\\'"
  :config
  (add-to-list 'eglot-server-programs
               '((scheme-mode) . ("guile-lsp-server"))))

;; Smart '()' (all)
(use-package adjust-parens
  :defer t
  :hook ((emacs-lisp-mode lisp-mode scheme-mode) . adjust-parens-mode))

;; Style checker (elisp)
(use-package checkdoc
  :ensure nil
  :defer t
  :commands (checkdoc-defun checkdoc-current-buffer))

;; Emacs package assist
(use-package eask-mode
  :defer t
  :after (apheleia)
  :mode "Eask\\'"
  :config
  (setf (alist-get 'eask-mode apheleia-mode-alist) 'lisp-indent))

;; Go directly to symbol definition (elisp)
(use-package elisp-def
  :defer t
  :hook (emacs-lisp-mode . elisp-def-mode))

;; Display function results in buffer (elisp)
(use-package eros
  :defer t
  :hook (emacs-lisp-mode . eros-mode))

(use-package flycheck-eask
  :after (flycheck eask-mode)
  :demand t
  :functions (flycheck-eask-setup)
  :config (flycheck-eask-setup))

(use-package flycheck-guile
  :after (flycheck (:any scheme geiser))
  :demand t)

(use-package flycheck-package
  :after (flycheck elisp-mode)
  :demand t
  :functions (flycheck-package-setup)
  :config (flycheck-package-setup))

;; Improved syntax highlighting (cl)
(use-package gaudy-cl
  :ensure (gaudy-cl :host codeberg :repo "zshaftel/gaudy-cl"
                    :files (:defaults "*.lisp" "*.asd"))
  :defer t
  :hook (lisp-ts-mode . gaudy-cl-mode)
  :custom (gaudy-cl-backend 'sly)
  :config
  (setf (alist-get 'gaudy-cl-mode font-lock-ignore)
        gaudy-cl-font-lock-ignore-keywords)
  (add-hook 'gaudy-cl-mode-hook #'gaudy-cl-highlight-mode))

;; Scheme REPL
(use-package geiser
  :defer t
  :hook ((scheme-mode . turn-on-geiser-mode)
         (geiser-repl-mode . (lambda () (setq-local fill-column 1000))))
  :custom (geiser-repl-use-other-window t))

(use-package geiser-guile
  :after (geiser)
  :demand t
  :bind ("C-c C-s" . geiser-guile-switch))

;; Elisp REPL
(use-package ielm
  :ensure nil
  :defer t
  :bind ("C-c I" . ielm))

;; Inspection tool (elisp)
(use-package inspector
  :defer t
  :bind (:map emacs-lisp-mode-map ("M-I e" . inspector-inspect-expression))
  :custom (inspector-switch-to-buffer nil))

;; Integration (elisp)
(use-package eros-inspector
  :after (eros inspector)
  :demand t
  :bind (:map emacs-lisp-mode-map
              ([remap eros-eval-last-sexp] . eros-inspector-eval-last-sexp)
              ([remap eros-eval-defun]     . eros-inspector-eval-defun)))

;; Support completion for dynamic variables (elisp)
(use-package let-completion
  :defer t
  :hook (emacs-lisp-mode . let-completion-mode))

;; Syntax highlighting (elisp, cl)
(use-package lisp-semantic-hl
  :defer t
  :hook ((emacs-lisp-mode lisp-mode) . lisp-semantic-hl-mode))

;; Interactively parse macros (elisp)
(use-package macrostep
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c C-m" . macrostep-expand)))

;; Interactively parse macros (scheme)
(use-package macrostep-geiser
  :defer t
  :bind ((:map geiser-mode-map
               ("C-c j" . macrostep-geiser))
         (:map geiser-repl-mode-map
               ("C-c j" . macrostep-geiser)))
  :functions (macrostep-geiser-setup)
  :defines (geiser-mode-map)
  :config (macrostep-geiser-setup))

;; Additional font hl (elisp)
(use-package morlock
  :defer t
  :hook (emacs-lisp-mode . morlock-mode))

;; Provide tool to accomplish X (elisp)
(use-package suggest
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c S" . suggest)))

;; Tree-style viewer for inspector (elisp)
(use-package tree-inspector
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("M-I t" . tree-inspector-inspect-expression)
              ("M-I s" . tree-inspector-inspect-last-sexp)))

;; Modern SLIME (cl)
(use-package sly
  :defer t
  :preface
  (defun that1guycolin/sly-load-if-not-connected ()
    "Connect to sly, unless an active connection exists already."
    (unless (sly-connected-p)
      (save-excursion (that1guycolin/sly-autoconnect))))

  (defun that1guycolin/sly-autoconnect ()
    "Start sly based on Emacs-type.
If \\='desktop or \\='termux, run `sly'. If \\='android-gui, connect to
a running slynk instance @ localhost:4005."
    (interactive)
    (if (eq that1guycolin/emacs-type 'android-gui)
        (sly-connect "localhost" 4005)
      (sly)))

  :bind ("C-c s" . that1guycolin/sly-autoconnect)
  :hook (((lisp-mode lisp-ts-mode) . sly-editing-mode)
         (sly-mrepl-mode . (lambda () (setq-local fill-column 1000))))
  :functions (sly sly-connect sly-connected-p sly-mrepl sly-mrepl-new
                  sly-mrepl-sync sly-mrepl-set-directory sly-cd sly-inspect
                  sly-apropos sly-describe-symbol)
  :init (setq inferior-lisp-program "sbcl")
  :custom
  (sly-auto-start 'always)
  (sly-lisp-implementations
   `((sbcl
      ("lisp-repl-core-dumper"
       "-s" "sb-bsd-sockets sb-posix sb-introspect sb-cltl2 asdf"
       "-g" ,(format "--load %s" (expand-file-name"sly/slynk/slynk-loader.lisp"
                                                  elpaca-sources-directory))
       "sbcl"))))
  :config
  (mapc (lambda (c) (add-to-list 'sly-contribs c))
        '(sly-fancy sly-mrepl sly-indentation sly-package-fu))
  (add-hook 'sly-mrepl-mode-hook #'corfu-mode)
  (add-hook 'sly-mode-hook #'that1guycolin/sly-load-if-not-connected)

  (defvar that1guycolin/sly-dispatch)
  (transient-define-prefix that1guycolin/sly-dispatch ()
    "Transient menu for functions related to `sly' & the `sly-mrepl'."
    ["SLYvester the Cat's Common Lisp IDE"
     ["Connection"
      ("s" "Sly" that1guycolin/sly-autoconnect)
      ("c" "Sly Connect" sly-connect)
      ("d" "Sly Disconnect" sly-disconnect)
      ("D" "Sly Disconnect (All)" sly-disconnect-all)]
     ["REPL"
      ("r" "Open" sly-mrepl)
      ("m" "Set Directory" sly-mrepl-set-directory :transient t)
      ("n" "New" sly-mrepl-new)
      ("s" "Sync" sly-mrepl-sync :transient t)]
     ["Utilities"
      ("h" "Change Directory" sly-cd :transient t)
      ("i" "Inspect" sly-inspect)
      ("a" "Match Symbol" sly-apropos)
      ("w" "Describe Symbol" sly-describe-symbol)]])
  (keymap-global-set "C-c s" 'that1guycolin/sly-dispatch))

(use-package sly-quicklisp
  :after (sly)
  :demand t)

(use-package sly-asdf
  :after (sly)
  :demand t)


;;; Go:
(use-package go-ts-mode
  :ensure nil
  :after (docstr)
  :defer t
  :preface
  :hook (go-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                        (setq-local fill-column 80) (docstr-mode 1)))
  :mode "\\.go\\'"
  :config
  (add-to-list 'docstr-writers-alist
               '(go-ts-mode . docstr-writers-golang))
  (add-to-list 'docstr-go-modes 'go-ts-mode))


;;; Lua:
(use-package lua-ts-mode
  :ensure nil
  :after (docstr apheleia)
  :defer t
  :preface
  (defun that1guycolin/docstr-trigger-lua (&rest _)
    "Trigger `docstr' for Lua's \\='---' documentation marker."
    (when (and (memq major-mode '(lua-mode lua-ts-mode))
               (docstr--doc-valid-p)
               (docstr--looking-back "---" 3)
               (memq docstr-lua-style '(luadoc doxygen)))
      (add-hook 'docstr-before-insert-hook #'docstr-lua--before-insert nil t)
      (docstr--insert-doc-string (docstr--generic-search-string 1 ")"))))

  :hook (lua-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                         (setq-local fill-column 120) (docstr-mode 1)))
  :mode "\\.lua\\'"
  :init (add-to-list 'major-mode-remap-alist '(lua-mode . lua-ts-mode))
  :custom (lua-ts-inferior-lua "luajit")
  :config
  (setf
   (alist-get 'stylua apheleia-formatters)
   '("stylua" "--search-parent-directories" "--stdin-filepath" filepath "-"))

  (add-to-list 'docstr-writers-alist
               '(lua-ts-mode . docstr-writers-lua))
  (setq docstr-trigger-alist
        (cons '("-" . that1guycolin/docstr-trigger-lua)
              (cl-remove-if (lambda (trigger)
                              (eq (cdr trigger) #'docstr-trigger-lua))
                            docstr-trigger-alist)))
  (with-eval-after-load 'docstr-lua
    (add-to-list 'docstr-lua-modes 'lua-ts-mode))
  (with-eval-after-load 'docstr-key
    (add-to-list 'docstr-key-javadoc-like-modes 'lua-ts-mode)))


;;; Markdown:
(use-package markdown-ts-mode
  :ensure nil
  :after (flycheck apheleia eglot)
  :defer t
  :hook (markdown-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                              (setq-local fill-column 80)))
  :mode ("\\.md\\'" "README\\'" "INSTALL\\'")
  :init
  (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode))
  :config
  (keymap-set markdown-ts-mode-map "C-c C-x" #'toggle-frame-maximized)
  (flycheck-define-checker markdown-rumdl
    "A fast Markdown linter written in Rust.
See URL: \\='https://github.com/rvben/rumdl'."
    :command ("rumdl" "check" "--watch" "--stdin" source)
    :error-patterns
    ((error line-start (file-name)
            ":" line ":" column ": "
            (id (one-or-more (not (any " ")))) " " (message) line-end)
     (warning line-start (file-name)
              ":" line ":" column ": "
              (id (one-or-more (not (any " ")))) " " (message) line-end)
     (info line-start (file-name)
           ":" line ":" column ": "
           (id (one-or-more (not (any " ")))) " " (message) line-end))
    :modes (markdown-ts-mode markdown-mode gfm-mode))
  (add-to-list 'flycheck-checkers 'markdown-rumdl)

  (setf
   (alist-get 'markdown-mode    apheleia-mode-alist) 'rumdl
   (alist-get 'markdown-ts-mode apheleia-mode-alist) 'rumdl
   (alist-get 'gfm-mode         apheleia-mode-alist) 'rumdl)

  (that1guycolin/eglot-remove-mode-servers 'markdown-mode)
  (add-to-list 'eglot-server-programs
               '((markdown-mode markdown-ts-mode) . ("rumdl" "server"))))

(use-package grip-mode
  :after (markdown-ts-mode)
  :demand t
  :bind (:map markdown-ts-mode-map
              ("C-c g" . grip-mode))
  :custom (grip-command 'auto))


;;; Python:
(use-package python
  :ensure nil
  :after (apheleia eglot)
  :defer t
  :preface
  (defun that1guycolin/python-uv-script-p ()
    "Return non-nil if current buffer is a uv script."
    (and buffer-file-name
         (save-excursion
           (goto-char (point-min))
           (looking-at-p
            (rx "#!/usr/bin/env -S uv tool run --script")))))

  (defun that1guycolin/python-run-smart ()
    "Run current Python file appropriately."
    (interactive)
    (cond
     ((that1guycolin/python-uv-script-p)
      (compile
       (format "uv run %s"
               (shell-quote-argument buffer-file-name))))
     ((locate-dominating-file default-directory "pyproject.toml")
      (compile "uv run python -m pytest"))
     (t
      (compile
       (format "python %s"
               (shell-quote-argument buffer-file-name))))))

  :bind (:map python-base-mode-map
              ("C-c C-k c" . python-skeleton-class)
              ("C-c C-k d" . python-skeleton-def)
              ("C-c C-k f" . python-skeleton-for)
              ("C-c C-k i" . python-skeleton-if)
              ("C-c C-k m" . python-skeleton-import)
              ("C-c C-k t" . python-skeleton-try)
              ("C-c C-k w" . python-skeleton-while)
              ("C-c C-r"   . that1guycolin/python-run-smart))
  :hook (python-ts-mode . (lambda () (outline-indent-minor-mode)
                            (kirigami-mode) (setq-local fill-column 88)
                            (docstr-mode 1)))
  :interpreter ("python3" "uv")
  :mode "\\.py\\'"
  :functions (python-skeleton-class
              python-skeleton-def python-skeleton-for python-skeleton-if
              python-skeleton-import python-skeleton-try python-skeleton-while)
  :init (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
  :custom
  (docstr-python-style 'google)
  (python-indent-offset 4)
  (python-shell-interpreter "python3")
  :config
  (keymap-unset python-base-mode-map "C-c C-t")
  
  (setf
   (alist-get 'ruff apheleia-formatters) '("ruff" "format" "-")
   (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff)

  (that1guycolin/eglot-remove-mode-servers 'python-mode)
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) .
                 ("uv" "run" "rass" "python")))

  (add-to-list 'docstr-writers-alist
               '(python-ts-mode . docstr-writers-python))
  (with-eval-after-load 'docstr-python
    (add-to-list 'docstr-python-modes 'python-ts-mode))
  (with-eval-after-load 'docstr-key
    (add-to-list 'docstr-key-sharp-doc-modes 'python-ts-mode)))

;; Live coding
(use-package live-py-mode
  :after (:any python-mode python-ts-mode)
  :defer t
  :bind (:map python-base-mode-map
              ("C-c L" . live-py-mode)))

;; Support testing frameworks
(use-package python-pytest
  :after (:any python-mode python-ts-mode)
  :defer t
  :bind (:map python-base-mode-map
              ("C-c C-t" . python-pytest-dispatch)))

;; Enhance built-in python(-ts)-mode
(use-package python-x
  :after (:any python-mode python-ts-mode)
  :demand t
  :functions (python-x-setup)
  :config (python-x-setup))


;;; Rust/Cargo:
(use-package rust-ts-mode
  :ensure nil
  :defer t
  :hook (rust-ts-mode . (lambda () (docstr-mode -1) (treesit-fold-mode)
                          (kirigami-mode) (setq-local fill-column 100)))
  :mode "\\.rs\\'"
  :init (add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode)))

(use-package rustic
  :defer t
  :hook (((rust-mode rust-ts-mode) . rustic-mode)
         (rustic-mode . (lambda () (setq-local fill-column 100))))
  :custom
  (compilation-ask-about-save t)
  (rustic-analyzer-command '("/usr/lib/rustup/bin/rust-analyzer"))
  (rustic-cargo-use-last-stored-arguments t)
  (rustic-format-on-save-method 'rustic-format-buffer)
  (rustic-format-trigger 'on-save)
  (rustic-lsp-client 'eglot))


;;; Shell scripts:
(use-package sh-script
  :ensure nil
  :after (apheleia flycheck)
  :defer t
  :preface
  (defun that1guycolin/sh-shell-hooks ()
    "Set hooks for `sh-mode' based on buffer's `sh-shell-file'.
Also used for `bash-ts-mode'. Add to the list `sh-mode-hook'."
    (cond
     ((string-suffix-p "bash" sh-shell-file)
      (when (eq mode-name 'bash-ts-mode)
        (bash-ts-mode))
      (treesit-fold-mode) (kirigami-mode)
      (flycheck-select-checker 'sh-shellcheck))
     ((string-suffix-p "zsh" sh-shell-file)
      (hs-minor-mode) (kirigami-mode))
     ((string-suffix-p "sh" sh-shell-file)
      (hs-minor-mode) (kirigami-mode)
      (flycheck-select-checker 'sh-shellcheck))
     ((string-suffix-p "dash" sh-shell-file)
      (hs-minor-mode) (kirigami-mode)
      (flycheck-select-checker 'sh-shellcheck))))

  :hook (sh-mode . (lambda () (apheleia-mode -1)
                     (setq-local fill-column 80)
                     (that1guycolin/sh-shell-hooks)))
  :mode (("\\.bash\\'" . bash-ts-mode)
         (("\\.dash\\'" "\\.sh\\'" "\\.zsh\\'") . sh-mode))
  :init (add-to-list 'flycheck-shellcheck-supported-shells 'dash)
  :custom
  (flycheck-shellcheck-infer-shell t)
  (setq flycheck-sh-bash-executable "/usr/bin/bash")
  (setq flycheck-sh-posix-bash-executable "/usr/bin/bash")
  (setq flycheck-sh-posix-dash-executable "/usr/bin/dash")
  (setq flycheck-sh-shellcheck-executable "/home/colin-l/.local/bin/shellcheck")
  (setq flycheck-sh-zsh-executable "/usr/bin/zsh")
  :config
  (when (eq system-type 'android)
    (setq flycheck-sh-bash-executable "/data/data/com.termux/files/usr/bin/bash")
    (setq flycheck-sh-posix-bash-executable
          "/data/data/com.termux/files/usr/bin/bash")
    (setq flycheck-sh-posix-dash-executable
          "/data/data/com.termux/files/usr/bin/dash")
    (setq flycheck-sh-shellcheck-executable
          "/data/data/com.termux/files/home/.local/bin/shellcheck")
    (setq flycheck-sh-zsh-executable "/data/data/com.termux/files/usr/bin/zsh"))
  
  (flycheck-define-checker zsh-lint
    "A Flycheck checker for zsh-lint.
See URL `https://wiki.zshell.dev'."
    :command ("zsh-lint" "--format" "json" source)
    :error-parser that1guycolin/flycheck-parse-zsh-lint
    :modes sh-mode)
  (add-hook 'sh-mode-hook
            (lambda ()
              (when (eq sh-shell 'zsh)
                (flycheck-select-checker 'zsh-lint)))))


(use-package shfmt
  :defer t
  :preface
  :bind ((:map bash-ts-mode-map ("C-c f" . shfmt-buffer))
         (:map sh-mode-map      ("C-c f" . shfmt-buffer)))
  :hook ((bash-ts-mode sh-mode) . shfmt-on-save-mode)
  :custom
  (shfmt-command "shfmt")
  (shfmt-arguments '("-i" "4" "-ci")))

(use-package pkgbuild-mode
  :after (eglot)
  :defer t
  :mode "^PKGBUILD\\'"
  :config (with-eval-after-load 'eglot
            (add-to-list 'eglot-server-programs
                         '((pkgbuild-mode) .
                           ("termux-language-server" "--check")))))

;; Fish shell:
(use-package fish-mode
  :after (flycheck apheleia eglot)
  :defer t
  :hook (fish-mode . (lambda () (setq-local fill-column 80)))
  :interpreter "fish"
  :mode "\\.fish\\'"
  :custom (fish-enable-auto-indent t)
  :config
  (flycheck-define-checker fish-self
    "The shell for the 90's built-in syntax checker.
See URL: \\='https://fishshell.com'."
    :command ("fish" "-n" source)
    :error-patterns
    ((error   line-start (file-name) " (line " line "): " (message) line-end)
     (warning line-start (file-name) " (line " line "): " (message) line-end)
     (info    line-start (file-name) " (line " line "): " (message) line-end))
    :modes (fish-mode))
  (add-to-list 'flycheck-checkers 'fish-self)
  (setf (alist-get 'fish-mode apheleia-mode-alist) 'fish-indent)
  (add-to-list 'eglot-server-programs '((fish-mode) . ("fish-lsp" "start"))))


;;; Build File Modes:
;;;  CMake:
(use-package cmake-ts-mode
  :ensure nil
  :after (apheleia)
  :defer t
  :hook (cmake-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                           (setq-local fill-column 100)))
  :mode ("\\.cmake\\'" "CMakeLists\\.txt\\'")
  :init (add-to-list 'major-mode-remap-alist '(cmake-mode . cmake-ts-mode))
  :config
  (setf
   (alist-get 'neocmakelsp apheleia-formatters)
   '("neocmakelsp" "format" "--inplace" buffer-file-name)
   (alist-get 'cmake-ts-mode apheleia-mode-alist) 'neocmakelsp))

(use-package eldoc-cmake
  :after (cmake-ts-mode)
  :defer t
  :commands (eldoc-cmake-enable)
  :init (add-hook 'cmake-ts-mode-hook (lambda ()
                                        (unless (featurep 'cmake-ts-mode)
                                          (eldoc-cmake-enable)))))

(use-package cmake-ide
  :after (cmake-ts-mode)
  :defer t
  :commands (cmake-ide-setup)
  :init (add-hook 'cmake-ts-mode-hook (lambda ()
                                        (unless (featurep 'cmake-ts-mode)
                                          (cmake-ide-setup)))))


;; Justfile:
(use-package just-ts-mode
  :defer t
  :hook (just-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                          (setq-local fill-column 100)))
  :mode "justfile\\'")

;; Makefile:
(use-package makefile-mode
  :ensure nil
  :after (flycheck)
  :defer t
  ;; :preface                           
  ;; (defun that1guycolin)

  :hook (makefile-mode . (lambda () (setq-local fill-column 100)))
  :mode "Makefile\\'"
  :config
  (flycheck-define-checker makefile-checkmake
    "Makefile style-checker/linter written in Go.
See URL: \\='https://github.com/mrtazz/checkmake'."
    :command ("checkmake" "-o" "json" source-inplace)
    :error-parser that1guycolin/flycheck-parse-checkmake
    :modes (makefile-mode makefile-automake-mode makefile-bsdmake-mode
                          makefile-gmake-mode))
  (add-to-list 'flycheck-checkers 'makefile-checkmake))


;;; Config File Modes:
;; INI:
(use-package ini-mode
  :defer t
  :hook (ini-mode . (lambda () (setq-local fill-column 100)))
  :mode ("\\.ini\\'" "\\.desktop\\'" "\\.hook\\'"))

;; JSON:
(use-package json-ts-mode
  :ensure nil
  :after (apheleia eglot)
  :defer t
  :preface
  (defun that1guycolin/apheleia-set-json-formatter (fmtr)
    "Get user-input on which FMTR they want for JSON files."
    (interactive
     (list (intern (completing-read
                    "Which formatter do you want to use for JSON files? "
                    '("jq" "prettier-json") nil t))))
    (unless (memq fmtr '(jq prettier-json))
      (user-error "Formatter must be either jq or prettier-json"))
    (setf
     (alist-get 'js-json-mode apheleia-mode-alist) fmtr
     (alist-get 'json-ts-mode apheleia-mode-alist) fmtr)
    (message "JSON formatter set to %s" fmtr))
  
  (defun that1guycolin/apheleia-toggle-json-formatter ()
    "Switch aphelia formatter between jq & prettier in json-modes."
    (interactive)
    (unless (memq major-mode '(json-ts-mode js-json-mode))
      (error "Buffer not in a json major-mode"))
    (let ((current-fmtr (alist-get major-mode apheleia-mode-alist)))
      (cond
       ((eq current-fmtr 'jq)
        (that1guycolin/apheleia-set-json-formatter 'prettier-json))
       ((eq current-fmtr 'prettier-json)
        (that1guycolin/apheleia-set-json-formatter 'jq))
       (t
        (call-interactively #'that1guycolin/apheleia-set-json-formatter)))))
  
  :hook (json-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                          (setq-local fill-column 80)))
  :mode ("\\.json\\'" "\\.jsonc\\'")
  :config
  (setf
   (alist-get 'jq apheleia-formatters)
   '("jq" "." "-M" "--indent" "2")
   (alist-get 'json-ts-mode apheleia-mode-alist) 'jq)
  (keymap-set json-ts-mode-map "C-c v"
              #'that1guycolin/apheleia-toggle-json-formatter)

  (that1guycolin/eglot-remove-mode-servers 'json-mode)
  (add-to-list 'eglot-server-programs
               '((js-json-mode json-ts-mode) .
                 ("vscode-json-language-server" "--stdio"))))

;; KDL:
(use-package kdl-mode
  :defer t
  :hook (kdl-mode . (lambda () (setq-local fill-column 100)))
  :mode "\\.kdl\\'")

;; Systemd:
(use-package systemd
  :after (flycheck)
  :defer t
  :hook (systemd-mode . (lambda () (setq-local fill-column 100)))
  :mode (("\\.container\\'" . systemd-mode)
         ("\\.service\\'"   . systemd-mode)
         ("\\.socket\\'"    . systemd-mode)
         ("\\.timer\\'"     . systemd-mode))
  :config
  (flycheck-define-checker systemd-systemdlint
    "A Systemd unit file linter.
See URL: \\='https://github.com/priv-kweihmann/systemdlint'."
    :command ("systemdlint" source)
    :error-patterns
    ((error line-start (file-name) ":" line ":" (message) line-end)
     (warning line-start (file-name) ":" line ":" (message) line-end)
     (info line-start (file-name) ":" line ":" (message) line-end))
    :modes systemd-mode)
  (add-to-list 'flycheck-checkers 'systemd-systemdlint))

;; TOML:
(use-package toml-ts-mode
  :ensure nil
  :after (apheleia)
  :defer t
  :hook (toml-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                          (setq-local fill-column 1000)))
  :mode "\\.toml\\'"
  :init (add-to-list 'major-mode-remap-alist '(conf-toml-mode . toml-ts-mode))
  :config
  (setf
   (alist-get 'tombi apheleia-formatters) '("tombi" "fmt" "-")
   (alist-get 'toml-ts-mode apheleia-mode-alist) 'tombi))

;; XML:
(use-package nxml-mode
  :ensure nil
  :after (eglot)
  :defer t
  :hook (nxml-mode . (lambda () (hs-minor-mode) (kirigami-mode)
                       (setq-local fill-column 1000)))
  :mode ("\\.xml\\'"
         "\\.xsd\\'" "\\.xslt\\'" "\\.svg\\'" "\\.rss\\'" "\\.pom\\'")
  :custom
  (nxml-child-indent 2)
  (nxml-attribute-indent 2)
  (nxml-slash-auto-complete-flag t)
  :config
  (that1guycolin/eglot-remove-mode-servers 'nxml-mode)
  (add-to-list 'eglot-server-programs '((nxml-mode) . ("lemminx"))))

(use-package auto-rename-tag
  :defer t
  :hook (nxml-mode . auto-rename-tag-mode))

;; YAML:
(use-package yaml-ts-mode
  :ensure nil
  :after (flycheck apheleia eglot)
  :defer t
  :preface
  ;; (defun that1guycolin/flycheck-handle-json--dclint (output)
  ;;   "Parse the json output from `dclint' into `flycheck' keys.")
  
  (defun that1guycolin/flycheck-yaml-checker ()
    "Select the linter for \\='.ya(m)l' files.
If the current `buffer-file-name' is \\='compose.ya(m)l' or
\\='docker-compose.ya(m)l', use \"dclint\". Otherwise, use \"yamllint\"."
    (unless (eq major-mode 'yaml-ts-mode)
      (error "Buffer not in yaml-ts-mode"))
    (if (and (buffer-file-name)
             (string-match-p
              "/\\(?:compose\\|docker-compose\\)\\.yam?l\\'"
              (buffer-file-name)))
        (flycheck-select-checker 'yaml-dclint)
      (flycheck-select-checker 'yaml-yamllint)))

  (defun that1guycolin/apheleia-set-yaml-formatter (fmtr)
    "Get user-input on which FMTR they want for Yaml files."
    (interactive
     (list (intern (completing-read
                    "Which formatter do you want to use for Yaml files? "
                    '("yamlfmt" "prettier-yaml") nil t))))
    (unless (memq fmtr '(yamlfmt prettier-yaml))
      (user-error "Formatter must be either yamlfmt or prettier-yaml"))
    (setf
     (alist-get 'yaml-ts-mode apheleia-mode-alist) fmtr)
    (message "Yaml formatter set to %s" fmtr))

  (defun that1guycolin/apheleia-toggle-yaml-formatter ()
    "Switch aphelia formatter between yamlfmt & prettier in yaml modes."
    (interactive)
    (unless (eq major-mode 'yaml-ts-mode)
      (error "Buffer not in a Yaml major-mode"))
    (let ((current-fmtr (alist-get major-mode apheleia-mode-alist)))
      (cond
       ((eq current-fmtr 'yamlfmt)
        (that1guycolin/apheleia-set-yaml-formatter 'prettier-yaml))
       ((eq current-fmtr 'prettier-yaml)
        (that1guycolin/apheleia-set-yaml-formatter 'yamlfmt))
       (t
        (call-interactively #'that1guycolin/apheleia-set-yaml-formatter)))))

  :bind (:map yaml-ts-mode-map
              ("C-c v" . that1guycolin/apheleia-toggle-yaml-formatter))
  :hook (yaml-ts-mode . (lambda () (outline-indent-minor-mode) (kirigami-mode)
                          (setq-local fill-column 1000)
                          (that1guycolin/flycheck-yaml-checker)))
  :mode ("\\.yml\\'" "\\.yaml\\'")
  :init
  (add-to-list 'major-mode-remap-alist '(yaml-mode . yaml-ts-mode))
  :config
  (flycheck-define-checker yaml-dclint
    "A yaml linter for \\='compose.yaml' files using dclint.
See URL: \\='https://github.com/zavoloklom/docker-compose-linter'."
    :command ("dclint" "-C"
              (eval (file-name-parent-directory (buffer-file-name))))
    :error-patterns
    ((error line-start (zero-or-more space) line ":" column
            (one-or-more space) "error" (one-or-more space) (message)
            (one-or-more space) (id (one-or-more (any alnum "-"))) line-end)
     (warning line-start (zero-or-more space) line ":" column
              (one-or-more space) "warning" (one-or-more space) (message)
              (one-or-more space) (id (one-or-more (any alnum "-"))) line-end)
     (info line-start (zero-or-more space) line ":" column
           (one-or-more space) "info" (one-or-more space) (message)
           (one-or-more space) (id (one-or-more (any alnum "-"))) line-end))
    :modes (yaml-ts-mode))
  (add-to-list 'flycheck-checkers 'yaml-dclint)

  (setf
   (alist-get 'yamlfmt apheleia-formatters) '("yamlfmt" "--in"  "-")
   (alist-get 'yaml-ts-mode apheleia-mode-alist) 'yamlfmt)

  (that1guycolin/eglot-remove-mode-servers 'yaml-mode)
  (add-to-list 'eglot-server-programs
               '((yaml-ts-mode) .
                 (lambda (_interactive _project)
                   (if (and (buffer-file-name)
                            (string-match-p
                             "/\\(?:compose\\|docker-compose\\)\\.ya?ml\\'"
                             (buffer-file-name)))
                       '("docker-compose-langserver" "--stdio" source)
                     '("yaml-language-server" "--stdio" source))))))

(use-package yaml-pro
  :defer t
  :hook ((yaml-mode yaml-ts-mode) . yaml-pro-mode))



(provide '03-idemacs)
;;; 03-idemacs.el ends here
