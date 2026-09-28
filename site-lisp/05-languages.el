;;; 05-languages.el --- Language Specific Settings -*- lexical-binding: t; -*-

;;; Packages included:
;; adjust-parens, auto-rename-tag, bash-ts-mode, checkdoc, cmake-ts-mode,
;; css-ts-mode, csv-mode, dockerfile-ts-mode, eask-mode, eldoc-cmake, elisp-def,
;; emacs-lisp-mode, eros, eros-inspector, fish-mode, flycheck-eask,
;; flycheck-guile, flycheck-package, gaudy-cl, geiser, geiser-guile, glsl-mode,
;; go-ts-mode, grip-mode, ielm, ini-mode, inspector, json-ts-mode, just-ts-mode,
;; kdl-mode, let-completion, lisp-semantic-hl, lisp-ts-mode, live-py-mode,
;; lua-ts-mode, macrostep, macrostep-geiser, makefile-mode, markdown-ts-mode,
;; morlock, nxml-mode, pkgbuild-mode, python-pytest, python-ts-mode, python-x,
;; rust-ts-mode, rustic, scheme-mode, sh-mode, shfmt, sly, sly-asdf,
;; sly-quicklisp, suggest, systemd, toml-ts-mode, tree-inspector, yaml-pro,
;; yaml-ts-mode

;;; Commentary:
;; The purpose of this file is to define how Emacs should behave in the
;; major-modes of various coding/scripting languages; different languages
;; require different settings.  The use of an Emacs built-in treesitter mode is
;; almost always given preference over its non-treesitter counterpart (in this
;; config).  Note how all packages are loaded with `:defer' or `:after'.

;;; Code:
(require '04-code-assist)
(declare-function treesit-fold-mode "treesit")
(declare-function kirigami-mode "kirigami")
(declare-function that1guycolin/eglot-remove-mode-servers "04-code-assist")

(defvar eglot-server-programs)


;;; CSS:
(use-package css-ts-mode
  :ensure nil
  :defer t
  :hook (css-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                         (setq-local fill-column 80)))
  :mode "\\.css\\'"
  :init
  (add-to-list 'major-mode-remap-alist '(css-mode . css-ts-mode))
  :config
  (with-eval-after-load 'eglot
    (that1guycolin/eglot-remove-mode-servers 'css-mode)
    (add-to-list 'eglot-server-programs
                 '((css-ts-mode) .
                   ("vscode-css-language-server" "--stdio")))))


;;; CSV:
(use-package csv-mode
  :defer t
  :hook (csv-mode . (lambda () (setq-local fill-column 1000)))
  :mode "\\.csv\\'")


