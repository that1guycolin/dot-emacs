;;; language-specific-configs.el --- Language Support -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for language-specific modes.  Shared packages (treesit,
;; flycheck, lsp-mode, dap-mode, apheleia) are configured first, followed
;; by language-specific settings in alphabetical order.
;;
;; Languages: Bash, Cmake,  Emacs-Lisp, Fish, JSON, Lisp, Markdown, Python, TOML,
;; XML, YAML

;;; Packages included:
;; adjust-parens, apheleia, auto-rename-tag, auto-virtualenv, bash, cmake-mode,
;; dap-mode, eask-mode, elisp-def, emacs-lisp-mode, fish-mode, flycheck,
;; flycheck-color-mode-line, flycheck-eask, flyover, grip-mode, ielm, json-mode,
;; lisp-mode, lisp-semantic-hl, live-py-mode, lsp-mode, lsp-treemacs, lsp-ui,
;; markdown-mode, markdown-toc, mason, modern-sh, nxml-mode, python, python-x,
;; slime, suggest, toml, treesit, treesit-auto, uv-mode, yaml, yaml-pro,
;; yasnippet, yasnippet-capf, yasnippet-snippets

;;; Code:
;; =======  TREESIT  =======
(defvar treesit-language-source-alist nil
  "List of online treesitter repositories for various languages.")

