;;; 05-coding.el --- Code Smarter, Not Harder -*- lexical-binding: t -*-

;;; Packages included:
;; adaptive-wrap, apheleia, comment-dwim-2, consult-eglot,
;; consult-eglot-embark, consult-flycheck, dumb-jump, editorconfig, eglot,
;; eglot-tempel, flycheck, flycheck-color-mode-line, flycheck-eask,
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
  :hook ((prog-mode text-mode) . adaptive-wrap-prefix-mode))

;; Easily switch between comment types
(use-package comment-dwim-2
  :defer t
  :bind ([remap comment-dwim] . comment-dwim-2))

;; Jump-to-def/find-refs
(use-package dumb-jump
  :demand t
  :functions (dumb-jump-xref-activate)
  :custom
  (dumb-jump-prefer-searcher 'ag)
  (xref-show-definitions-function #'consult-xref)
  :config (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

;; Integrate with editorconfig
(use-package editorconfig
  :defer t
  :hook ((prog-mode text-mode conf-mode) . editorconfig-mode))

;; Colorize "", {}, [], ()
(use-package rainbow-delimiters
  :defer t
  :hook ((prog-mode conf-mode) . rainbow-delimiters-mode))

;; Auto-close "", {}, [], ()
(use-package smartparens
  :defer t
  :hook ((prog-mode text-mode) . smartparens-mode)
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


;;; Linting (Flycheck):
;; bash:          'shellcheck'    (pacman -S shellcheck)
;; common-lisp:   'mallet'        (git clone)
;; common-lisp:   'ocicl'         (pacman -S ocicl)
;; docker-compose 'dclint'        (npm install -g dclint)
;; emacs-lisp:    'emacs-lisp'    (built-in)
;; fish:          'fish-check'    (included with fish)
;; json:          'jsonlint'      (npm install -g jsonlint)
;; lua:           'luacheck'      (pacman -S luacheck)
;; markdown:      'rumdl'         (pacman -S rumdl)
;; systemd:       'systemdlint'   (uv tool install systemdlint)
;; toml:          'tombi'         (pacman -S tombi)
;; xml:           'xmllint'       (pacman -S libxml2)
;; yaml:          'yamllint'      (pacman -S yamllint)

(use-package flycheck
  :defer t
  :preface
  (defvar user/lisp-directory)
  (defvar minions-prominent-modes)
  (defvar sh-shell)
  (defun user/setup-vale ()
    "If not setup, install the vale from the .ini file in site-lisp."
    (interactive)
    (let* ((vale-config (expand-file-name ".vale.ini" user/lisp-directory))
           (vale-install (expand-file-name ".vale-styles" user/lisp-directory))
           (command (format "vale --config %s sync >/dev/null" vale-config)))
      (unless (file-exists-p vale-install)
        (shell-command command))))

  (defun user/flycheck-shellcheck-setup-dash ()
    "Update `flycheck-shell-check-args' when `sh-shell' is dash."
    (when (and (eq major-mode 'sh) (eq sh-shell 'dash))
      (setq-local flycheck-shellcheck-args '("--shell=dash"))))

  :hook ((prog-mode text-mode) . flycheck-mode)
  :functions (flycheck-select-checker flycheck-add-mode)
  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-disabled-checkers
   '(emacs-lisp-elsa rpm-rpmlint yaml-jsyaml yaml-ruby))
  :config
  (add-to-list 'minions-prominent-modes 'flycheck-mode)
  (add-to-list 'flycheck-shellcheck-supported-shells 'dash)
  (flycheck-add-mode 'yaml-yamllint 'docker-compose-mode)
  (add-hook 'sh-mode-hook #'user/flycheck-shellcheck-setup-dash)

  (flycheck-define-checker cl-ocicl
    "Common Lisp checker using `ocicl lint`."
    :command ("ocicl" "lint" source)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
              (id (one-or-more (not (any ":")))) ": " (message) line-end))
    :modes (lisp-mode lisp-data-mode))
  (add-to-list 'flycheck-checkers 'cl-ocicl)
  
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
           (message (minimal-match (one-or-more not-newline)))
           (one-or-more space) (id (one-or-more not-newline))
           line-end))
    :modes (lisp-mode lisp-data-mode))
  (add-to-list 'flycheck-checkers 'cl-mallet)

  (flycheck-define-checker dc-dclint
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
    :modes (docker-compose-mode))
  (add-to-list 'flycheck-checkers 'dc-dclint)

  (flycheck-define-checker fish-self
    "The shell for the 90's built-in syntax checker.
See URL `https://fishshell.com'."
    :command ("fish" "-n" source)
    :error-patterns
    ((error   line-start (file-name) " (line " line "): " (message) line-end)
     (warning line-start (file-name) " (line " line "): " (message) line-end)
     (info    line-start (file-name) " (line " line "): " (message) line-end))
    :modes (fish-mode))
  (add-to-list 'flycheck-checkers 'fish-self)

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
  (add-to-list 'flycheck-checkers 'markdown-rumdl)

  (flycheck-define-checker systemd-systemdlint
    "A Systemd unit file linter.
See URL `https://github.com/priv-kweihmann/systemdlint'."
    :command ("systemdlint" source)
    :error-patterns
    ((error line-start (file-name) ":" line ":" (message) line-end)
     (warning line-start (file-name) ":" line ":" (message) line-end)
     (info line-start (file-name) ":" line ":" (message) line-end))
    :modes systemd-mode)
  (add-to-list 'flycheck-checkers 'systemd-systemdlint)

  (flycheck-define-checker text-vale
    "Tool to bring code-like linting to prose.
See URL `https://vale.sh'."
    :command
    ("vale" "--config" (eval
                        (expand-file-name ".vale.ini" user-emacs-directory))
     "--no-global" "--output" "line" source)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ":"
              (id (one-or-more (not (any ":")))) ":" (message) line-end))
    :modes (markdown-mode gfm-mode text-mode org-mode org-gtd-clarify-mode
                          flycheck-error-message-mode))

  (add-hook 'org-mode-hook #'(lambda ()
                               (flycheck-select-checker 'org-lint)))
  (add-hook 'bash-ts-mode-hook #'(lambda ()
                                   (flycheck-select-checker 'sh-shellcheck))))

;; Display flycheck errors in buffer
(use-package flyover
  :after (flycheck)
  :demand t
  :functions (flyover-mode flyover-toggle flyover-flash-error-at-point)
  :defines (flyover-checkers)
  :init (setq flyover-checkers '(flycheck))
  :custom
  (flyover-levels '(error warning info))
  (flyover-use-theme-colors t)
  (flyover-background-lightness 45)
  (flyover-text-tint 'lighter)
  (flyover-text-tint-percent 50)
  (flyover-icon-tint 'lighter)
  (flyover-icon-tint-percent 50)
  (flyover-icon-background-tint 'darker)
  (flyover-icon-background-tint-percent 50)
  (flyover-border-style 'arrow)
  (flyover-border-match-icon t)
  (flyover-hide-checker-name nil)
  (flyover-show-error-id t)
  (flyover-show-virtual-line t)
  (flyover-virtual-line-type 'curved-arrow)
  (flyover-line-position-offset 0)
  (flyover-wrap-messages t)
  (flyover-max-line-length 120)
  (flyover-debounce-interval 0.5)
  (flyover-cursor-debounce-interval 0.5)
  (flyover-display-mode 'always)
  (flyover-hide-during-completion t)
  :config
  (flyover-mode 1)
  (defvar-keymap user/flyover-functions-map
    :doc "Useful functions for `flyover'."
    "m" #'flyover-mode
    "t" #'flyover-toggle
    "P" #'flyover-flash-error-at-point)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      user/flyover-functions-map
      "m" "(De)Activate Flyover-Mode"
      "t" "Flyover Toggle"
      "p" "Flash Error @ Point"))
  (keymap-global-set "C-c y" user/flyover-functions-map))

;; Buffer status
(use-package flycheck-color-mode-line
  :defer t
  :hook (flycheck-mode . flycheck-color-mode-line-mode))

(use-package flycheck-eask
  :after (eask-mode)
  :demand t
  :config (flycheck-eask-setup))

(use-package flycheck-package
  :after (elisp-mode)
  :defer t
  :config (flycheck-package-setup))

(use-package flycheck-guile
  :after (geiser)
  :demand t)

(use-package consult-flycheck
  :after (consult flycheck)
  :demand t)


;;; Formatting:
;; bash:         'shfmt'         (pacman -S shfmt)
;; cmake:        'neocmakelsp'   (cargo install neocmakelsp)
;; fish:         'fish_indent'   (bundled with fish shell)
;; emacs-lisp:   'lisp-indent'   (built-in)
;; json:         'jq'            (pacman -S jq)
;; lua:          'stylua'        (pacman -S stylua)
;; markdown:     'rumdl'         (pacman -S rumdl)
;; python:       'ruff'          (uv add ruff)
;; toml:         'tombi'         (pacman -S tombi)
;; xml:          'xmllint'       (pacman -S libxml2)
;; yaml:         'yamlfmt'       (pacman -S yamlfmt)

;; sh-mode/bash-ts-mode
(use-package shfmt
  :defer t
  :preface
  (defvar bash-ts-mode-map)
  (defvar sh-mode-map)
  :bind ((:map bash-ts-mode-map
               ("C-c C-f" . shfmt-buffer))
         (:map sh-mode-map
               ("C-c C-f". shfmt-buffer)))
  :hook ((bash-ts-mode sh-mode) . shfmt-on-save-mode)
  :custom
  (shfmt-command "shfmt")
  (shfmt-arguments '("-i" "4" "-ci")))

;; Everything else
(use-package apheleia
  :defer t
  :preface
  (defun user/apheleia-set-json-formatter (fmtr)
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
  
  (defun user/apheleia-toggle-json-formatter ()
    "Switch aphelia formatter between jq & prettier in json-modes."
    (interactive)
    (unless (memq major-mode '(json-ts-mode js-json-mode))
      (error "Buffer not in a json major-mode"))
    (let ((current-fmtr (alist-get major-mode apheleia-mode-alist)))
      (cond
       ((eq current-fmtr 'jq)
        (user/apheleia-set-json-formatter 'prettier-json))
       ((eq current-fmtr 'prettier-json)
        (user/apheleia-set-json-formatter 'jq))
       (t
        (call-interactively #'user/apheleia-set-json-formatter)))))

  (defun user/apheleia-set-yaml-formatter (fmtr)
    "Get user-input on which FMTR they want for Yaml files."
    (interactive
     (list (completing-read
            "Which formatter do you want to use for Yaml files? "
            '(yamlfmt prettier-yaml) nil t)))
    (unless (memq fmtr '(yamlfmt prettier-yaml))
      (user-error "Formatter must be either yamlfmt or prettier-yaml"))
    (setf
     (alist-get 'yaml-mode           apheleia-mode-alist) fmtr
     (alist-get 'yaml-ts-mode        apheleia-mode-alist) fmtr
     (alist-get 'docker-compose-mode apheleia-mode-alist) fmtr)
    (message "Yaml formatter set to %s" fmtr))

  (defun user/apheleia-toggle-yaml-formatter ()
    "Switch aphelia formatter between yamlfmt & prettier in yaml modes."
    (interactive)
    (unless (memq major-mode '(yaml-mode yaml-ts-mode docker-compose-mode))
      (error "Buffer not in a Yaml major-mode"))
    (let ((current-fmtr (alist-get major-mode apheleia-mode-alist)))
      (cond
       ((eq current-fmtr 'yamlfmt)
        (user/apheleia-set-yaml-formatter 'prettier-yaml))
       ((eq current-fmtr 'prettier-yaml)
        (user/apheleia-set-yaml-formatter 'yamlfmt))
       (t
        (call-interactively #'user/apheleia-set-yaml-formatter)))))

  :bind ("C-c f" . apheleia-format-buffer)
  :hook ((prog-mode text-mode) . apheleia-mode)
  :config
  (add-hook 'bash-ts-mode-hook (lambda () (apheleia-mode -1)))
  (add-hook 'sh-mode-hook      (lambda () (apheleia-mode -1)))
  (setf
   (alist-get 'jq          apheleia-formatters) '("jq" "." "-M" "--indent" "2")
   (alist-get 'neocmakelsp apheleia-formatters) '("neocmakelsp" "format" "-")
   (alist-get 'ruff        apheleia-formatters) '("ruff" "format" "-")
   (alist-get 'tombi       apheleia-formatters) '("tombi" "fmt" "-")
   (alist-get 'yamlfmt     apheleia-formatters) '("yamlfmt" "--in"  "-"))
  (setf
   (alist-get 'cmake-ts-mode       apheleia-mode-alist) 'neocmakelsp
   (alist-get 'docker-compose-mode apheleia-mode-alist) 'yamlfmt
   (alist-get 'eask-mode           apheleia-mode-alist) 'lisp-indent
   (alist-get 'fish-mode           apheleia-mode-alist) 'fish-indent
   (alist-get 'js-json-mode        apheleia-mode-alist) 'jq
   (alist-get 'json-ts-mode        apheleia-mode-alist) 'jq
   (alist-get 'markdown-mode       apheleia-mode-alist) 'rumdl
   (alist-get 'markdown-ts-mode    apheleia-mode-alist) 'rumdl
   (alist-get 'gfm-mode            apheleia-mode-alist) 'rumdl
   (alist-get 'python-mode         apheleia-mode-alist) 'ruff
   (alist-get 'python-ts-mode      apheleia-mode-alist) 'ruff
   (alist-get 'toml-ts-mode        apheleia-mode-alist) 'tombi
   (alist-get 'conf-toml-mode      apheleia-mode-alist) 'tombi
   (alist-get 'yaml-mode           apheleia-mode-alist) 'yamlfmt
   (alist-get 'yaml-ts-mode        apheleia-mode-alist) 'yamlfmt)
  (with-eval-after-load 'js-json-mode
    (keymap-set js-json-mode-map "C-c v"
                #'user/apheleia-toggle-json-formatter))
  (with-eval-after-load 'json-ts-mode
    (keymap-set json-ts-mode-map "C-c v"
                #'user/apheleia-toggle-json-formatter))
  (with-eval-after-load 'docker-compose-mode
    (keymap-set docker-compose-mode-map "C-c w"
                #'user/apheleia-toggle-yaml-formatter))
  (with-eval-after-load 'yaml-mode
    (keymap-set yaml-mode-map "C-c v"
                #'user/apheleia-toggle-yaml-formatter))
  (with-eval-after-load 'yaml-ts-mode
    (keymap-set yaml-ts-mode-map "C-c v"
                #'user/apheleia-toggle-yaml-formatter)))


;;; Language-Server-Protocol (eglot):
;; bash:     'bash-language-server'
;;           (pnpm i -g bash-language-server)
;; cmake:    'neocmakelsp'
;;           (cargo install neocmakelsp)
;; compose:  'docker-compose-langserver'
;;           (npm i -g @microsoft/container-language-service)
;; fish:     'fish-lsp'
;;           (npm install -g fish-lsp)
;; json:     'json-language-server'
;;           (pnpm i -g vscode-json-languageserver)
;; lua:      'lua-language-server'
;;           (pacman -S lua-language-server)
;; markdown: 'rumdl'
;;           (pacman -S rumdl)
;; python:   'rass' [`ty'/`ruff']
;;           (uv tool install rass ty ruff)
;; toml:     'tombi'
;;           (pacman -S tombi)
;; xml:      'lemminx'
;;           (install from AUR or see github.com/eclipse-lemminx/lemminx)
;; yaml:     'yaml-language-server'
;;           (npm i -g yaml-language-server)
(use-package eglot
  :ensure nil
  :defer t
  :bind (:map ctl-x-map ("e" . eglot))
  :config
  (setq eglot-server-programs
        (cl-remove-if
         (lambda (cell)
           (cl-some
            (lambda (mode)
              (memq mode '(css-mode
                           css-ts-mode
                           dockerfile-mode dockerfile-ts-mode
                           json-mode json-ts-mode
                           markdown-mode markdown-ts-mode
                           python-mode python-ts-mode)))
            (ensure-list (car cell))))
         eglot-server-programs))

  (let ((lsp-cons-cells
         '(((css-mode css-ts-mode) .
            ("vscode-css-language-server" "--stdio"))
           ((dockerfile-mode dockerfile-ts-mode) .
            ("docker-language-server" "start" "--stdio"))
           ((docker-compose-mode) .
            ("docker-compose-langserver" "--stdio"))
           ((fish-mode) . ("fish-lsp" "start"))
           ((json-mode json-ts-mode) .
            ("vscode-json-language-server" "--stdio"))
           ((markdown-mode markdown-ts-mode) . ("rumdl" "server"))
           ((nxml-mode) . ("lemminx"))
           ((python-mode python-ts-mode) . ("uv" "run" "rass" "python")))))
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
  (defvar-keymap user/kirigami-functions-map
    :doc "Common code folding functions from `kirigami'."
    "o" #'kirigami-open-fold
    "r" #'kirigami-open-fold-rec
    "u" #'kirigami-open-folds
    "c" #'kirigami-close-fold
    "f" #'kirigami-close-folds
    "a" #'kirigami-toggle-fold)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      user/kirigami-functions-map
      "o" "Open Fold"
      "r" "Recursively Open Fold"
      "u" "Open Folds"
      "c" "Close Fold"
      "f" "Close Folds"
      "a" "Toggle Folds"))
  (keymap-global-set "C-c z" user/kirigami-functions-map))


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


(provide '05-coding)
;;; 05-coding.el ends here