;;; Containers:
(use-package dockerfile-ts-mode
  :ensure nil
  :defer t
  :hook (dockerfile-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                                (setq-local fill-column 100)))
  :mode ("Dockerfile\\'" "Containerfile\\'")
  :config
  (with-eval-after-load 'eglot
    (that1guycolin/eglot-remove-mode-servers 'dockerfile-mode)
    (add-to-list 'eglot-server-programs
                 '((dockerfile-ts-mode) .
                   ("docker-language-server" "start" "--stdio")))))


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

  (with-eval-after-load 'flycheck
    (flycheck-define-checker cl-mallet
      "A Common Lisp linter using Mallet.
See URL: `https://github.com/fukamachi/mallet'."
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
    (add-to-list 'flycheck-checkers 'cl-mallet))

  (with-eval-after-load 'eglot
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
                     (list "localhost" that1guycolin/eglot-lisp-alive-port))))))

(use-package scheme-mode
  :ensure nil
  :defer t
  :hook (scheme-mode . (lambda () (outline-minor-mode) (kirigami-mode)
                         (setq-local fill-column 80)))
  :mode "\\.scm\\'"
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((scheme-mode) . ("guile-lsp-server"))))
  (add-hook 'scheme-mode-hook #'outline-minor-mode))

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
  :mode "Eask\\'"
  :config
  (with-eval-after-load 'apheleia
    (setf
     (alist-get 'eask-mode apheleia-mode-alist) 'lisp-indent)))

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
  :after (flycheck (:any scheme-mode geiser))
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
  (require '00-macros)
  (declare-function corfu-mode "corfu")

  (defun that1guycolin/sly-load-if-not-connected ()
    "Connect to sly, unless an active connection exists already."
    (unless (sly-connected-p)
      (save-excursion (that1guycolin/sly-autoconnect))))

  (defun that1guycolin/sly-autoconnect ()
    "Start sly based on Emacs-type.
If \\='desktop or \\='termux, run `sly'.  If \\='android-gui, connect to
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
  (sly-lisp-implementations
   `((sbcl
      ("lisp-repl-core-dumper"
       "-s" "sb-bsd-sockets sb-posix sb-introspect sb-cltl2 asdf"
       "-g" ,(format "--load %s" (expand-file-name"sly/slynk/slynk-loader.lisp"
                                                  elpaca-sources-directory))
       "sbcl"))))
  :config
  (dolist (contrib '(sly-fancy sly-mrepl sly-indentation sly-package-fu))
    (add-to-list 'sly-contribs contrib))
  (setq sly-auto-start 'always)
  (add-hook 'sly-mrepl-mode-hook #'corfu-mode)
  (add-hook 'sly-mode-hook #'that1guycolin/sly-load-if-not-connected)
  (with-eval-after-load 'transient
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
        ("w" "Describe Symbol" sly-describe-symbol)]]))
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
  :defer t
  :hook (go-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                        (setq-local fill-column 80)))
  :mode "\\.go\\'")


;;; Lua:
(use-package lua-ts-mode
  :ensure nil
  :defer t
  :hook (lua-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                         (setq-local fill-column 120)))
  :mode "\\.lua\\'"
  :init (add-to-list 'major-mode-remap-alist '(lua-mode . lua-ts-mode))
  :custom (lua-ts-inferior-lua "luajit")
  :config
  (add-hook 'lua-ts-mode-hook (lambda () (docstr-mode 1)))
  (with-eval-after-load 'apheleia
    (setf
     (alist-get 'stylua apheleia-formatters) '("stylua" "--stdin-filepath"
                                               filepath "-"))))


;;; Makefile:
(use-package makefile-mode
  :ensure nil
  :defer t
  :preface
  (defun that1guycolin/flycheck-checkmake--read-json (output)
    "Parse the leading JSON array out of OUTPUT, ignoring trailing text."
    (with-temp-buffer
      (insert output)
      (goto-char (point-min))
      (json-parse-buffer :object-type 'alist :array-type 'list)))

  (defun that1guycolin/flycheck-checkmake-parse-json (output checker buffer)
    "Parse checkmake's JSON OUTPUT into Flycheck errors for CHECKER/BUFFER."
    (mapcar
     (lambda (violation)
       (flycheck-error-new-at
        (alist-get 'line_number violation)
        nil
        (if (member (alist-get 'rule violation) '("miniphony"))
            'error
          'warning)
        (format "[%s] %s"
                (alist-get 'rule violation)
                (alist-get 'violation violation))
        :checker checker
        :buffer buffer
        :filename (buffer-file-name buffer)))
     (that1guycolin/flycheck-checkmake--read-json output)))
  
  :hook (makefile-mode . (lambda () (setq-local fill-column 100)))
  :mode "Makefile\\'"
  :config
  (with-eval-after-load 'flycheck
    (flycheck-define-checker makefile-checkmake
      "Makefile style-checker/linter written in Go.
See URL `https://github.com/mrtazz/checkmake'.  Install with \\='go
install github.com/checkmake/checkmake/cmd/checkmake@latest'."
      :command ("checkmake" "-o" "json" source-inplace)
      :error-parser that1guycolin/flycheck-checkmake-parse-json
      :modes (makefile-mode makefile-automake-mode makefile-bsdmake-mode
                            makefile-gmake-mode))
    (add-to-list 'flycheck-checkers 'makefile-checkmake)))


