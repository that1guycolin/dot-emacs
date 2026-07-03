;;; 08-code-assist.el --- Linting, formatting, & LSPs -*- lexical-binding: t; -*-

;;; Packages included:
;; adaptive-wrap, apheleia, comment-dwim-2, consult-eglot,
;; consult-eglot-embark, consult-flycheck, dumb-jump, eglot, flycheck,
;; flycheck-color-mode-line, flycheck-eask, flycheck-eglot, flycheck-package,
;; flyover, flyspell, flyspell-correct, flyspell-correct-avy-menu, hideshow,
;; kirigami, lsp-snippet, outline, outline-indent, rainbow-delimiters, shfmt,
;; smartparens, treesit-fold, visual-regexp, visual-regexp-steroids

;;; Commentary:
;; Call packages that support efficient & productive coding at a global scope.
;; The packages called in this file set up an Emacs IDE.

;;; Code:
;;;; =======  TEXT MANIPULATION  =======
;; `adaptive-wrap'           (smart text wrapping)
;; `comment-dwim-2'          (easily switch between comment-types)
;; `dumb-jump'               (jump-to-def/find-refs)
;; `rainbow-delimiters'      (colorize "", {}, [], ())
;; `smartparens'             (auto-close "", {}, [], ())
;; `visual-regexp'           (hl regexp as you type)
;; `visual-regexp-steroids'  (use python-style regexp instead of Emacs)
;;   ===================================
(use-package adaptive-wrap
  :defer t
  :hook ((prog-mode text-mode) . adaptive-wrap-prefix-mode))

(use-package comment-dwim-2
  :defer t
  :bind ([remap comment-dwim] . comment-dwim-2))

(use-package dumb-jump
  :demand t
  :functions dumb-jump-xref-activate
  :custom
  (dumb-jump-prefer-searcher 'ag)
  (xref-show-definitions-function #'consult-xref)
  :config
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

(use-package rainbow-delimiters
  :defer t
  :hook ((prog-mode conf-mode) . rainbow-delimiters-mode))

(use-package smartparens
  :defer t
  :hook ((prog-mode text-mode) . smartparens-mode)
  :config
  (require 'smartparens-config))

(use-package visual-regexp
  :defer t
  :bind
  (("C-c r" . vr/replace)
   ("C-c q" . vr/query-replace)))

(use-package visual-regexp-steroids
  :defer t
  :bind
  (([remap isearch-forward-regexp]  . vr/isearch-forward)
   ([remap isearch-backward-regexp] . vr/isearch-backward)))


;;;; =======  FLYCHECK  =======
;; bash:        'shellcheck'    (pacman -S shellcheck)
;; emacs-lisp:  'emacs-lisp'    (built-in)
;; json:        'jsonlint'      (pnpm install -g jsonlint)
;; lua:         'luacheck'      (pacman -S luacheck)
;; markdown:    'rumdl'         (pacman -S rumdl)
;; systemd:     'systemdlint'   (uv tool install systemdlint)
;; toml:        'tombi'         (uv tool install tombi)
;; xml:         'xmllint'       (pacman -S libxml2)
;; yaml:        'yamllint'      (pacman -S yamllint)
;; --------------------------
;; Extensions:
;; `flyover'                     (display errors in buffer)
;; `flycheck-color-mode-line'    (display buffer status)
;; `flycheck-eask'               (Support Eask files)
;; `flycheck-package'            (Support Emacs' pacakge files)
;; `consult-flycheck'            (Completing-read for flycheck)
;;   ==========================
(use-package flycheck
  :defer t
  :preface
  (defvar minions-prominent-modes)
  (defvar sh-shell)
  (defun user/setup-vale ()
    "If not setup, install the vale from the .ini file in dot-Emacs."
    (interactive)
    (let* ((vale-config (expand-file-name ".vale.ini" user-emacs-directory))
           (vale-install (expand-file-name ".vale-styles" user-emacs-directory))
           (command (format "vale --config %s sync >/dev/null" vale-config)))
      (unless (file-exists-p vale-install)
        (shell-command command))))

  (defun user/flycheck-shellcheck-setup-dash ()
    "Update `flycheck-shell-check-args' when `sh-shell' is dash."
    (when (and (eq major-mode 'sh) (eq sh-shell 'dash))
      (setq-local flycheck-shellcheck-args '("--shell=dash"))))

  :hook ((prog-mode text-mode) . flycheck-mode)
  :functions flycheck-select-checker flycheck-add-mode

  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-disabled-checkers
   '(emacs-lisp-elsa rpm-rpmlint yaml-jsyaml yaml-ruby))

  :config
  (add-to-list 'minions-prominent-modes 'flycheck-mode)
  (add-to-list 'flycheck-shellcheck-supported-shells 'dash)
  (flycheck-add-mode 'org-lint 'org-gtd-clarify-mode)
  (flycheck-add-mode 'yaml-yamllint 'docker-compose-mode)
  (add-hook 'sh-mode-hook #'user/flycheck-shellcheck-setup-dash)

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
                               (flycheck-select-checker 'org-lint))))

(use-package flyover
  :after (flycheck)
  :functions flyover-mode flyover-toggle flyover-flash-error-at-point
  :defines flyover-checkers
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
  (with-eval-after-load 'which-key)
  (which-key-add-keymap-based-replacements
    user/flyover-functions-map
    "m" "(De)Activate Flyover-Mode"
    "t" "Flyover Toggle"
    "p" "Flash Error @ Point")
  (keymap-global-set "C-c y" user/flyover-functions-map))

(use-package flycheck-color-mode-line
  :defer t
  :hook (flycheck-mode . flycheck-color-mode-line-mode))

(use-package flycheck-eask
  :defer t
  :hook (eask-mode . flycheck-eask-setup))

(use-package flycheck-package
  :defer t
  :hook (emacs-lisp-mode . flycheck-package-setup))

(use-package consult-flycheck
  :after (consult flycheck))


;;;; =======  EGLOT  =======
;;   ---------------------------  REQUIRED  ---------------------------
;; cmake:    'neocmakelsp'               (cargo install neocmakelsp)
;; fish:     'fish-lsp'                  (pnpm install -g fish-lsp)
;; lua:      'lua-language-server'       (pacman -S lua-language-server)
;; markdown: 'rumdl'                     (pacman -S rumdl)
;; python:   'rass' [`ty'/`ruff']        (uv tool install rass ty ruff)
;; toml:     'tombi'                     (pacman -S tombi)
;;   ---------------------------  OPTIONAL  ---------------------------
;; bash:    'bash-language-server'
;;          (pnpm i -g bash-language-server)
;; compose: 'docker-compose-langserver'
;;          (pnpm i -g @microsoft/container-language-service)
;; json:    'json-language-server'
;;          (pnpm i -g vscode-json-languageserver)
;; xml:     'lemminx'
;;          ((aur sync -c lemminx) OR (SEE github.com/eclipse-lemminx/lemminx))
;; yaml:    'yaml-language-server'
;;          (pnpm i -g yaml-language-server)
;;   -------------------------  INTEGRATIONS  --------------------------
;; `consult-eglot' `consult-eglot-embark' `flycheck-eglot' `lsp-snippet'
;;   ===================================================================
(use-package eglot
  :defer t
  :bind (:map ctl-x-map ("e" . eglot))
  
  :config
  (setq eglot-server-programs
        (cl-remove-if
         (lambda (cell)
           (cl-some
            (lambda (mode)
              (memq mode '(python-mode
                           python-ts-mode
                           markdown-mode
                           markdown-ts-mode)))
            (ensure-list (car cell))))
         eglot-server-programs))
  (let ((lsp-cons-cells
         '(((docker-compose-mode) .
            ("docker-compose-langserver" "--stdio"))
           ((fish-mode) .
            ("fish-lsp" "start"))
           ((lua-mode lua-ts-mode) .
            (expand-file-name "~/.luarocks/bin/lua-language-server"))
           ((markdown-mode markdown-ts-mode) .
            ("rumdl" "server"))
           ((nxml-mode) .
            ("lemminx"))
           ((python-mode python-ts-mode) .
            ("uv" "run" "rass" "python")))))
    (dolist (con lsp-cons-cells)
      (add-to-list 'eglot-server-programs con))))

(use-package consult-eglot
  :after (consult eglot)
  :commands (consult-eglot-symbols))

(use-package consult-eglot-embark
  :after (consult-eglot embark)
  :functions consult-eglot-embark-mode
  :config (consult-eglot-embark-mode 1))

(use-package flycheck-eglot
  :after (flycheck)
  :functions global-flycheck-eglot-mode
  :config
  (global-flycheck-eglot-mode 1))

(use-package lsp-snippet
  :ensure (:id lsp-snippet :type git :host github
               :depth treeless :protocol https :autoloads t
               :repo "svaante/lsp-snippet" :main "lsp-snippet.el" :build t
               :files ("Makefile" "*.el") :autoloads t)
  :after (:all eglot (:any tempel yasnippet))
  :config
  (with-eval-after-load 'tempel
    (require 'lsp-snippet-tempel)
    (lsp-snippet-tempel-eglot-init))
  (with-eval-after-load 'yasnippet
    (require 'lsp-snippet-yasnippet)
    (lsp-snippet-yasnippet-eglot-init)))


;;;; =======  FORMATTING  =======
;; bash:         'shfmt'         (pacman -S shfmt)
;; cmake:        'neocmakelsp'   (cargo install neocmakelsp)
;; fish:         'fish_indent'   (bundled with fish shell)
;; emacs-lisp:   'lisp-indent'   (built-in)
;; json:         'jq'            (pacman -S jq)
;; lua:          'stylua'        (pacman -S stylua)
;; markdown:     'rumdl'         (pacman -S rumdl)
;; python:       'ruff'          (uv tool install ruff)
;; toml:         'tombi'         (pacman -S tombi)
;; xml:          'xmlstarlet'    (pacman -S xmlstarlet)
;; yaml:         'yq-yqml'       (pacman -S yq-yaml)
;;   ============================
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

(use-package apheleia
  :defer t
  :bind ("C-c f" . apheleia-format-buffer)
  :hook ((prog-mode text-mode) . apheleia-mode)

  :config
  (when (or (equal major-mode 'bash-ts-mode)
            (equal major-mode 'sh-mode))
    (apheleia-mode -1))
  
  (setf (alist-get 'jq          apheleia-formatters)
        '("jq" "." "-M" "--indent" "2"))
  
  (setf (alist-get 'neocmakelsp apheleia-formatters)
        '("neocmakelsp" "format" (buffer-file-name)))

  (setf (alist-get 'prettier    apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  
  (setf (alist-get 'ruff        apheleia-formatters)
        '("ruff" "format" "-"))
  
  (setf (alist-get 'tombi       apheleia-formatters)
        '("tombi" "fmt" "-"))
  
  (setf (alist-get 'xmlstarlet  apheleia-formatters)
        '("xmlstarlet" "fo" "--indent-spaces" "2" "-"))

  (setf (alist-get 'yamlfmt     apheleia-formatters)
        '("yamlfmt" "--in"  "-"))

  (setf (alist-get 'cmake-mode          apheleia-mode-alist) 'neocmakelsp)
  (setf (alist-get 'cmake-ts-mode       apheleia-mode-alist) 'neocmakelsp)
  (setf (alist-get 'eask-mode           apheleia-mode-alist) 'lisp-indent)
  (setf (alist-get 'fish-mode           apheleia-mode-alist) 'fish-indent)
  (setf (alist-get 'json-mode           apheleia-mode-alist) 'jq)
  (setf (alist-get 'js-json-mode        apheleia-mode-alist) 'jq)
  (setf (alist-get 'json-ts-mode        apheleia-mode-alist) 'jq)
  (setf (alist-get 'markdown-mode       apheleia-mode-alist) 'rumdl)
  (setf (alist-get 'markdown-ts-mode    apheleia-mode-alist) 'rumdl)
  (setf (alist-get 'gfm-mode            apheleia-mode-alist) 'rumdl)
  (setf (alist-get 'python-mode         apheleia-mode-alist) 'ruff)
  (setf (alist-get 'python-ts-mode      apheleia-mode-alist) 'ruff)
  (setf (alist-get 'toml-ts-mode        apheleia-mode-alist) 'tombi)
  (setf (alist-get 'conf-toml-mode      apheleia-mode-alist) 'tombi)
  (setf (alist-get 'nxml-mode           apheleia-mode-alist) 'xmlstarlet)
  (setf (alist-get 'yaml-mode           apheleia-mode-alist) 'yamlfmt)
  (setf (alist-get 'yaml-ts-mode        apheleia-mode-alist) 'yamlfmt))


;;;; =======  FOLDING  =======
;; `hideshow'            (fold based on buffer-syntax)
;; `outline'             (fold based on headings)
;; `outline-indent'      (fold based on indentation)
;; `treesit-fold'        (fold based on treesit-language syntax)
;; `kirigami'            (consistent settings across backends)
;;   =========================
(use-package hideshow
  :ensure nil
  :defer t
  :hook
  ((c-mode
    c++-mode css-mode go-mode html-mode java-mode js-mode json-mode lua-mode
    nxml-mode perl-mode php-mode ruby-mode rust-mode sh-mode typescript-mode) . hs-minor-mode))

(use-package outline
  :ensure nil
  :defer t
  :hook
  ((conf-mode
    diff-mode emacs-lisp-mode lisp-interaction-mode lisp-mode markdown-mode) .
    outline-minor-mode))

(use-package outline-indent
  :defer t
  :hook
  ((python-mode python-ts-mode yaml-ts-mode) . outline-indent-minor-mode)
  :custom
  (outline-indent-ellipsis " ▼"))

(use-package treesit-fold
  :defer t
  :hook
  ((bash-ts-mode
    cmake-ts-mode csharp-ts-mode css-ts-mode c++-ts-mode c-ts-mode
    dockerfile-ts-mode go-mod-ts-mode go-ts-mode java-ts-mode json-ts-mode
    lua-ts-mode makefile-ts-mode markdown-ts-mode php-ts-mode ruby-ts-mode
    rust-ts-mode toml-ts-mode typescript-ts-mode xml-ts-mode) .
    treesit-fold-mode)
  :custom
  (treesit-fold-line-count-show t)
  (treesit-fold-line-count-format " ▼")
  :config
  (set-face-attribute
   'treesit-fold-replacement-face nil
   :foreground "#808080"
   :box nil
   :weight 'bold))

(use-package kirigami
  :defer t
  :hook
  ((bash-ts-mode
    cmake-ts-mode c++-mode c-mode conf-mode csharp-ts-mode css-mode css-ts-mode
    c++-ts-mode c-ts-mode diff-mode dockerfile-ts-mode emacs-lisp-mode go-mode
    go-mod-ts-mode go-ts-mode html-mode java-mode java-ts-mode js-mode
    json-mode json-ts-mode lisp-interaction-mode lisp-mode lua-mode lua-ts-mode
    makefile-ts-mode markdown-mode markdown-ts-mode nxml-mode perl-mode
    php-mode php-ts-mode python-base-mode ruby-mode ruby-ts-mode rust-mode
    rust-ts-mode sh-mode toml-ts-mode typescript-mode typescript-ts-mode
    xml-ts-mode yaml-ts-mode) . kirigami-mode)
  :functions
  kirigami-open-fold kirigami-open-fold-rec kirigami-open-folds
  kirigami-close-fold kirigami-close-folds kirigami-toggle-fold
  :config
  (defvar-keymap user/kirigami-functions
    :doc "Common code folding functions from `kirigami'."
    "o" #'kirigami-open-fold
    "O" #'kirigami-open-fold-rec
    "r" #'kirigami-open-folds
    "c" #'kirigami-close-fold
    "m" #'kirigami-close-folds
    "a" #'kirigami-toggle-fold)

  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      user/kirigami-functions
      "o" "Open Fold"
      "O" "Recursively Open Fold"
      "r" "Open Folds"
      "c" "Close Fold"
      "m" "Close Folds"
      "a" "Toggle Folds"))
  (keymap-global-set "C-c z" user/kirigami-functions))


;;;; =======  FLYSPELL  =======
;; `flyspell'                    (spellcheck)
;; `flyspell-correct'            (correct w/ flyspell...)
;; `flyspell-correct-avy-menu'   (... and your favorite interface)
;;   ==========================
(declare-function embark-act "embark")
(use-package flyspell
  :ensure nil
  :defer t
  :hook ((prog-mode conf-mode text-mode) . flyspell-mode)
  :config
  (keymap-unset flyspell-mode-map "C-.")
  (keymap-global-set "C-." #'embark-act))

(use-package flyspell-correct
  :after flyspell
  :bind (:map flyspell-mode-map
              ("C-&" . flyspell-correct-wrapper)))

(use-package flyspell-correct-avy-menu
  :after (flyspell-correct avy))


(provide '08-code-assist)
;;; 08-code-assist.el ends here

                                        ; LocalWords:  hs
