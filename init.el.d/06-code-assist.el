;;; 06-code-assist.el --- Linting, formatting, & LSPs -*- lexical-binding: t; -*-

;;; Packages included:
;; adaptive-wrap, apheleia, dap-mode, docstr, flycheck, flycheck-color-mode-line,
;; flycheck-pos-tip, lsp-mode, lsp-treemacs, lsp-ui, mason, smartparens,
;; yasnippet, yasnippet-capf, yasnippet-snippets

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
  docstr-major-modes docstr-mode user/docstr-mode-hooks
  :config
  (dolist (mode (docstr-major-modes))
    (add-hook (intern (concat (symbol-name mode) "-hook"))
	      #'docstr-mode)))


;; =======  FLYCHECK  =======
;; bash: 'shellcheck' (pacman -S shellcheck)*
;; emacs-lisp: 'emacs-lisp' (built-in)
;; json: 'jsonlint' (npm install -g jsonlint)*
;; lua: 'luacheck' (pacman -S luacheck)*
;; markdown: 'rumdl' (pacman -S rumdl)*
;; toml: 'tombi' (uv tool install tombi)*
;; xml: 'xmllint' (pacman -S libxml2)
;; yaml: 'yamllint' (pacman -S yamllint)*
;; --------------------------
;; Extensions:
;; `flycheck-pos-tip' (popup flycheck errors)
;; `flycheck-color-mode-line'
;; ==========================
(use-package flycheck
  :hook
  ((prog-mode     . flycheck-mode)
   (markdown-mode . flycheck-mode)
   (org-mode      . flycheck-mode))

  :functions flycheck-select-checker

  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-disabled-checkers
   '(emacs-lisp-elsa sh-bash yaml-jsyaml yaml-ruby))

  :config
  (flycheck-define-checker fish-self
    "The shell for the 90's built-in syntax checker.
See URL `https://fishshell.com'."
    :command ("fish" "-n" source)
    :error-patterns
    ((error line-start (file-name) " (line " line "): " (message) line-end))
    :modes (fish-mode))
  (add-to-list 'flycheck-checkers 'fish-self)
  
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

  (flycheck-define-checker tombi-lint
    "A powerful toolkit to help you maintain clean and consistent TOML files.
See URL `https://tombi-toml.github.io/tombi'."
    :command ("tombi" "lint" "--quiet" "-" source)
    :error-patterns
    ((error line-start
	    "Error: " (message)
	    "\n"
	    (+ blank) "at " (file-name) ":" line ":" column line-end)
     (warning line-start
	      "Warning: " (message)
	      "\n"
	      (+ blank) "at " (file-name) ":" line ":" column line-end))
    :modes (toml-mode toml-ts-mode))
  (add-to-list 'flycheck-checkers 'tombi-lint)

  (let* ((vale-config (expand-file-name ".vale.ini" user-emacs-directory))
	 (vale-install (expand-file-name ".vale-styles" user-emacs-directory))
	 (command (format "vale --config %s sync >/dev/null" vale-config)))
    (unless (file-exists-p vale-install)
      (shell-command command)))

  (flycheck-define-checker text-vale
    "Tool to bring code-like linting to prose.
See URL `https://vale.sh'."
    :command
    ("vale" "--config" (eval (expand-file-name ".vale.ini" user-emacs-directory))
     "--no-global" "--output" "line" source)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ":"
              (id (one-or-more (not (any ":")))) ":" (message) line-end))
    :modes (markdown-mode gfm-mode text-mode org-mode org-gtd-clarify-mode
			  flycheck-error-message-mode))
  (add-to-list 'flycheck-checkers 'text-vale)


  (let ((flycheck-modes-alist
	 '((fish-mode     . fish-self)
	   (markdown-mode . markdown-rumdl)
	   (gfm-mode      . markdown-rumdl)
	   (toml-ts-mode  . tombi-lint)
	   (org-mode      . org-lint))))
    (dolist (mode (mapcar #'car flycheck-modes-alist))
      (let ((hook (intern (concat (symbol-name mode) "-hook")))
	    (checker (cdr (assoc mode flycheck-modes-alist))))
	(add-hook hook (lambda ()
			 (flycheck-select-checker checker)))))))

(use-package flycheck-pos-tip
  :after flycheck
  :functions flycheck-pos-tip-mode
  :config
  (flycheck-pos-tip-mode 1))

(use-package flycheck-color-mode-line
  :after flycheck
  :hook (flycheck-mode . flycheck-color-mode-line-mode))


;; =======  LSP-MODE  =======
;; cmake: 'neocmakelsp' (cargo install neocmakelsp)*
;; fish: 'fish-lsp' (npm install -g fish-lsp)*
;; markdown: 'rumdl' (pacman -S rumdl)*
;; python: 'ty' (uv tool install ty)*
;; python: 'ruff' (uv tool install ruff)*
;; -------  OPTIONAL  -------
;; [OPTIONAL] bash: 'bash-language-server' (pacman -S bash-language-server)*
;; [OPTIONAL] json: 'json-language-server' (pacman -S json-language-server)*
;; [OPTIONAL] lua: `lua-language-server'*
;; [OPTIONAL] toml: 'tombi' (uv tool install tombi)*
;; [OPTIONAL] xml: 'lemminx'*
;; [OPTIONAL] yaml: 'yaml-language-server' (pacman -S yaml-language-server)*
;; ==========================
(use-package lsp-mode
  :hook
  ((cmake-ts-mode  . lsp-deferred)
   (markdown-mode  . lsp-deferred)
   (python-ts-mode . lsp-deferred)
   (toml-ts-mode   . lsp-deferred))
  :bind ("C-c C-l" . lsp)
  :functions
  lsp-mode lsp-register-client make-lsp--client lsp-stdio-connection
  lsp-format-buffer lsp-enable-which-key-integration
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
   '(cmake-language-server marksman pylsp pyright taplo))
  
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
    :major-modes '(toml-mode toml-ts-mode)
    :server-id 'tombi-ls))
  
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
  :after lsp-mode)

(use-package lsp-treemacs
  :after (lsp-mode treemacs))


;; =======  FORMATTING  =======
;; bash: 'shfmt' (pacman -S shfmt)*
;; cmake: 'neocmakelsp' (cargo install neocmakelsp)*
;; fish: 'fish_indent' (bundled with fish shell)
;; emacs-lisp: 'lisp-indent' (built-in)
;; json: 'jq' (pacman -S jq)
;; lua: `stylua'*
;; markdown: 'rumdl'* (pacman -S rumdl)*
;; python: 'ruff' (uv tool install ruff)*
;; toml: 'tombi' (pacman -S tombi)*
;; xml: 'xmlstarlet' (pacman -S xmlstarlet)
;; yaml: 'yq-yqml' (pacman -S yq-yaml)
;; ============================
(use-package apheleia
  :bind ("C-c f" . apheleia-format-buffer)
  :hook
  ((prog-mode     . apheleia-mode)
   (markdown-mode . apheleia-mode)
   (org-mode      . apheleia-mode))

  :config
  (setf (alist-get 'shfmt apheleia-formatters)
	'("shfmt" "-i" "4" "-ci" "-"))
  (setf (alist-get 'neocmakelsp apheleia-formatters)
        '("neocmakelsp" "format" (buffer-file-name)))
  (setf (alist-get 'jq apheleia-formatters)
	'("jq" "." "-M" "--indent" "2"))
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
  (setf (alist-get 'json-mode apheleia-mode-alist) 'jq)
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) 'jq)
  (setf (alist-get 'markdown-mode apheleia-mode-alist) 'rumdl)
  (setf (alist-get 'gfm-mode apheleia-mode-alist) 'rumdl)
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff)
  (setf (alist-get 'toml-ts-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'conf-toml-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'nxml-mode apheleia-mode-alist) 'xmlstarlet)
  (setf (alist-get 'yaml-mode apheleia-mode-alist) 'yq-yaml)
  (setf (alist-get 'yaml-ts-mode apheleia-mode-alist) 'yq-yaml))


;; =======  DAP-MODE  =======
;; python: 'debugpy' (uv tool install debugpy)*
;; ==========================
(use-package dap-mode
  :defer t
  :commands
  dap-debug dap-debug-edit-template dap-auto-configure-mode
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
(declare-function transient-define-prefix "transient")
(use-package mason
  :commands
  mason-install mason-manager mason-setup
  :functions
  mason-ensure mason-installed-p user/mason--install-program
  user/mason-install-optional-program user/mason-install-optional-programs
  user/mason-dispatch
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
  (transient-define-prefix
    user/mason--dispatch ()
    "Commands to install external dependencies with `mason'."
    [
     ["Mason - Install external deps for flycheck & lsp-mode"]
     [("r" "Install required" user/mason-install-required-programs)
      ("o" "Install optional" user/mason-install-optional-programs)]
     [("p" "Install program" user/mason-install-program)
      ("m" "Mason Manager" mason-manager)]
     ])

  (declare-function user/mason--dispatch "06-code-assist")
  (defun user/mason-dispatch ()
    "Load mason if not loaded then run user/mason--dispatch."
    (interactive)
    (if (featurep 'mason)
	(user/mason--dispatch)
      (progn
	(mason-setup)
	(user/mason--dispatch))))
  (bind-keys ("C-c m" . user/mason-dispatch)))


(provide '06-code-assist)
;;; 06-code-assist.el ends here
