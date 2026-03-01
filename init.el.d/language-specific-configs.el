;;; language-specific-configs.el --- Language Support -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for language-specific modes.  Shared packages (treesit,
;; flycheck, lsp-mode, dap-mode, apheleia) are configured first, followed
;; by language-specific settings in alphabetical order.
;;
;; Languages: bash, cmake, common-lisp, emacs-lisp, fish, json, markdown,
;; python, toml, xml, yaml

;;; Packages included:
;; apheleia, bash, cmake-mode, dap-mode, eask-mode, elisp-def, emacs-lisp-mode,
;; fish-mode, flycheck, flycheck-color-mode-line, flycheck-eask, flycheck-inline,
;; ielm, json5-ts-mode, lisp-mode, lisp-semantic-hl, live-py-mode, lsp-mode,
;; lsp-treemacs, lsp-ui, markdown-ts-mode, nxml-mode, python, python-x, sly,
;; suggest, test-simple, toml, treesit, treesit-auto, treesit-langs, uv-mode,
;; yaml-ts-mode

;;; Code:
;; Treesitter: 'treesit'
(use-package treesit
  :ensure nil
  :no-require t
  :demand t)

(use-package treesit-langs
  :ensure nil
  :no-require t
  :demand t)

(use-package treesit-auto
  :demand t
  :functions global-treesit-auto-mode
  :config
  (global-treesit-auto-mode 1))

;;; Flycheck linters:
;; bash: 'shellcheck' (pacman -S shellcheck)
;; emacs-lisp: 'emacs-lisp' (built-in)
;; json: 'jsonlint' (npm install -g jsonlint)
;; xml: 'xmlstarlet' (pacman -S xmlstarlet)
;; yaml: 'yamllint' (pacman -S yamllint)

(use-package flycheck
  :demand t
  :functions global-flycheck-mode
  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-disabled-checkers '((emacs-lisp-elsa
                                 sh-bash
                                 yaml-jsyaml
                                 yaml-ruby)))
  :config
  (global-flycheck-mode))

;; Use 'flycheck' with 'flycheck-inline' & 'flycheck-color-mode-line'.
(use-package flycheck-inline
  :after flycheck
  :hook (flycheck-mode . flycheck-inline-mode))

(use-package flycheck-color-mode-line
  :after flycheck
  :hook (flycheck-inline-mode . flycheck-color-mode-line-mode))

;;; LSP servers:
;; cmake: 'neocmakelsp' (cargo install neocmakelsp)
;; fish: 'fish-lsp' (npm install -g fish-lsp)
;; markdown: 'marksman' (pacman -S marksman);;
;; python: 'ty' (uv tool install ty); 'ruff' (uv tool install ruff)
;; toml: 'tombi' (uv tool install tombi)

(use-package lsp-mode
  :commands (lsp-register-client
             make-lsp--client
             lsp-stdio-connection)
  :hook ((cmake-mode
	  cmake-ts-mode
          fish-mode
          markdown-ts-mode
          python-ts-mode
          toml-ts-mode) . lsp-deferred)
  :bind-keymap ("C-c l" . lsp-mode-map)
  :bind (:map lsp-mode-map
              ("C-c l f" . lsp-format-buffer))
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
  :after lsp-mode
  :demand t)

(use-package lsp-treemacs
  :after (lsp-mode treemacs)
  :demand t)

;;; Dap-mode debuggers:
;; python: 'debugpy' (uv tool install debugpy)

