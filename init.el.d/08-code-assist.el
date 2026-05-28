;;; 08-code-assist.el --- Linting, formatting, & LSPs -*- lexical-binding: t; -*-

;;; Packages included:
;; adaptive-wrap, apheleia, comment-dwim-2, dap-mode, docstr, flycheck,
;; flycheck-color-mode-line, flycheck-eask, flycheck-inline, flycheck-package,
;; lsp-mode, lsp-treemacs, mason, smartparens, visual-regexp,
;; visual-regexp-steroids, yasnippet, yasnippet-capf, yasnippet-snippets

;;; Commentary:
;; Call packages that support efficient & productive coding at a global scope.
;; The packages called in this file help to make Emacs feel like a typical IDE.

;;; Code:
;; =======  TEXT MANIPULATION  =======
;; `visual-regexp' (hl regexp as you type)
;; `visual-regexp-steroids' (use python-style regexp instead of Emacs)
;; `smartparens' (auto-close "", {}, [], ())
;; `adaptive-wrap' (smart text wrapping)
;; `docstr' (composing/formatting DocStrings)
;; `comment-dwim-2' (easily switch between no-comment, comment, EOL comment)
;; ===================================
(use-package visual-regexp
  :bind
  (("C-c r" . vr/replace)
   ("C-c q" . vr/query-replace)))

(use-package visual-regexp-steroids
  :functions
  vr/isearch-forward vr/isearch-backward
  :after visual-regexp
  :config
  (bind-keys
   ([remap isearch-forward-regexp]  . vr/isearch-forward)
   ([remap isearch-backward-regexp] . vr/isearch-backward)))

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

(use-package comment-dwim-2
  :bind
  ([remap comment-dwim] . comment-dwim-2))


;; =======  FLYCHECK  =======
;; bash: 'shellcheck' (pacman -S shellcheck)
;; emacs-lisp: 'emacs-lisp' (built-in)
;; json: 'jsonlint' (npm install -g jsonlint)
;; lua: 'luacheck' (pacman -S luacheck)
;; markdown: 'rumdl' (pacman -S rumdl)
;; toml: 'tombi' (uv tool install tombi)
;; xml: 'xmllint' (pacman -S libxml2)
;; yaml: 'yamllint' (pacman -S yamllint)
;; --------------------------
;; Extensions:
;; `flycheck-inline' (display errors in buffer)
;; `flycheck-color-mode-line'
;; `flycheck-eask' (Support Eask files)
;; `flycheck-package' (Support Emacs' pacakges)
;; ==========================
(use-package flycheck
  :hook
  ((prog-mode . flycheck-mode)
   (text-mode . flycheck-mode))
  :functions flycheck-select-checker flycheck-add-mode

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
    :modes (markdown-ts-mode markdown-mode gfm-mode))
  (add-to-list 'flycheck-checkers 'markdown-rumdl)

  (let* ((vale-config (expand-file-name ".vale.ini" user-emacs-directory))
	 (vale-install (expand-file-name ".vale-styles" user-emacs-directory))
	 (command (format "vale --config %s sync >/dev/null" vale-config)))
    (unless (file-exists-p vale-install)
      (shell-command command)))

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
  (add-to-list 'flycheck-checkers 'text-vale)

  (flycheck-add-mode 'org-lint 'org-gtd-clarify-mode)

  (let ((flycheck-modes-alist
	 '((fish-mode        . fish-self)
	   (markdown-mode    . markdown-rumdl)
	   (gfm-mode         . markdown-rumdl)
	   (markdown-ts-mode . markdown-rumdl)
	   (org-mode         . org-lint))))
    (dolist (mode (mapcar #'car flycheck-modes-alist))
      (let ((hook (intern (concat (symbol-name mode) "-hook")))
	    (checker (cdr (assoc mode flycheck-modes-alist))))
	(add-hook hook (lambda ()
			 (flycheck-select-checker checker)))))))

(use-package flycheck-inline
  :defer t
  :hook (flycheck-mode . flycheck-inline-mode))

(use-package flycheck-color-mode-line
  :defer t
  :hook (flycheck-mode . flycheck-color-mode-line-mode))

(use-package flycheck-eask
  :defer t
  :hook (eask-mode . flycheck-eask-setup))

(use-package flycheck-package
  :defer t
  :hook (emacs-lisp-mode . flycheck-package-setup))


