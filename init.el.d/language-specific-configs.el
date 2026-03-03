;;; language-specific-configs.el --- Language Support -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for language-specific modes.  Shared packages (treesit,
;; flycheck, lsp-mode, dap-mode, apheleia) are configured first, followed
;; by language-specific settings in alphabetical order.
;;
;; Languages: bash, cmake, common-lisp, emacs-lisp, fish, json, markdown,
;; python, toml, xml, yaml

;;; Packages included:
;; apheleia, auto-rename-tag, auto-virtualenv, bash, cmake-mode, dap-mode,
;; eask-mode, elisp-def, emacs-lisp-mode, fish-mode, flycheck,
;; flycheck-color-mode-line, flycheck-eask, flyover, ielm, json-mode, lisp-mode,
;; lisp-semantic-hl, live-py-mode, lsp-mode, lsp-treemacs, lsp-ui,
;; markdown-mode, mason, modern-sh, nxml-mode, python, python-x, suggest,
;; test-simple, toml, treesit, treesit-auto, uv-mode, yaml

;;; Code:
;; Tree-sitter support ('treesit' 'treesit-auto')
(defvar treesit-language-source-alist nil
  "List of online treesitter repositories for various languages.")

(use-package treesit
  :ensure nil
  :no-require t
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
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; 'mason' (external package installer - linters, formatters, & lsps, oh my!)
(use-package mason
  :functions (mason-installed-p mason-install)
  :config
  (mason-setup
   (dolist (pkg '("debugpy" "fish-lsp" "jsonlint" "marksman" "neocmakelsp"
		  "ruff" "shellcheck" "shfmt" "tombi" "ty" "yamllint"))
     (unless (mason-installed-p pkg)
       (ignore-errors (mason-install pkg))))))

;;; Flycheck linters:
;; bash: 'shellcheck' (pacman -S shellcheck)*
;; emacs-lisp: 'emacs-lisp' (built-in)
;; json: 'jsonlint' (npm install -g jsonlint)*
;; markdown: 'mado' (pacman -S mado)
;; xml: 'xmlstarlet' (pacman -S xmlstarlet)
;; yaml: 'yamllint' (pacman -S yamllint)*