(use-package dap-mode
  :commands (dap-debug dap-debug-edit-template dap-auto-configure-mode)
  :custom
  (dap-auto-configure-features '(sessions locals controls tooltip))
  (dap-lldb-dbug-program '("/usr/bin/lldb-dap"))
  (dap-python-debugger 'debugpy)
  (require 'dap-python))

;;; 'Apheleia' formatters:
;; bash: 'shfmt' (pacman -S shfmt)
;; cmake: 'neocmakelsp' (uv tool install neocmakelsp)
;; fish: 'fish_indent' (bundled with fish shell)
;; elisp: 'indent' (built-in)
;; json: 'prettier'* (npm install --save-dev --save-exact prettier)
;; markdown: 'prettier'* (npm install --save-dev --save-exact prettier)
;; python: 'ruff' (uv tool install ruff)
;; toml: 'tombi' (pacman -S tombi)
;; xml: 'xmlstarlet' (pacman -S xmlstarlet)
;; yaml: 'prettier'* (npm install --save-dev --save-exact prettier)
;; (NOTE: When formatting with 'prettier', it is HIGHLY recommended to use a
;; project-specific installation rather than a global one.)

(use-package apheleia
  :demand t
  :functions apheleia-global-mode apheleia-format-buffer
  :config
  (setf (alist-get 'shfmt apheleia-formatters) '("shfmt" "-i" "4" "-ci"))
  (setf (alist-get 'neocmakelsp apheleia-formatters)
        '("neocmakelsp" "format" "-"))
  (setf (alist-get 'ruff apheleia-formatters)
        '("ruff" "format"))
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
  :ensure t
  :hook ((emacs-lisp-mode lisp-mode) . lisp-semantic-hl-mode))

;;; ****************************************************************************
;;;                BEGIN LANGUAGE SPECIFIC CONFIGURATIONS
;;; ****************************************************************************

;;; ***BASH***
;; Basic Emacs configuration for bash scripts.

(use-package bash
  :ensure nil
  :no-require t
  :mode (("\\.bash\\'" . bash-ts-mode)
	 ("\\.sh\\'" . bash-ts-mode))
  :interpreter ("bash" . bash-ts-mode))

;;; ***CMAKE***
;; Emacs configuration for cmake-mode.  Add neocmakelsp as lsp server

(use-package cmake-mode
  :mode (("\\.cmake\\'" . cmake-ts-mode)
	 ("CmakeLists.txt" . cmake-ts-mode))
  :custom
  (add-to-list 'major-mode-remap-alist '(cmake-mode . cmake-ts-mode))
  :config
  (with-eval-after-load 'lsp-mode
    (lsp-register-client
     (make-lsp--client
      :new-connection (lsp-stdio-connection '("neocmakelsp" "stdio"))
      :major-modes '(cmake-mode cmake-ts-mode)
      :server-id 'neocmakelsp))))

;;; ***COMMON-LISP***
;; General Emacs configuration for common-lisp. 'sly' (superior-lisp-mode)

(use-package lisp-mode
  :ensure nil
  :mode (("\\.lisp\\'" . lisp-mode)
         ("\\.cl\\'"   . lisp-mode)
         ("\\.asd\\'"  . lisp-mode))
  :interpreter ("ros"  . lisp-mode)
  :custom
  (inferior-lisp-program "ros -Q run"))

(use-package sly
  :after lisp-mode
  :hook (lisp-mode . sly)
  :custom
  (inferior-lisp-program "ros -Q run"))

;;; ***EMACS-LISP***
;; Configures emacs-lisp-mode for .el files linting through flycheck.

(use-package emacs-lisp-mode
  :ensure nil
  :no-require t
  :bind ("C-c e" . emacs-lisp-mode-map)
  :mode ("\\.el\\'" . emacs-lisp-mode))

(use-package elisp-def
  :bind (:map emacs-lisp-mode-map
	      ("C-c e d" . elisp-def)
	      ("C-c e C-d" . elisp-def-mode))
  :hook ((emacs-lisp-mode ielm) . elisp-def-mode))

(use-package suggest
  :bind (:map emacs-lisp-mode-map
	      ("C-c e s" . suggest)))

(use-package test-simple
  :bind (:map emacs-lisp-mode-map
	      ("C-c e t" . test-simple-start)))

(use-package ielm
  :ensure nil
  :bind (:map emacs-lisp-mode-map
	      ("C-c e e" . ielm)))

(use-package eask-mode
  :mode ("Eask" . eask-mode))

(use-package flycheck-eask
  :hook (eask-mode . flycheck-eask-setup)
  :after eask-mode)

;;; ***FISH***
;; Set Emacs to activate fish mode based on .fish extension or shebang.
;; Sets and enables auto indent.

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
;; Configures json-mode for .json  & .jsonc files.

(use-package json5-ts-mode
  :mode (("\\.json\\'" . json5-ts-mode)
         ("\\.jsonc\\'" . json5-ts-mode)))

;;; ***MARKDOWN***
;; General Emacs configuration for markdown documents.

(use-package markdown-ts-mode
  :mode (("\\.md\\'" . markdown-ts-mode)
         ("README" . markdown-ts-mode)
         ("INSTALL" . markdown-ts-mode))
  :config
  (with-eval-after-load 'lsp-mode
    (add-to-list 'lsp-language-id-configuration
		 '(markdown-ts-mode . "markdown"))))

;;; ***PYTHON***
;; 'python' (Emacs native), 'python-x' (general enhancements),
;; 'live-py-mode' (live coding), 'uv-mode' (uv support - includes venvs)
(use-package python
  :bind-keymap ("C-c p" . python-keymap)
  :mode ("\\.py\\'" . python-ts-mode)
  :custom
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
  (lsp-python-vulture-enabled nil)
  (python-indent-offset 4)
  (python-shell-interpreter "python3"))

(use-package python-x
  :after python
  :hook (python-mode . python-x-setup))

;; Live python with 'live-py-mode'
(use-package live-py-mode
  :after python
  :bind (:map python-ts-mode-map
              ("C-c p l" . live-py-mode)))

(use-package uv-mode
  :hook ((python-mode python-ts-mode). uv-mode-auto-activate-hook))

;;; ***TOML***
;; Basic Emacs configuration for toml-mode.

(use-package toml
  :ensure nil
  :mode ("\\.toml\\'" . toml-ts-mode)
  :custom
  (add-to-list 'major-mode-remap-alist '(toml . toml-ts-mode))
  :config
  (with-eval-after-load 'lsp-mode
    (lsp-register-client
     (make-lsp--client
      :new-connection (lsp-stdio-connection '("tombi" "lsp"))
      :major-modes '(toml-mode toml-ts-mode)
      :server-id 'tombi-ls))))

;;; ***XML***
;; Basic Emacs user configuration for nxml-mode.

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

;;; ***YAML***
;; Basic Emacs configuration for yaml-mode.

(use-package yaml-ts-mode
  :ensure nil
  :mode (("\\.yml\\'" . yaml-ts-mode)
	 ("\\.yaml\\'" . yaml-ts-mode))
  :custom
  (add-to-list 'major-mode-remap-alist '(yaml-mode . yaml-ts-mode)))

(provide 'language-specific-configs)
;;; language-specific-configs.el ends here
