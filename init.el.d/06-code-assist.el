;;; 06-code-assist.el --- Linting, formatting, & LSPs -*- lexical-binding: t; -*-

;;; Packages included:
;; adaptive-wrap, apheleia, dap-mode, flycheck, flycheck-color-mode-line,
;; flyover, lsp-mode, lsp-treemacs, lsp-ui, smartparens, yasnippet,
;; yasnippet-capf, yasnippet-snippets

;;; Commentary:
;; Call packages that support efficient & productive coding at a global scope.
;; The packages called in this file help to make Emacs feel like a typical IDE.

;;; Code:
;; =======  TEXT MANIPULATION  =======
;; `smartparens' (auto-close "", {}, [], ())
;; `adaptive-wrap' (smart text wrapping)
;; `docstr' (composing/formatting DocStrings)
;; ===================================
(use-package smartparens
  :hook
  ((prog-mode . smartparens-mode)
   (text-mode . smartparens-mode))
  :config
  (require 'smartparens-config))

(use-package adaptive-wrap
  :hook
  ((prog-mode . adaptive-wrap-prefix-mode)
   (text-mode . adaptive-wrap-prefix-mode)))

(use-package docstr
  :functions
  docstr-major-modes
  docstr-mode
  user/docstr-mode-hooks
  :config

  (defun user/docstr-mode-hooks ()

    "Trigger `docstr-mode' for major modes in which it is available.