(use-package flycheck
  :hook ((bash-ts-mode    . flycheck-mode)
	 (emacs-lisp-mode . flycheck-mode)
	 (json-ts-mode    . flycheck-mode)
	 (markdown-mode   . flycheck-mode)
	 (nxml-mode       . flycheck-mode)
	 (yaml-ts-mode    . flycheck-mode))
  :functions flycheck-select-checker
  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-disabled-checkers '(emacs-lisp-elsa sh-bash yaml-jsyaml yaml-ruby)))

;; Use 'flycheck' with 'flycheck-inline' & 'flycheck-color-mode-line'.
(use-package flyover
  :hook (flycheck-mode . flyover-mode)
  :custom
  (flyover-checkers '(flycheck))
  (flyover-levels '(error warning info))

  ;; Appearance
  (flyover-use-theme-colors t)
  (flyover-background-lightness 45)

  ;; Text tinting
  (flyover-text-tint 'lighter)
  (flyover-text-tint-percent 50)

  ;; Icon tinting (foreground and background)
  (flyover-icon-tint 'lighter)
  (flyover-icon-tint-percent 50)
  (flyover-icon-background-tint 'darker)
  (flyover-icon-background-tint-percent 50)

  ;; Icons
  (flyover-info-icon " ")
  (flyover-warning-icon " ")
  (flyover-error-icon " ")

  ;; Border styles: none, pill, arrow, slant, slant-inv, flames, pixels
  (flyover-border-style 'pill)
  (flyover-border-match-icon t)

  ;; Display settings
  (flyover-hide-checker-name t)
  (flyover-show-virtual-line t)
  (flyover-virtual-line-type 'curved-dotted-arrow)
  (flyover-line-position-offset 1)

  ;; Message wrapping
  (flyover-wrap-messages t)
  (flyover-max-line-length 80)

  ;; Performance
  (flyover-debounce-interval 0.2)
  (flyover-cursor-debounce-interval 0.3)

  ;; Display mode (controls cursor-based visibility)
  (flyover-display-mode 'always)

  ;; Completion integration
  (flyover-hide-during-completion t))

(use-package flycheck-color-mode-line
  :hook (flycheck-mode . flycheck-color-mode-line-mode))

;;; LSP servers:
;; cmake: 'neocmakelsp' (cargo install neocmakelsp)*
;; fish: 'fish-lsp' (npm install -g fish-lsp)*
;; python: 'ty' (uv tool install ty); 'ruff' (uv tool install ruff)*
;; toml: 'tombi' (uv tool install tombi)*
;; [OPTIONAL] markdown: 'marksman' (pacman -S marksman)

(use-package lsp-mode
  :hook ((cmake-ts-mode    . lsp-deferred)
	 (fish-mode        . lsp-deferred)
	 (python-ts-mode   . lsp-deferred)
	 (toml-ts-mode     . lsp-deferred))
  :bind-keymap ("C-c C-l" . lsp-mode-map)
  :functions (lsp-register-client make-lsp--client lsp-stdio-connection)
  :bind (:map lsp-mode-map
	      ("f" . lsp-format-buffer))
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
                          taplo)))

(use-package lsp-ui
  :after lsp-mode)

(use-package lsp-treemacs
  :after (lsp-mode treemacs))

;;; Dap-mode debuggers:
;; python: 'debugpy' (uv tool install debugpy)*

(use-package dap-mode
  :commands (dap-debug dap-debug-edit-template dap-auto-configure-mode)
  :defines dap-python-debugger
  :custom
  (dap-auto-configure-features '(sessions locals controls tooltip))
  (dap-lldb-dbug-program "/usr/bin/lldb-dap")
  :config
  (require 'dap-python)
  (setq dap-python-debugger 'debugpy))

;;; 'Apheleia' formatters:
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
  (setf (alist-get 'cmake-mode apheleia-mode-alist) 'neocmakelsp)
  (setf (alist-get 'cmake-ts-mode apheleia-mode-alist) 'neocmakelsp)
  (setf (alist-get 'eask-mode apheleia-mode-alist) 'lisp-indent)
  (setf (alist-get 'fish-mode apheleia-mode-alist) 'fish-indent)
  (setf (alist-get 'markdown-mode apheleia-mode-alist) 'prettier)
  (setf (alist-get 'markdown-ts-mode apheleia-mode-alist) 'prettier)
  (setf (alist-get 'python-mode apheleia-mode-alist) 'ruff)
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff)
  (setf (alist-get 'toml-ts-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'conf-toml-mode apheleia-mode-alist) 'tombi)
  (setf (alist-get 'nxml-mode apheleia-mode-alist) 'xmlstarlet)
  (apheleia-global-mode +1)
  (keymap-global-set "C-c f" #'apheleia-format-buffer))

;; Semantic hightlighting for common and emacs lisp flavors.
(use-package lisp-semantic-hl
  :hook ((emacs-lisp-mode lisp-mode) . lisp-semantic-hl-mode))

;;; ****************************************************************************
;;;                BEGIN LANGUAGE SPECIFIC CONFIGURATIONS
;;; ****************************************************************************

;;; ***BASH***
(use-package bash
  :ensure nil
  :no-require t
  :mode ("\\.bash\\'" . bash-ts-mode)
  :interpreter ("bash" . bash-ts-mode))

(use-package modern-sh
  :hook (bash-ts-mode . modern-sh-mode)
  :bind (:map bash-ts-mode-map
	      ("<f8>" . modern-sh-menu)))
;;; ***CMAKE***
;; Emacs configuration for cmake-mode.  Add neocmakelsp as lsp server

(use-package cmake-mode
  :mode (("\\.cmake\\'" . cmake-ts-mode)
	 ("CmakeLists.txt" . cmake-ts-mode))
  :config
  (with-eval-after-load 'lsp-mode
    (lsp-register-client
     (make-lsp--client
      :new-connection (lsp-stdio-connection '("neocmakelsp" "stdio"))
      :major-modes '(cmake-mode cmake-ts-mode)
      :server-id 'neocmakelsp))))

;;; ***COMMON-LISP***
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
(use-package slime
  :after lisp-mode)

;;; ***EMACS-LISP***
(use-package emacs-lisp-mode
  :ensure nil
  :no-require t
  :mode ("\\.el\\'" . emacs-lisp-mode))

(use-package elisp-def
  :bind (:map emacs-lisp-mode-map
	      ("C-c C-d" . elisp-def)
	      ("C-c C-D" . elisp-def-mode))
  :hook ((emacs-lisp-mode . elisp-def-mode)
	 (ielm . elisp-def-mode)))

(use-package suggest
  :bind (:map emacs-lisp-mode-map
	      ("C-c C-s" . suggest)))

(use-package test-simple
  :bind (:map emacs-lisp-mode-map
	      ("C-c C-t" . test-simple-start)))

(use-package ielm
  :ensure nil
  :bind (:map emacs-lisp-mode-map
	      ("C-c e" . ielm)))

(use-package eask-mode
  :mode ("Eask" . eask-mode))

(use-package flycheck-eask
  :hook (eask-mode . flycheck-eask-setup))

;;; ***FISH***
(use-package fish-mode
  :mode ("\\.fish\\'" . fish-mode)
  :interpreter ("fish" . fish-mode)
  :custom
  (fish-enable-auto-indent t)
  :config
  (with-eval-after-load 'lsp-mode
    (add-to-list 'lsp-language-id-configuration '(fish-mode . "fish"))
    (lsp-register-client
     (make-lsp--client
      :new-connection (lsp-stdio-connection '("fish-lsp" "start"))
      :major-modes '(fish-mode fish-ts-mode)
      :server-id 'fish-ls))))

;;; ***JSON***
(use-package json-mode
  :mode (("\\.json\\'" . json-ts-mode)
         ("\\.jsonc\\'" . json-ts-mode)))

;;; ***MARKDOWN***
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "cmark")
  :config
  (when (memq major-mode '(gfm-mode))
    (setq markdown-command "cmark-gfm"))
  (with-eval-after-load 'flycheck
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
  (define-key markdown-mode-command-map (kbd "C-l") #'lsp-deferred))

(use-package markdown-toc
  :after (:any markdown-mode gfm-mode)
  :functions (markdown-toc-follow-link-at-point
	      markdown-toc-generate-or-refresh-toc
	      markdown-toc-delete-toc
	      markdown-toc-version)
  :config
  (define-key markdown-mode-command-map (kbd "C-.")
	      #'markdown-toc-follow-link-at-point)
  (define-key markdown-mode-command-map (kbd "C-t")
	      #'markdown-toc-generate-or-refresh-toc)
  (define-key markdown-mode-command-map (kbd "C-d") #'markdown-toc-delete-toc)
  (define-key markdown-mode-command-map (kbd "C-v") #'markdown-toc-version))

(use-package grip-mode
  :ensure (:package "grip-mode" :source "MELPA" :protocol https
		    :inherit t :depth nil :repo "seagle0128/grip-mode"
		    :fetcher github
		    :files ("*.el" "*.el.in" "dir" "*.info" "*.texi"
			    "*.texinfo" "doc/dir" "doc/*.info" "doc/*.texi"
			    "doc/*.texinfo" "lisp/*.el" "docs/dir"
			    "docs/*.info" "docs/*.texi" "docs/*.texinfo"
			    (:exclude ".dir-locals.el" "test.el" "tests.el"
				      "*-test.el" "*-tests.el" "LICENSE"
				      "README*" "*-pkg.el")))
  :after gfm-mode
  :functions grip-mode
  :defines grip-command
  :config
  (define-key markdown-mode-command-map (kbd "g") #'grip-mode)
  (setq grip-command 'auto))


;;; ***PYTHON***
;; 'python' (Emacs native), 'python-x' (general enhancements),
;; 'live-py-mode' (live coding), 'uv-mode' (uv support - includes venvs)
;; 'auto-virtualev' (additional venv support)

(use-package python
  :mode ("\\.py\\'" . python-ts-mode)
  :interpreter ("uv" . python-ts-mode)
  :custom
  (lsp-python-vulture-enabled nil)
  (python-shell-interpreter "python3")
  :config
  (setq python-indent-offset 4))

(use-package python-x
  :hook (python-ts-mode . python-x-setup))

(use-package live-py-mode
  :bind (:map python-ts-mode-map
	      ("C-c C-l" . live-py-mode)))

(use-package uv-mode
  :hook (python-ts-mode . uv-mode-auto-activate-hook))

(use-package auto-virtualenv
  :hook (python-ts-mode . auto-virtualenv-setup))

;;; ***TOML***
(use-package toml
  :mode ("\\.toml\\'" . toml-ts-mode)
  :config
  (with-eval-after-load 'lsp-mode
    (lsp-register-client
     (make-lsp--client
      :new-connection (lsp-stdio-connection '("tombi" "lsp"))
      :major-modes '(toml-mode toml-ts-mode)
      :server-id 'tombi-ls))))

;;; ***XML***
(use-package nxml-mode
  :ensure nil
  :no-require t
  :mode (("\\.xml\\'"  . nxml-mode)
         ("\\.xsd\\'"  . nxml-mode)
         ("\\.xslt\\'" . nxml-mode)
         ("\\.svg\\'"  . nxml-mode)
         ("\\.rss\\'"  . nxml-mode)
         ("\\.pom\\'"  . nxml-mode))
  :custom
  (nxml-child-indent 2)
  (nxml-attribute-indent 2)
  (nxml-slash-auto-complete-flag t))

(use-package auto-rename-tag
  :hook (nxml-mode . auto-rename-tag-mode))

;;; ***YAML***
(use-package yaml
  :mode (("\\.yml\\'" . yaml-ts-mode)
	 ("\\.yaml\\'" . yaml-ts-mode)))

(provide 'language-specific-configs)
;;; language-specific-configs.el ends here
