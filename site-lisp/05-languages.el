;;; 05-languages.el --- Language Specific Settings -*- lexical-binding: t; -*-

;;; Packages included:
;; adjust-parens, auto-rename-tag, bash-ts-mode, checkdoc, cmake-ts-mode,
;; csv-mode, docker-compose-mode, dockerfile-ts-mode, eask-mode, eldoc-cmake,
;; elisp-def, emacs-lisp-mode, eros, eros-inspector, fish-mode, geiser,
;; geiser-guile, glsl-mode, grip-mode, ielm, ini-mode, inspector, json-ts-mode,
;; just-ts-mode, kdl-mode, lisp-ts-mode, lisp-semantic-hl, live-py-mode,
;; lua-ts-mode, macrostep, macrostep-geiser, markdown-mode, markdown-ts-mode,
;; morlock, nxml-mode, pkgbuild-mode, python-pytest, python-ts-mode, python-x,
;; rustic, rust-ts-mode, scheme-mode, sh-mode, sly, suggest, systemd,
;; toml-ts-mode, tree-inspector, treesit, yaml-pro, yaml-ts-mode

;;; Commentary:
;; The purpose of this file is to define how Emacs should behave in the
;; major-modes of different coding/scripting languages.  Different languages
;; obviously require different settings.  The use of Emacs' built-in treesitter
;; modes is almost always preferred (in this config), and it's worth noting that
;; the only package loaded with `:demand t' & not `:defer t' is treesit.

;;; Code:
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


;;; CSV:
(use-package csv-mode
  :defer t
  :mode "\\.csv\\'")


;;; Containers:
(use-package dockerfile-ts-mode
  :ensure nil
  :defer t
  :mode ("Dockerfile\\'" "Containerfile\\'"))


;;; Shaders:
(use-package glsl-mode
  :defer t
  :mode "\\.glsl\\'")


;;; (E)Lisp:
;; Base packages
(use-package emacs-lisp-mode
  :ensure nil
  :defer t
  :mode "\\.el\\'"
  :custom (flycheck-emacs-lisp-load-path 'inherit))

(use-package lisp-ts-mode
  :defer t
  :interpreter "sbcl"
  :mode ("\\.lisp\\'" "\\.cl\\'" "\\.asd\\'")
  :init (add-to-list 'major-mode-remap-alist '(lisp-mode . lisp-ts-mode))
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
    (add-to-list 'flycheck-checkers 'cl-mallet)))

(use-package scheme-mode
  :ensure nil
  :defer t
  :mode "\\.scm\\'")

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
  :mode "Eask\\'")

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
  :after (flycheck emacs-lisp-mode)
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
  :hook (scheme-mode . turn-on-geiser-mode)
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
  :hook ((lisp-mode lisp-ts-mode) . sly-editing-mode)
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