;;; Markdown:
(use-package markdown-ts-mode
  :ensure nil
  :defer t
  :hook (markdown-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                              (setq-local fill-column 80)))
  :mode ("\\.md\\'" "README\\'" "INSTALL\\'")
  :init
  (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode))
  :config
  (keymap-set markdown-ts-mode-map "C-c C-x" #'toggle-frame-maximized)
  (with-eval-after-load 'flycheck
    (flycheck-define-checker markdown-rumdl
      "A fast Markdown linter written in Rust.
See URL `https://github.com/rvben/rumdl'."
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
    (add-to-list 'flycheck-checkers 'markdown-rumdl))

  (with-eval-after-load 'apheleia
    (setf
     (alist-get 'markdown-mode    apheleia-mode-alist) 'rumdl
     (alist-get 'markdown-ts-mode apheleia-mode-alist) 'rumdl
     (alist-get 'gfm-mode         apheleia-mode-alist) 'rumdl))

  (with-eval-after-load 'eglot
    (that1guycolin/eglot-remove-mode-servers 'markdown-mode)
    (add-to-list 'eglot-server-programs
                 '((markdown-mode markdown-ts-mode) . ("rumdl" "server")))))

(use-package grip-mode
  :after (markdown-ts-mode)
  :demand t
  :bind (:map markdown-ts-mode-map
              ("C-c g" . grip-mode))
  :custom (grip-command 'auto))


;;; Python:
(use-package python-ts-mode
  :ensure nil
  :defer t
  :preface
  (defvar python-base-mode-map)

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
  :init
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
  :custom
  (docstr-python-style 'google)
  (python-indent-offset 4)
  (python-shell-interpreter "python3")
  :config
  (keymap-unset python-base-mode-map "C-c C-t")
  
  (with-eval-after-load 'apheleia
    (setf
     (alist-get 'ruff apheleia-formatters) '("ruff" "format" "-")
     (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff))

  (with-eval-after-load 'eglot
    (that1guycolin/eglot-remove-mode-servers 'python-mode)
    (add-to-list 'eglot-server-programs
                 '((python-mode python-ts-mode) .
                   ("uv" "run" "rass" "python")))))

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
(use-package bash-ts-mode
  :ensure nil
  :defer t
  :hook (bash-ts-mode . (lambda () (apheleia-mode -1) (treesit-fold-mode)
                          (kirigami-mode)
                          (setq-local fill-column 80)))
  :interpreter "bash"
  :mode "\\.bash\\'"
  :config (with-eval-after-load 'flycheck
            (flycheck-select-checker 'bash-ts-mode)))

(use-package sh-mode
  :ensure nil
  :defer t
  :preface
  (defun that1guycolin/sh-mode-shell-auto ()
    "Automatically set `sh-shell-file' based on `sh-shell'."
    (interactive)
    (unless (or (eq major-mode 'sh-mode) (eq major-mode 'bash-ts-mode))
      (user-error "Buffer not in a shell-script mode"))
    (let ((file nil))
      (cond
       ((eq sh-shell 'bash)  (setq file "/usr/bin/bash"))
       ((eq sh-shell 'dash)  (setq file "/usr/bin/dash"))
       ((eq sh-shell 'zsh)   (setq file "/usr/bin/zsh"))
       (t                    (setq file "/usr/bin/zsh")))
      (when (or (eq that1guycolin/emacs-type 'android-gui)
                (eq that1guycolin/emacs-type 'termux))
        (setq file (concat "/data/data/com.termux/files" file)))
      (setq-local sh-shell-file file)))

  :hook (sh-mode . (lambda ()  (that1guycolin/sh-mode-shell-auto)
                     (apheleia-mode -1) (hs-minor-mode) (kirigami-mode)
                     (setq-local fill-column 80)))
  :interpreter ("sh" "zsh" "dash")
  :mode ("\\.zsh\\'" "\\.dash\\'")
  :init (with-eval-after-load 'flycheck
          (add-to-list 'flycheck-shellcheck-supported-shells 'dash))
  :custom
  (flycheck-shellcheck-infer-shell t)
  (flycheck-sh-bash-executable
   (that1guycolin/desktop-mobile
     :desk "/usr/bin/bash"
     :termux "/data/data/com.termux/files/usr/bin/bash"))
  (flycheck-sh-posix-bash-executable
   (that1guycolin/desktop-mobile
     :desk "/usr/bin/bash"
     :termux "/data/data/com.termux/files/usr/bin/bash"))
  (flycheck-sh-posix-dash-executable
   (that1guycolin/desktop-mobile
     :desk "/usr/bin/shellcheck"
     :termux "/data/data/com.termux/files/usr/bin/shellcheck"))
  (flycheck-sh-zsh-executable
   (that1guycolin/desktop-mobile
     :desk "/usr/bin/zsh"
     :termux "/data/data/com.termux/files/usr/bin/zsh")))

(use-package shfmt
  :defer t
  :preface
  (defvar bash-ts-mode-map)
  (defvar sh-mode-map)
  :bind ((:map bash-ts-mode-map
               ("C-c f" . shfmt-buffer))
         (:map sh-mode-map
               ("C-c f". shfmt-buffer)))
  :hook ((bash-ts-mode sh-mode) . shfmt-on-save-mode)
  :custom
  (shfmt-command "shfmt")
  (shfmt-arguments '("-i" "4" "-ci")))

(use-package pkgbuild-mode
  :defer t
  :mode "^PKGBUILD\\'"
  :config (with-eval-after-load 'eglot
            (add-to-list 'eglot-server-programs
                         '((pkgbuild-mode) .
                           ("termux-language-server" "--check")))))

;; Fish shell:
(use-package fish-mode
  :defer t
  :hook (fish-mode . (lambda () (setq-local fill-column 80)))
  :interpreter "fish"
  :mode "\\.fish\\'"
  :custom (fish-enable-auto-indent t)
  :config
  (with-eval-after-load 'flycheck
    (flycheck-define-checker fish-self
      "The shell for the 90's built-in syntax checker.
See URL `https://fishshell.com'."
      :command ("fish" "-n" source)
      :error-patterns
      ((error   line-start (file-name) " (line " line "): " (message) line-end)
       (warning line-start (file-name) " (line " line "): " (message) line-end)
       (info    line-start (file-name) " (line " line "): " (message) line-end))
      :modes (fish-mode))
    (add-to-list 'flycheck-checkers 'fish-self))

  (with-eval-after-load 'apheleia
    (setf (alist-get 'fish-mode apheleia-mode-alist) 'fish-indent))

  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs '((fish-mode) . ("fish-lsp" "start")))))


;;; Build File Modes:
;;;  CMake:
(use-package cmake-ts-mode
  :ensure nil
  :defer t
  :hook (cmake-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                           (setq-local fill-column 100)))
  :mode ("\\.cmake\\'" "CMakeLists\\.txt\\'")
  :init (add-to-list 'major-mode-remap-alist '(cmake-mode . cmake-ts-mode))
  :config
  (with-eval-after-load 'apheleia
    (setf
     (alist-get 'neocmakelsp apheleia-formatters)
     '("neocmakelsp" "format" "-")
     (alist-get 'cmake-ts-mode apheleia-mode-alist) 'neocmakelsp)))

(use-package eldoc-cmake
  :defer t
  :hook ((cmake-mode cmake-ts-mode) . eldoc-cmake-enable))

;; Justfile:
(use-package just-ts-mode
  :defer t
  :hook (just-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                          (setq-local fill-column 100)))
  :mode "justfile\\'")


;;; Config File Modes:
;; INI:
(use-package ini-mode
  :defer t
  :hook (ini-mode . (lambda () (setq-local fill-column 100)))
  :mode ("\\.ini\\'" "\\.desktop\\'" "\\.hook\\'"))

;; JSON:
(use-package json-ts-mode
  :ensure nil
  :defer t
  :preface
  (defun that1guycolin/apheleia-set-json-formatter (fmtr)
    "Get user-input on which FMTR they want for JSON files."
    (interactive
     (list (completing-read
            "Which formatter do you want to use for JSON files? "
            '(jq prettier-json) nil t)))
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
  (with-eval-after-load 'apheleia
    (setf
     (alist-get 'jq apheleia-formatters)
     '("jq" "." "-M" "--indent" "2")
     (alist-get 'prettier-json apheleia-formatters)
     '("pnpx" "prettier" "--stdin-filepath" filepath "--parser=json")
     (alist-get 'json-ts-mode apheleia-mode-alist) 'jq)
    (keymap-set json-ts-mode-map "C-c v"
                #'that1guycolin/apheleia-toggle-json-formatter))

  (with-eval-after-load 'eglot
    (that1guycolin/eglot-remove-mode-servers 'json-mode)
    (add-to-list 'eglot-server-programs
                 '((js-json-mode json-ts-mode) .
                   ("vscode-json-language-server" "--stdio")))))

;; KDL:
(use-package kdl-mode
  :defer t
  :hook (kdl-mode . (lambda () (setq-local fill-column 100)))
  :mode "\\.kdl\\'")

;; Systemd:
(use-package systemd
  :defer t
  :hook (systemd-mode . (lambda () (setq-local fill-column 100)))
  :mode (("\\.container\\'" . systemd-mode)
         ("\\.service\\'"   . systemd-mode)
         ("\\.socket\\'"    . systemd-mode)
         ("\\.timer\\'"     . systemd-mode))
  :config
  (with-eval-after-load 'flycheck
    (flycheck-define-checker systemd-systemdlint
      "A Systemd unit file linter.
See URL `https://github.com/priv-kweihmann/systemdlint'."
      :command ("systemdlint" source)
      :error-patterns
      ((error line-start (file-name) ":" line ":" (message) line-end)
       (warning line-start (file-name) ":" line ":" (message) line-end)
       (info line-start (file-name) ":" line ":" (message) line-end))
      :modes systemd-mode)
    (add-to-list 'flycheck-checkers 'systemd-systemdlint)))

;; TOML:
(use-package toml-ts-mode
  :ensure nil
  :defer t
  :hook (toml-ts-mode . (lambda () (treesit-fold-mode) (kirigami-mode)
                          (setq-local fill-column 1000)))
  :mode "\\.toml\\'"
  :init (add-to-list 'major-mode-remap-alist '(conf-toml-mode . toml-ts-mode))
  :config
  (with-eval-after-load 'apheleia
    (setf
     (alist-get 'tombi apheleia-formatters) '("tombi" "fmt" "-")
     (alist-get 'toml-ts-mode apheleia-mode-alist) 'tombi)))

;; XML:
(use-package nxml-mode
  :ensure nil
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
  (with-eval-after-load 'eglot
    (that1guycolin/eglot-remove-mode-servers 'nxml-mode)
    (add-to-list 'eglot-server-programs '((nxml-mode) . ("lemminx")))))

(use-package auto-rename-tag
  :defer t
  :hook (nxml-mode . auto-rename-tag-mode))

;;; YAML:
(use-package yaml-ts-mode
  :ensure nil
  :defer t
  :preface
  (defun that1guycolin/flycheck-yaml-checker ()
    "Select the linter for \\='.ya(m)l' files.
If the current `buffer-file-name' is \\='compose.ya(m)l' or
\\='docker-compose.ya(m)l', use \"dclint\".  Otherwise, use \"yamllint\"."
    (unless (eq major-mode 'yaml-ts-mode)
      (error "Buffer not in yaml-ts-mode"))
    (if (and (buffer-file-name)
             (string-match-p
              "/\\(?:compose\\|docker-compose\\)\\.yam?ml\\'"
              (buffer-file-name)))
        (flycheck-select-checker 'yaml-dclint)
      (flycheck-select-checker 'yaml-yamllint)))

  (defun that1guycolin/apheleia-set-yaml-formatter (fmtr)
    "Get user-input on which FMTR they want for Yaml files."
    (interactive
     (list (completing-read
            "Which formatter do you want to use for Yaml files? "
            '(yamlfmt prettier-yaml) nil t)))
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
  (with-eval-after-load 'flycheck
    (flycheck-define-checker yaml-dclint
      "A yaml linter for \\='compose.yaml' files using dclint.
See URL: https://github.com/zavoloklom/docker-compose-linter"
      :command ("dclint" source)
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
    (add-to-list 'flycheck-checkers 'yaml-dclint))

  (with-eval-after-load 'apheleia
    (setf
     (alist-get 'yamlfmt apheleia-formatters) '("yamlfmt" "--in"  "-")
     (alist-get 'yaml-ts-mode apheleia-mode-alist) 'yamlfmt))

  (with-eval-after-load 'eglot
    (that1guycolin/eglot-remove-mode-servers 'yaml-mode)
    (add-to-list 'eglot-server-programs
                 '((yaml-ts-mode) .
                   (lambda (_interactive _project)
                     (if (and (buffer-file-name)
                              (string-match-p
                               "/\\(?:compose\\|docker-compose\\)\\.yam?ml\\'"
                               (buffer-file-name)))
                         '("docker-compose-langserver" "--stdio")
                       '("yaml-language-server" "--stdio")))))))

(use-package yaml-pro
  :defer t
  :hook ((yaml-mode yaml-ts-mode) . yaml-pro-mode))


(provide '05-languages)
;;; 05-languages.el ends here

                                        ; LocalWords:  fmtr