;; =======  LSP-MODE  =======
;; cmake: 'neocmakelsp' (cargo install neocmakelsp)
;; fish: 'fish-lsp' (npm install -g fish-lsp)
;; lua: 'lua-language-server' (pacman -S lua-language-server)
;; markdown: 'rumdl' (pacman -S rumdl)
;; python: 'ty' (uv tool install ty)
;; python: 'ruff' (uv tool install ruff)
;; -------  OPTIONAL  -------
;; [OPTIONAL] bash: 'bash-language-server' (pacman -S bash-language-server)
;; [OPTIONAL] json: 'json-language-server' (pacman -S json-language-server)
;; [OPTIONAL] toml: 'tombi' (uv tool install tombi)
;; [OPTIONAL] xml: 'lemminx'
;; [OPTIONAL] yaml: 'yaml-language-server' (pacman -S yaml-language-server)
;; ------  EXTENSIONS  ------
;; `lsp-treemacs' (treemacs integration)
;; `dap-mode' (debug protocol)
;; -- Requires 'debugpy': (uv tool install debugpy)
;; ==========================
(use-package lsp-mode
  :hook
  ((cmake-ts-mode  . lsp-deferred)
   (fish-mode      . lsp-deferred)
   (lua-ts-mode    . lsp-deferred)
   (markdown-mode  . lsp-deferred)
   (python-ts-mode . lsp-deferred)
   (rustic-mode    . lsp-deferred)
   (toml-ts-mode   . lsp-deferred))
  :bind ("C-c C-l" . lsp)
  :functions
  lsp-mode lsp-register-client make-lsp--client lsp-stdio-connection
  lsp-format-buffer lsp-enable-which-key-integration
  :defines lsp-language-id-configuration

  :custom
  (lsp-auto-guess-root t)
  (lsp-disabled-clients
   '(cmake-language-server marksman pylsp pyright semgrep-ls taplo))
  (lsp-enable-file-watchers nil)
  (lsp-enable-on-type-formatting nil)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-idle-delay 0.8)
  (lsp-log-io nil)
  (lsp-lua-runtime-version "LuaJIT")
  (lsp-lua-diagnostics-globals ["mp"])
  (lsp-rust-analyzer-cargo-watch-command "cargo-clippy")
  (lsp-rust-server 'rust-analyzer)
  (lsp-use-plists t)
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
    :major-modes '(markdown-mode gfm-mode markdown-ts-mode)
    :server-id 'rumdl-ls))

  (lsp-register-client
   (make-lsp--client
    :new-connection (lsp-stdio-connection '("tombi" "lsp"))
    :major-modes '(toml-mode toml-ts-mode)
    :server-id 'tombi-ls))
  
  (bind-keys
   :map lsp-mode-map
   ("C-c F" . lsp-format-buffer))
  (dolist (dir '("[/\\\\]node_modules\\'" "[/\\\\]\\.git\\'" "[/\\\\]dist\\'"
                 "[/\\\\]build\\'" "[/\\\\]target\\'" "[/\\\\]\\.direnv\\'"
                 "[/\\\\]\\.cache\\'" "[/\\\\]vendor\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories dir))
  (add-hook 'fish-mode-hook
            (lambda ()
	      (setq-local lsp-enable-file-watchers nil))))

(use-package lsp-treemacs
  :after lsp-mode)

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


;; =======  FORMATTING  =======
;; bash: 'shfmt' (pacman -S shfmt)
;; cmake: 'neocmakelsp' (cargo install neocmakelsp)
;; fish: 'fish_indent' (bundled with fish shell)
;; emacs-lisp: 'lisp-indent' (built-in)
;; json: 'jq' (pacman -S jq)
;; lua: `stylua'
;; markdown: 'rumdl' (pacman -S rumdl)
;; python: 'ruff' (uv tool install ruff)
;; toml: 'tombi' (pacman -S tombi)
;; xml: 'xmlstarlet' (pacman -S xmlstarlet)
;; yaml: 'yq-yqml' (pacman -S yq-yaml)
;; ============================
(use-package apheleia
  :bind ("C-c f" . apheleia-format-buffer)
  :hook
  ((prog-mode . apheleia-mode)
   (text-mode . apheleia-mode))

  :config
  (when (or (equal major-mode 'rustic-mode)
	    (equal major-mode 'sh-mode))
    (apheleia-mode -1))
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
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) 'jq)
  (setf (alist-get 'markdown-mode apheleia-mode-alist) 'rumdl)
  (setf (alist-get 'gfm-mode apheleia-mode-alist) 'rumdl)
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff)
  (setf (alist-get 'toml-ts-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'conf-toml-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'nxml-mode apheleia-mode-alist) 'xmlstarlet)
  (setf (alist-get 'yaml-ts-mode apheleia-mode-alist) 'yq-yaml))


;; =======  SNIPPETS  =======
;; 'yasnippet' (functions)
;; 'yasnippet-snippets' (library)
;; 'yasnippet-capf' (completions)
;; ==========================
(use-package yasnippet
  :hook
  ((prog-mode . yas-minor-mode)
   (text-mode . yas-minor-mode))
  :functions yas-reload-all
  :config
  (add-to-list 'yas-snippet-dirs
	       (expand-file-name "snippets" user-emacs-directory))
  (yas-reload-all))

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

(use-package tempel
  :defer t
  :preface
  (defun user/tempel-setup-capf ()
    "Locally add relevant tempel items to `completion-at-point-functions'."
    (setq-local completion-at-point-functions
		(cons #'tempel-complete completion-at-point-functions)))
  :bind
  (("M-+" . tempel-complete)
   ("M-*" . tempel-insert))
  :hook
  (((text-mode prog-mode) . tempel-abbrev-mode)
   ((text-mode prog-mode) . user/tempel-setup-capf))
  :functions tempel-complete)


(provide '08-code-assist)
;;; 08-code-assist.el ends here