(use-package treesit
  :ensure nil
  :config
  (setq treesit-language-source-alist
	'((bash "https://github.com/tree-sitter/tree-sitter-bash")
	  (cmake "https://github.com/uyha/tree-sitter-cmake")
	  (css "https://github.com/tree-sitter/tree-sitter-css")
	  (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
	  (fish "https://github.com/ram02z/tree-sitter-fish")
	  (emacs-lisp "https://github.com/Wilfred/tree-sitter-elisp")
	  (go "https://github.com/tree-sitter/tree-sitter-go")
	  (html "https://github.com/tree-sitter/tree-sitter-html")
	  (javascript "https://github.com/tree-sitter/tree-sitter-javascript"
		      "master" "src")
	  (json "https://github.com/tree-sitter/tree-sitter-json")
	  (lua "https://github.com/MunifTanjim/tree-sitter-lua")
	  (make "https://github.com/alemuller/tree-sitter-make")
	  (markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown"
		    "split_parser" "tree-sitter-markdown/src")
	  (markdown-inline
	   "https://github.com/tree-sitter-grammars/tree-sitter-markdown"
	   "split_parser" "tree-sitter-markdown-inline/src")
	  (powershell "https://github.com/airbus-cert/tree-sitter-powershell")
	  (python "https://github.com/tree-sitter/tree-sitter-python")
	  (rust "https://github.com/tree-sitter/tree-sitter-rust")
	  (toml "https://github.com/ikatyang/tree-sitter-toml")
	  (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
	       "master" "tsx/src")
	  (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
		      "master" "typescript/src")
	  (yaml "https://github.com/ikatyang/tree-sitter-yaml")))
  (add-to-list 'treesit-extra-load-path "/usr/lib"))

(use-package treesit-auto
  :functions (treesit-auto-add-to-auto-mode-alist global-treesit-auto-mode)
  :custom
  (treesit-auto-install 'prompt)
  :config
  (global-treesit-auto-mode 1)
  (treesit-auto-add-to-auto-mode-alist 'all))


;; =======  MASON  =======
;; external package installer
;; =======================
(defvar user/required-mason-programs
  '("debugpy" "fish-lsp" "jsonlint" "marksman" "neocmakelsp" "prettier" "ruff"
    "shellcheck" "shfmt" "tombi" "ty" "yamllint")
  "List of programs required by this setup that mason is able to install.")

(defun user/mason-install-required-programs ()
  "Leverages mason to install required programs if not installed."
  (mason-setup
    (dolist (program user/required-mason-programs)
      (unless (mason-installed-p program)
	(ignore-errors (mason-install program))))))

(defvar user/optional-mason-programs
  '("bash-language-server" "json-language-server" "lemminx" "marksman"
    "yaml-language-server")
  "List of optional programs for this setup that mason is able to install.")

(defun user/mason-install-optional-program (program)
  "Use mason to install an optional PROGRAM.
Installation options come from the list \"user/optional-mason-programs\"."
  (interactive
   (list (completing-read "Select program: "
			  user/optional-mason-programs nil t)))
  (if (mason-installed-p program)
      (message "%s is already installed." program)
    (progn
      (message "Installing %s ..." program)
      (ignore-errors (mason-install program)))))

(defun user/mason-install-optional-programs ()
  "Use mason to install all optional programs."
  (interactive)
  (dolist (program user/optional-mason-programs)
    (unless (mason-installed-p program)
      (ignore-errors (mason-install program)))))

(use-package mason
  :commands mason-setup
  :hook (elpaca-after-init . user/mason-install-required-programs)
  :init
  (setq mason-dir (expand-file-name "~/.local"))
  :functions
  (mason-installed-p
   mason-install
   mason-manager)
  :config
  (bind-keys
   ("C-c m o" . user/mason-install-optional-program)
   ("C-c m a" . user/mason-install-optional-programs)
   ("C-c m m" . mason-manager)))


;; =======  FLYCHECK  =======
;; bash: 'shellcheck' (pacman -S shellcheck)*
;; emacs-lisp: 'emacs-lisp' (built-in)
;; json: 'jsonlint' (npm install -g jsonlint)*
;; markdown: 'mado' (pacman -S mado)
;; xml: 'xmllint' (pacman -S libxml2)
;; yaml: 'yamllint' (pacman -S yamllint)*
;; ==========================
(use-package flycheck
  :hook
  ((bash-ts-mode    . flycheck-mode)
   (emacs-lisp-mode . flycheck-mode)
   (json-ts-mode    . flycheck-mode)
   (markdown-mode   . flycheck-mode)
   (nxml-mode       . flycheck-mode)
   (yaml-ts-mode    . flycheck-mode))
  :functions flycheck-select-checker
  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-disabled-checkers '(emacs-lisp-elsa sh-bash yaml-jsyaml yaml-ruby))
  (flycheck-define-checker markdown-mado
    "A fast Markdown linter written in Rust.
See URL `https://github.com/akiomik/mado`."
    :command ("mado" "check" source)
    :error-patterns
    ((error line-start (file-name)
	    ":" line ":" column ": "
	    (id (one-or-more (not (any " ")))) " " (message) line-end))
    :modes (markdown-mode gfm-mode))
  (add-to-list 'flycheck-checkers 'markdown-mado)
  (when (memq major-mode '(markdown-mode gfm-mode))
    (flycheck-select-checker 'markdown-mado)))

;; Use 'flycheck' with 'flyover' & 'flycheck-color-mode-line'.
(use-package flyover
  :hook (flycheck-mode . flyover-mode)
  :init
  (setq flyover-checkers '(flycheck))
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
  (flyover-virtual-line-type 'dotted-arrow)
  (flyover-line-position-offset 1)
  (flyover-wrap-messages t)
  (flyover-max-line-length 80)
  (flyover-debounce-interval 0.1)
  (flyover-cursor-debounce-interval 0.2)
  (flyover-display-mode 'hide-on-same-line)
  (flyover-hide-during-completion t)
  (bind-keys
   :map flycheck-mode-map
   ("C-c M-f" . flyover-toggle)))

(use-package flycheck-color-mode-line
  :hook (flycheck-mode . flycheck-color-mode-line-mode))


;; =======  LSP-MODE  =======
;; cmake: 'neocmakelsp' (cargo install neocmakelsp)*
;; fish: 'fish-lsp' (npm install -g fish-lsp)*
;; python: 'ty' (uv tool install ty)
;; python: 'ruff' (uv tool install ruff)*
;; toml: 'tombi' (uv tool install tombi)*
;; -------  OPTIONAL  -------
;; [OPTIONAL] bash: 'bash-language-server' (pacman -S bash-language-server)*
;; [OPTIONAL] json: 'json-language-server' (pacman -S json-language-server)*
;; [OPTIONAL] markdown: 'marksman' (pacman -S marksman)*
;; [OPTIONAL] xml: 'lemminx'*
;; [OPTIONAL] yaml: 'yaml-language-server' (pacman -S yaml-language-server)*
;; =====================*****
(use-package lsp-mode
  :hook
  ((cmake-ts-mode  . lsp-deferred)
   (fish-mode      . lsp-deferred)
   (python-ts-mode . lsp-deferred)
   (toml-ts-mode   . lsp-deferred))
  :functions
  (lsp-register-client
   make-lsp--client
   lsp-stdio-connection
   lsp-format-buffer)
  :custom
  (lsp-use-plists t)
  (lsp-enable-which-key-integration)
  (lsp-idle-delay 0.5)
  (lsp-log-io nil)
  (lsp-enable-file-watchers nil)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-auto-guess-root t)
  (lsp-enable-on-type-formatting nil)
  (lsp-disabled-clients '(cmake-language-server
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
    :new-connection (lsp-stdio-connection '("tombi" "lsp"))
    :major-modes '(toml-ts-mode)
    :server-id 'tombi-ls))
  (bind-keys
   :map lsp-mode-map
   ("C-c F" lsp-format-buffer)))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode))

(use-package lsp-treemacs
  :hook (lsp-mode . lsp-treemacs-sync-mode)
  :after treemacs)


;; =======  DAP-MODE  =======
;; python: 'debugpy' (uv tool install debugpy)*
;; ==========================
(use-package dap-mode
  :defer t
  :commands (dap-debug dap-debug-edit-template dap-auto-configure-mode)
  :defines dap-python-debugger
  :custom
  (dap-auto-configure-features '(sessions locals controls tooltip))
  (dap-lldb-dbug-program "/usr/bin/lldb-dap")
  :config
  (require 'dap-python)
  (setq dap-python-debugger 'debugpy))


;; =======  APHELEIA  =======
;; bash: 'shfmt' (pacman -S shfmt)*
;; cmake: 'neocmakelsp' (uv tool install neocmakelsp)*
;; fish: 'fish_indent' (bundled with fish shell)
;; emacs-lisp: 'indent' (built-in)
;; json: 'prettier'* (npm install --save-dev --save-exact prettier)*
;; markdown: 'prettier'* (npm install --save-dev --save-exact prettier)*
;; python: 'ruff' (uv tool install ruff)*
;; toml: 'tombi' (pacman -S tombi)*
;; xml: 'xmlstarlet' (pacman -S xmlstarlet)
;; yaml: 'prettier'* (npm install --save-dev --save-exact prettier)*
;; ==========================
(use-package apheleia
  :functions apheleia-global-mode apheleia-format-buffer
  :config
  (setf (alist-get 'shfmt apheleia-formatters)
	'("shfmt" "-i" "4" "-ci" "-"))
  (setf (alist-get 'neocmakelsp apheleia-formatters)
        '("neocmakelsp" "format" "-"))
  (setf (alist-get 'ruff apheleia-formatters)
        '("ruff" "format" "-"))
  (setf (alist-get 'tombi apheleia-formatters)
        '("tombi" "fmt" "-"))
  (setf (alist-get 'xmlstarlet apheleia-formatters)
        '("xml" "fo" "--indent-spaces" "2" "-"))
  (setf (alist-get 'cmake-ts-mode apheleia-mode-alist) 'neocmakelsp)
  (setf (alist-get 'eask-mode apheleia-mode-alist) 'lisp-indent)
  (setf (alist-get 'fish-mode apheleia-mode-alist) 'fish-indent)
  (setf (alist-get 'markdown-mode apheleia-mode-alist) 'prettier)
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff)
  (setf (alist-get 'toml-ts-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'conf-toml-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'nxml-mode apheleia-mode-alist) 'xmlstarlet)
  (apheleia-global-mode +1)
  (bind-keys ("C-c f" . apheleia-format-buffer)))


;; =======  SNIPPETS  =======
;; 'yasnippet' (functions), 'yasnippet-snippets' (library),
;; 'yasnippet-capf' (completions)
;; ==========================
(use-package yasnippet
  :functions (yas-global-mode yas-reload-all)
  :config
  (add-to-list 'yas-snippet-dirs
	       (expand-file-name "snippets" user-emacs-directory))
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :hook (yas-global-mode . yasnippet-snippets-initialize))

(use-package yasnippet-capf
  :functions yasnippet-capf
  :config
  (add-to-list 'completion-at-point-functions #'yasnippet-capf))


;;; ============================================================================
;;;                    BEGIN LANGUAGE SPECIFIC CONFIGURATIONS
;;; ============================================================================

;; =======  BASH  =======
(use-package bash-ts-mode
  :ensure nil
  :mode ("\\.bash\\'" . bash-ts-mode)
  :interpreter ("bash" . bash-ts-mode)
  :defines bash-ts-mode-map
  :config
  (bind-keys
   :map bash-ts-mode-map
   ("C-c C-l" . lsp-deferred)))

(use-package modern-sh
  :hook (bash-ts-mode . modern-sh-mode)
  :functions modern-sh-menu
  :config
  (bind-keys
   :map bash-ts-mode-map
   ("<f8>" . modern-sh-menu)))


;; =======  CMAKE  =======
(use-package cmake-ts-mode
  :ensure nil
  :mode
  (("\\.cmake\\'" . cmake-ts-mode)
   ("CmakeLists.txt" . cmake-ts-mode)))


;; =======  BOTH-LISP-TYPES  =======
(use-package lisp-semantic-hl
  :hook
  ((emacs-lisp-mode . lisp-semantic-hl-mode)
   (lisp-mode . lisp-semantic-hl-mode)))

(use-package adjust-parens
  :hook
  ((emacs-lisp-mode . adjust-parens-mode)
   (lisp-mode . adjust-parens-mode)))


;; =======  EMACS-LISP  =======
(use-package emacs-lisp-mode
  :ensure nil
  :mode ("\\.el\\'" . emacs-lisp-mode))

(use-package elisp-def
  :hook
  ((emacs-lisp-mode . elisp-def-mode)
   (ielm . elisp-def-mode)))

(use-package suggest
  :bind (:map emacs-lisp-mode-map
	      ("C-c S" . suggest)))

(use-package ielm
  :ensure nil
  :bind (:map emacs-lisp-mode-map
	      ("C-c I" . ielm)))

(use-package eask-mode
  :mode ("Eask" . eask-mode))

(use-package flycheck-eask
  :hook (eask-mode . flycheck-eask-setup))


;; =======  FISH  =======
(use-package fish-mode
  :mode ("\\.fish\\'" . fish-mode)
  :interpreter ("fish" . fish-mode)
  :config
  (setq fish-enable-auto-indent t))


;; =======  JSON  =======
(use-package json-ts-mode
  :ensure nil
  :mode
  (("\\.json\\'" . json-ts-mode)
   ("\\.jsonc\\'" . json-ts-mode))
  :config
  (bind-keys
   :map json-ts-mode-map
   ("C-c C-l" . lsp-deferred)))


;; =======  LISP  =======
(defvar user-init-directory (expand-file-name "init.el.d" user-emacs-directory)
  "Directory from which init files are loaded.")
(use-package lisp-mode
  :ensure nil
  :mode (("\\.lisp\\'" . lisp-mode)
         ("\\.cl\\'"   . lisp-mode)
         ("\\.asd\\'"  . lisp-mode))
  :interpreter ("ros"  . lisp-mode)
  :config
  (add-hook 'lisp-mode-hook
	    (lambda () (load (expand-file-name
			      "roswell-lisp-setup.el" user-init-directory)))))

(use-package slime)


;; =======  MARKDOWN  =======
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "cmark-gfm")
  :config
  (when (memq major-mode '(markdown-mode))
    (setq markdown-command "cmark"))
  (bind-keys
   :map markdown-mode-command-map
   ("C-l" . lsp-deferred)))

(use-package markdown-toc
  :after (:any markdown-mode gfm-mode)
  :functions (markdown-toc-follow-link-at-point
	      markdown-toc-generate-or-refresh-toc
	      markdown-toc-delete-toc
	      markdown-toc-version)
  :config
  (bind-keys
   :map markdown-mode-command-map
   ("C-." . markdown-toc-follow-link-at-point)
   ("C-t" . markdown-toc-generate-or-refresh-toc)
   ("C-d" . markdown-toc-delete-toc)
   ("C-v" . markdown-toc-version)))

(use-package grip-mode
  :after gfm-mode
  :functions grip-mode
  :defines grip-command
  :config
  (bind-keys
   :map markdown-mode-command-map
   ("g" . grip-mode))
  (setq grip-command 'auto))


;; =======  PYTHON  =======
;; 'python' (Emacs native), 'python-x' (general enhancements),
;; 'live-py-mode' (live coding), 'uv-mode' (uv support - includes venvs)
;; 'auto-virtualev' (additional venv support)
;; ========================
(use-package python-ts-mode
  :ensure nil
  :mode ("\\.py\\'" . python-ts-mode)
  :interpreter (("uv" . python-ts-mode)
		("python3" . python-ts-mode))
  :defines
  (python-indent-guess-indent-offset
   python-ts-mode-map)
  :custom
  (lsp-python-vulture-enabled nil)
  (python-shell-interpreter "python3")
  :config
  (bind-keys
   :map python-ts-mode-map
   ("C-c l" . lsp-deferred))
  (setq python-indent-guess-indent-offset nil))

(use-package python-x
  :hook (python-ts-mode . python-x-setup))

(use-package live-py-mode
  :bind (:map python-ts-mode-map
              ("C-c L" . live-py-mode)))

(use-package uv-mode
  :hook (python-ts-mode . uv-mode-auto-activate-hook))

(use-package auto-virtualenv
  :hook (python-ts-mode . auto-virtualenv-setup))


;; =======  TOML  =======
(use-package toml-ts-mode
  :ensure nil
  :mode ("\\.toml\\'" . toml-ts-mode))


;; =======  XML  =======
(use-package nxml-mode
  :ensure nil
  :mode (("\\.xml\\'"  . nxml-mode)
         ("\\.xsd\\'"  . nxml-mode)
         ("\\.xslt\\'" . nxml-mode)
         ("\\.svg\\'"  . nxml-mode)
         ("\\.rss\\'"  . nxml-mode)
         ("\\.pom\\'"  . nxml-mode))
  :custom
  (nxml-child-indent 2)
  (nxml-attribute-indent 2)
  (nxml-slash-auto-complete-flag t)
  :config
  (bind-keys
   :map nxml-mode-map
   ("C-c C-l" . lsp-deferred)))

(use-package auto-rename-tag
  :hook (nxml-mode . auto-rename-tag-mode))


;; =======  YAML  =======
(use-package yaml-ts-mode
  :ensure nil
  :mode (("\\.yml\\'" . yaml-ts-mode)
	 ("\\.yaml\\'" . yaml-ts-mode))
  :config
  (bind-keys
   :map yaml-ts-mode-map
   ("C-c C-l" . lsp-deferred)))

(use-package yaml-pro
  :hook (yaml-ts-mode . yaml-pro-mode))


(provide 'language-specific-configs)
;;; language-specific-configs.el ends here