Run docstr-major-modes for an up-to-date list of modes in which docstr works.
For each mode on that list, add `docstr-mode' to its hook."
    
    (dolist (mode (docstr-major-modes))
      (add-hook (intern (concat (symbol-name mode) "-hook"))
		#'docstr-mode)))
  
  (user/docstr-mode-hooks))


;; =======  FLYCHECK  =======
;; bash: 'shellcheck' (pacman -S shellcheck)*
;; emacs-lisp: 'emacs-lisp' (built-in)
;; json: 'jsonlint' (npm install -g jsonlint)*
;; markdown: 'rumdl' (pacman -S rumdl)*
;; xml: 'xmllint' (pacman -S libxml2)
;; yaml: 'yamllint' (pacman -S yamllint)*
;; --------------------------
;; Extensions:
;; `flyover' (appear inline)
;; `flycheck-color-mode-line'
;; ==========================
(use-package flycheck
  :hook
  ((prog-mode . flycheck-mode)
   (text-mode . flycheck-mode))

  :functions flycheck-select-checker

  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-disabled-checkers
   '(emacs-lisp-elsa lua-luacheck lua sh-bash yaml-jsyaml yaml-ruby))

  :config
  (flycheck-define-checker fish-self
    "The shell for the 90's built-in syntax checker."
    :command ("fish" "-n" source)
    :error-patterns
    ((error line-start (file-name) " (line " line "): " (message) line-end))
    :modes (fish-mode))
  (add-to-list 'flycheck-checkers 'fish-self)
  (add-hook 'fish-mode-hook (lambda ()
			      (flycheck-select-checker 'fish-self)))

  (flycheck-define-checker lua-selene
    "Write correct & idiomatic lua code."
    :command ("selene" "--quiet" "-" source )
    :error-patterns
    ((error line-start
            (file-name) ":" line ":" column ": "
            (or "error" "warning" "info")
            "[" (id (one-or-more (not (any "]")))) "]: "
            (message)
            line-end))
    :modes (lua-ts-mode))
  (add-to-list 'flycheck-checkers 'lua-selene)
  (add-hook 'lua-ts-mode-hook (lambda ()
                                (flycheck-select-checker 'lua-selene)))
  
  (flycheck-define-checker markdown-rumdl
    "A fast Markdown linter written in Rust.
See URL `https://github.com/rvben/rumdl'."
    :command ("rumdl" "check" "--watch" "--stdin" source)
    :error-patterns
    ((error line-start (file-name)
	    ":" line ":" column ": "
	    (id (one-or-more (not (any " ")))) " " (message) line-end))
    :modes (markdown-mode gfm-mode))
  (add-to-list 'flycheck-checkers 'markdown-rumdl)
  (add-hook 'markdown-mode-hook (lambda ()
                                  (flycheck-select-checker 'markdown-rumdl))))

(defun user/no-flyover-if-lsp ()
  "If `lsp-mode' is not nil, disable `flyover-mode'."
  (if (fboundp 'lsp-mode)
      (flyover-mode -1)
    (flyover-mode 1)))

(use-package flyover
  :after flycheck
  :commands flyover-mode
  :hook (flycheck-mode . user/no-flyover-if-lsp)
  :functions flyover-toggle
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
  (flyover-line-position-offset 1)
  (flyover-wrap-messages t)
  (flyover-max-line-length 80)
  (flyover-debounce-interval 0.1)
  (flyover-cursor-debounce-interval 0.2)
  (flyover-display-mode 'hide-on-same-line)
  (flyover-hide-during-completion t)
  :config

  (bind-keys
   :map flycheck-mode-map
   ("C-c M-f" . flyover-toggle)))

(use-package flycheck-color-mode-line
  :after flycheck
  :hook (flycheck-mode . (lambda ()
			   flycheck-color-mode-line-mode 1)))


;; =======  LSP-MODE  =======
;; cmake: 'neocmakelsp' (cargo install neocmakelsp)*
;; fish: 'fish-lsp' (npm install -g fish-lsp)*
;; markdown: 'rumdl' (pacman -S rumdl)*
;; python: 'ty' (uv tool install ty)*
;; python: 'ruff' (uv tool install ruff)*
;; toml: 'tombi' (uv tool install tombi)*
;; -------  OPTIONAL  -------
;; [OPTIONAL] bash: 'bash-language-server' (pacman -S bash-language-server)*
;; [OPTIONAL] json: 'json-language-server' (pacman -S json-language-server)*
;; [OPTIONAL] lua: `lua-language-server'*
;; [OPTIONAL] xml: 'lemminx'*
;; [OPTIONAL] yaml: 'yaml-language-server' (pacman -S yaml-language-server)*
;; ==========================
(use-package lsp-mode
  :hook
  ((cmake-ts-mode  . lsp-deferred)
   (markdown-mode  . lsp-deferred)
   (python-ts-mode . lsp-deferred)
   (toml-ts-mode   . lsp-deferred))
  :bind (:map prog-mode-map
	      ("C-c C-l" . lsp))
  :functions
  lsp-mode
  lsp-register-client
  make-lsp--client
  lsp-stdio-connection
  lsp-format-buffer
  lsp-enable-which-key-integration
  :defines lsp-language-id-configuration
  :custom
  (lsp-use-plists t)
  (lsp-idle-delay 0.8)
  (lsp-log-io nil)
  (lsp-enable-file-watchers nil)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-auto-guess-root t)
  (lsp-enable-on-type-formatting nil)
  (lsp-disabled-clients
   '(cmake-language-server
     marksman
     pylsp
     pyright
     taplo))
  :config
  (lsp-register-client
   (make-lsp--client
    :new-connection (lsp-stdio-connection '("neocmakelsp" "stdio"))
    :major-modes '(cmake-ts-mode)
    :server-id 'neocmakelsp))
  (add-to-list 'lsp-language-id-configuration '(fish-mode . "fish"))
  (lsp-register-client
   (make-lsp--client
    :new-connection (lsp-stdio-connection '("fish-lsp" "start"))
    :major-modes '(fish-mode)
    :server-id 'fish-ls))
  (lsp-register-client
   (make-lsp--client
    :new-connection (lsp-stdio-connection '("rumdl" "server" "--stdio"))
    :major-modes '(markdown-mode gfm-mode)
    :server-id 'rumdl-ls))
  (lsp-register-client
   (make-lsp--client
    :new-connection (lsp-stdio-connection '("tombi" "lsp"))
    :major-modes '(toml-ts-mode)
    :server-id 'tombi-ls))

  (add-hook 'lsp-mode-hook
	    (lambda () (flyover-mode -1)))
  
  (bind-keys
   :map lsp-mode-map
   ("C-c F" . lsp-format-buffer))
  (dolist (dir '("[/\\\\]node_modules\\'"
                 "[/\\\\]\\.git\\'"
                 "[/\\\\]dist\\'"
                 "[/\\\\]build\\'"
                 "[/\\\\]target\\'"
                 "[/\\\\]\\.direnv\\'"
                 "[/\\\\]\\.cache\\'"
                 "[/\\\\]vendor\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories dir))
  (add-hook 'fish-mode-hook
            (lambda ()
	      (setq-local lsp-enable-file-watchers nil))))

(use-package lsp-ui
  :after lsp-mode
  :config)

(use-package lsp-treemacs
  :after (lsp-mode treemacs))


;; =======  FORMATTING  =======
;; bash: 'shfmt' (pacman -S shfmt)*
;; cmake: 'neocmakelsp' (cargo install neocmakelsp)*
;; fish: 'fish_indent' (bundled with fish shell)
;; emacs-lisp: 'indent' (built-in)
;; json: 'prettier'* (npm install --save-dev --save-exact prettier)*
;; lua: `stylua'*
;; markdown: 'rumdl'* (pacman -S rumdl)*
;; python: 'ruff' (uv tool install ruff)*
;; toml: 'tombi' (pacman -S tombi)*
;; xml: 'xmlstarlet' (pacman -S xmlstarlet)
;; yaml: 'prettier'* (npm install --save-dev --save-exact prettier)*
;; ============================
(use-package apheleia
  :bind ("C-c f" . apheleia-format-buffer)
  :hook
  ((prog-mode . apheleia-mode)
   (markdown-mode . apheleia-mode))
  :config
  (setf (alist-get 'shfmt apheleia-formatters)
	'("shfmt" "-i" "4" "-ci" "-"))
  (setf (alist-get 'neocmakelsp apheleia-formatters)
        '("neocmakelsp" "format" "-"))
  (setf (alist-get 'prettier-json apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath "--parser=json"
          (apheleia-formatters-js-indent "--use-tabs" "--tab-width")))
  (setf (alist-get 'prettier-yaml apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath "--parser=yaml"
          (apheleia-formatters-js-indent "--use-tabs" "--tab-width")))
  (setf (alist-get 'ruff apheleia-formatters)
        '("ruff" "format" "-"))
  (setf (alist-get 'rumdl apheleia-formatters)
	'("rumdl" "fmt" "--stdin" "-"))
  (setf (alist-get 'tombi apheleia-formatters)
        '("tombi" "fmt" "-"))
  (setf (alist-get 'xmlstarlet apheleia-formatters)
        '("xmlstarlet" "fo" "--indent-spaces" "2" "-"))
  (setf (alist-get 'cmake-ts-mode apheleia-mode-alist) 'neocmakelsp)
  (setf (alist-get 'eask-mode apheleia-mode-alist) 'lisp-indent)
  (setf (alist-get 'fish-mode apheleia-mode-alist) 'fish-indent)
  (setf (alist-get 'markdown-mode apheleia-mode-alist) 'rumdl)
  (setf (alist-get 'gfm-mode apheleia-mode-alist) 'rumdl)
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff)
  (setf (alist-get 'toml-ts-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'conf-toml-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'nxml-mode apheleia-mode-alist) 'xmlstarlet))


;; =======  DAP-MODE  =======
;; python: 'debugpy' (uv tool install debugpy)*
;; ==========================
(use-package dap-mode
  :defer t
  :commands
  dap-debug
  dap-debug-edit-template
  dap-auto-configure-mode
  :defines dap-python-debugger
  :custom
  (dap-auto-configure-features '(sessions locals controls tooltip))
  (dap-lldb-debug-program "/usr/bin/lldb-dap")
  :config
  (require 'dap-python)
  (setq dap-python-debugger 'debugpy))


;; =======  SNIPPETS  =======
;; 'yasnippet' (functions)
;; 'yasnippet-snippets' (library)
;; 'yasnippet-capf' (completions)
;; ==========================
(use-package yasnippet
  :hook
  ((prog-mode . yas-minor-mode)
   (markdown-mode . yas-minor-mode))
  yas-reload-all
  :config
  (add-to-list 'yas-snippet-dirs
	       (expand-file-name "snippets" user-emacs-directory)))

(use-package yasnippet-snippets
  :after yasnippet
  :functions yasnippet-snippets-initialize
  :init
  (yasnippet-snippets-initialize))

(use-package yasnippet-capf
  :after (yasnippet cape)
  :functions yasnippet-capf
  :config
  (add-to-list 'completion-at-point-functions #'yasnippet-capf))


;; =======  MASON  =======
;; `mason' (install external deps)
;; =======================
(use-package mason
  :commands
  mason-install
  mason-manager
  mason-setup
  :functions
  mason-installed-p
  user/mason--install-program
  user/mason-install-optional-program
  user/mason-install-optional-programs
  :defines mason-dir

  :init
  (setq mason-dir (expand-file-name "~/.local"))

  :config
  (mason-setup)
  
  ;; Variables
  (defvar user/required-mason-programs
    '("debugpy" "fish-lsp" "jsonlint" "lua-language-server" "neocmakelsp"
      "prettier" "ruff" "rumdl" "selene" "shellcheck" "shfmt" "stylua" "tombi"
      "ty" "yamllint")
    "List of programs required in this setup that mason is able to install.")
  
  (defvar user/optional-mason-programs
    '("bash-language-server" "json-language-server" "lemminx" "systemdlsp"
      "systemdlint" "textlint" "textlsp" "yaml-language-server")
    "List of optional programs in this setup that mason is able to install.")

  ;; Functions
  (defun user/mason--install-program (program)
    "Checks installation status of PROGRAM. If PROGRAM is not installed,
mason installs it."
    (condition-case err
        (if (mason-installed-p program)
            (message "%s is already installed." program)
          (message "Installing %s ..." program)
          (mason-install program))
      (error
       (message "Mason failed to install %s: %s"
                program (error-message-string err)))))

  (defun user/mason-install-program (program)
    "Use mason to install a PROGRAM.
 Installation options come from the lists
 \"user/required-mason-programs\" & \"user/optional-mason-programs\"."
    (interactive
     (list (completing-read "Select program: "
			    (append user/required-mason-programs
				    user/optional-mason-programs) nil t)))
    (user/mason--install-program program))

  (defun user/mason-install-required-programs ()
    "Leverages mason to install required programs if not installed."
    (interactive)
    (dolist (program user/required-mason-programs)
      (user/mason--install-program program)))
  
  (defun user/mason-install-optional-programs ()
    "Use mason to install all optional programs."
    (interactive)
    (dolist (program user/optional-mason-programs)
      (user/mason--install-program program)))

  (defvar user/mason--dispatch nil)
  (declare-function mason-setup "mason")
  (transient-define-prefix
    user/mason--dispatch ()
    "Commands to install external dependencies with `mason'."
    [
     ["Mason - Install external
deps for flycheck & lsp-mode"]
     [("r" "Install required" user/mason-install-required-programs)
      ("o" "Install optional" user/mason-install-optional-programs)]
     [("p" "Install program" user/mason-install-program)
      ("m" "Mason Manager" mason-manager)]]))

(declare-function transient-define-prefix "transient")

(declare-function user/mason--dispatch "06-code-assist")
(defun user/mason-dispatch ()
  "Load mason if not loaded then run user/mason--dispatch."
  (interactive)
  (if (featurep 'mason)
      (user/mason--dispatch)
    (progn
      (mason-setup)
      (user/mason--dispatch))))
(bind-keys ("C-c m" . user/mason-dispatch))


(provide '06-code-assist)
;;; 06-code-assist.el ends here