;;; Lua:
(use-package lua-ts-mode
  :ensure nil
  :defer t
  :mode "\\.lua\\'"
  :init (add-to-list 'major-mode-remap-alist '(lua-mode . lua-ts-mode))
  :custom (lua-ts-inferior-lua "luajit")
  :config (add-hook 'lua-ts-mode-hook (lambda () (docstr-mode 1))))


;;; Makefile:
(use-package makefile-mode
  :ensure nil
  :defer t
  :mode "Makefile\\'"
  :config
  (with-eval-after-load 'flycheck
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

    (flycheck-define-checker makefile-checkmake
      "Makefile style-checker/linter written in Go.
See URL `https://github.com/mrtazz/checkmake'."
      :command ("checkmake" "-o" "json" source-inplace)
      :error-parser that1guycolin/flycheck-checkmake-parse-json
      :modes (makefile-mode makefile-automake-mode makefile-bsdmake-mode
                            makefile-gmake-mode))
    (add-to-list 'flycheck-checkers 'makefile-checkmake)))


;;; Markdown:
(use-package markdown-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.md\\'" "README\\'" "INSTALL\\'")
  :init (add-to-list 'major-mode-remap-alist
                     '(markdown-mode . markdown-ts-mode))
  :config (keymap-set markdown-ts-mode-map "C-c C-x" #'toggle-frame-maximized)
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
    (add-to-list 'flycheck-checkers 'markdown-rumdl)))

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
  (add-hook 'python-ts-mode-hook (lambda () (docstr-mode 1))))

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
  :mode "\\.rs\\'"
  :init (add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode))
  :config (add-hook 'rust-ts-mode-hook (lambda () (docstr-mode 1))))

(use-package rustic
  :defer t
  :hook ((rust-mode rust-ts-mode) . rustic-mode)
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
  :interpreter "bash"
  :mode "\\.bash\\'")

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

  :hook (sh-mode . that1guycolin/sh-mode-shell-auto)
  :interpreter ("sh" "zsh" "dash")
  :mode ("\\.zsh\\'" "\\.dash\\'")
  :init (with-eval-after-load 'flycheck
          (add-to-list 'flycheck-shellcheck-supported-shells 'dash))
  (add-hook 'bash-ts-mode-hook
            (lambda () (flycheck-select-checker 'sh-shellcheck)))
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

(use-package pkgbuild-mode
  :defer t
  :mode "^PKGBUILD\\'")

;; Fish shell:
(use-package fish-mode
  :defer t
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
    (add-to-list 'flycheck-checkers 'fish-self)))


;;; Build File Modes:
;;; CMake:
(use-package cmake-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.cmake\\'" "CMakeLists\\.txt\\'")
  :init (add-to-list 'major-mode-remap-alist '(cmake-mode . cmake-ts-mode)))

(use-package eldoc-cmake
  :defer t
  :hook ((cmake-mode cmake-ts-mode) . eldoc-cmake-enable))

;; Justfile:
(use-package just-ts-mode
  :defer t
  :mode "justfile\\'")


;;; Config File Modes:
;; INI:
(use-package ini-mode
  :defer t
  :mode ("\\.ini\\'" "\\.desktop\\'" "\\.hook\\'"))

;; JSON:
(use-package json-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.json\\'" "\\.jsonc\\'"))

(use-package json5-ts-mode
  :defer t
  :mode ("\\.json5\\'"))

;; KDL:
(use-package kdl-mode
  :defer t
  :mode "\\.kdl\\'")

;; Systemd:
(use-package systemd
  :defer t
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
  :mode "\\.toml\\'"
  :init (add-to-list 'major-mode-remap-alist '(conf-toml-mode . toml-ts-mode)))

;; XML:
(use-package nxml-mode
  :ensure nil
  :defer t
  :mode ("\\.xml\\'"
         "\\.xsd\\'" "\\.xslt\\'" "\\.svg\\'" "\\.rss\\'" "\\.pom\\'")
  :custom
  (nxml-child-indent 2)
  (nxml-attribute-indent 2)
  (nxml-slash-auto-complete-flag t))

(use-package auto-rename-tag
  :defer t
  :hook (nxml-mode . auto-rename-tag-mode))

;;; YAML:
(use-package yaml-ts-mode
  :ensure nil
  :defer t
  :preface
  :mode ("\\.yml\\'" "\\.yaml\\'")
  :init (add-to-list 'major-mode-remap-alist '(yaml-mode . yaml-ts-mode))
  :config
  (with-eval-after-load 'flycheck
    (flycheck-define-checker yaml-dclint
      "A Docker Compose linter using dclint.
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
    (add-to-list 'flycheck-checkers 'yaml-dclint)
    
    (defun that1guycolin/flycheck-yaml-linter ()
      "Select the linter for \\='.ya(m)l' files.
If the current `buffer-file-name' is \\='compose.ya(m)l' or
\\='docker-compose.ya(m)l', use \"dclint\".  Otherwise, use \"yamllint\"."
      (unless (eq major-mode 'yaml-ts-mode)
        (error "Buffer not in yaml-ts-mode"))
      (if (string-match-p
           "/\\(?:compose\\|docker-compose\\)\\.yam?ml\\'"
           (buffer-file-name))
          (flycheck-select-checker 'yaml-dclint)
        (flycheck-select-checker 'yaml-yamllint)))
    (add-hook 'yaml-ts-mode-hook #'that1guycolin/flycheck-yaml-linter)))

(use-package yaml-pro
  :defer t
  :hook ((yaml-mode yaml-ts-mode) . yaml-pro-mode))


(provide '05-languages)
;;; 05-languages.el ends here
