;;; 04-tree-sitter-lang-config.el --- Enable tree-sitter support -*- lexical-binding: t; -*-

;;; Packages included:
;; bash-ts-mode, cmake-ts-mode, emacs-lisp-mode, ielm, json-ts-mode, lisp-mode,
;; nxml-mode, python-ts-mode, toml-ts-mode, treesit, treesit-auto, yaml-ts-mode

;;; Commentary:
;; Activates and configures Emacs' built-in tree-sitter supported languages.

;;; Code:
;; =======  GLOBAL TREESIT PACKAGES  =======
(defvar treesit-language-source-alist)
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
	  (gitcommit "https://github.com/gbprod/tree-sitter-gitcommit")
	  (go "https://github.com/tree-sitter/tree-sitter-go")
	  (html "https://github.com/tree-sitter/tree-sitter-html")
	  (javascript "https://github.com/tree-sitter/tree-sitter-javascript"
		      "master" "src")
	  (json "https://github.com/tree-sitter/tree-sitter-json")
          (kdl "https://github.com/tree-sitter-grammars/tree-sitter-kdl")
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
  :functions
  global-treesit-auto-mode
  treesit-auto-add-to-auto-mode-alist
  :custom
  (treesit-auto-install 'prompt)
  :config
  ;;  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode 1))


;; =======  MODE CONFIGURATIONS  =======
(use-package bash-ts-mode
  :defer t
  :ensure nil
  :mode
  ("\\.bash\\'" . bash-ts-mode)
  :interpreter ("bash" . bash-ts-mode))

(use-package cmake-ts-mode
  :defer t
  :ensure nil
  :mode
  (("\\.cmake\\'" . cmake-ts-mode)
   ("CMakeLists\\.txt\\'" . cmake-ts-mode)))

(use-package emacs-lisp-mode
  :defer t
  :ensure nil
  :mode ("\\.el\\'" . emacs-lisp-mode))

(use-package ielm
  :defer t
  :ensure nil
  :bind ("C-c I" . ielm))

(use-package json-ts-mode
  :defer t
  :ensure nil
  :mode
  (("\\.json\\'" . json-ts-mode)
   ("\\.jsonc\\'". json-ts-mode)))

(use-package lisp-mode
  :defer t
  :ensure nil
  :mode
  (("\\.lisp\\'" . lisp-mode)
   ("\\.cl\\'"   . lisp-mode)
   ("\\.asd\\'"  . lisp-mode))
  :interpreter ("ros"  . lisp-mode))

(use-package lua-ts-mode
  :defer t
  :ensure nil
  :mode ("\\.lua\\'" . lua-ts-mode)
  :custom
  (lua-ts-inferior-lua "luajit"))

(use-package python-ts-mode
  :defer t
  :ensure nil
  :mode ("\\.py\\'" . python-ts-mode)
  :interpreter
  (("uv" . python-ts-mode)
   ("python3" . python-ts-mode))

  :defines
  python-indent-offset
  python-indent-guess-indent-offset
  python-ts-mode-map

  :custom
  (lsp-python-vulture-enabled nil)
  (python-shell-interpreter "python3")

  :config
  (setq
   python-indent-offset 4
   python-indent-guess-indent-offset nil))

(use-package sh-mode
  :ensure nil
  :interpreter ("sh" . sh-mode))

(use-package toml-ts-mode
  :defer t
  :ensure nil
  :mode ("\\.toml\\'" . toml-ts-mode))

(use-package nxml-mode
  :defer t
  :ensure nil
  :mode
  (("\\.xml\\'"  . nxml-mode)
   ("\\.xsd\\'"  . nxml-mode)
   ("\\.xslt\\'" . nxml-mode)
   ("\\.svg\\'"  . nxml-mode)
   ("\\.rss\\'"  . nxml-mode)
   ("\\.pom\\'"  . nxml-mode))
  :custom
  (nxml-child-indent 2)
  (nxml-attribute-indent 2)
  (nxml-slash-auto-complete-flag t))

(use-package yaml-ts-mode
  :defer t
  :ensure nil
  :mode
  (("\\.yml\\'" . yaml-ts-mode)
   ("\\.yaml\\'" . yaml-ts-mode)))


(provide '04-tree-sitter-lang-config)
;;; 04-tree-sitter-lang-config.el ends here
