;;; 04-tree-sitter-lang-config.el --- Enable tree-sitter support -*- lexical-binding: t; -*-

;;; Packages included:
;; bash-ts-mode, cmake-ts-mode, emacs-lisp-mode, ielm, json-ts-mode, lisp-mode,
;; lua-ts-mode, markdown-ts-mode, nxml-mode, python-ts-mode, sh-mode,
;; toml-ts-mode, treesit, yaml-ts-mode

;;; Commentary:
;; Activates and configures Emacs' built-in tree-sitter supported languages.

;;; Code:
;; =======  GLOBAL TREESIT PACKAGES  =======
(defvar treesit-language-source-alist)
(use-package treesit
  :ensure nil
  :demand t
  :config
  (setq treesit-language-source-alist
	'((bash "https://github.com/tree-sitter/tree-sitter-bash")
	  (common-lisp
	   "https://github.com/tree-sitter-grammars/tree-sitter-commonlisp")
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
	  (yaml "https://github.com/ikatyang/tree-sitter-yaml")
	  (zsh "https://github.com/georgeharker/tree-sitter-zsh"))))


;; =======  MODE CONFIGURATIONS  =======
(use-package bash-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.bash\\'"  . bash-ts-mode)
  :interpreter ("bash" . bash-ts-mode))

(use-package cmake-ts-mode
  :ensure nil
  :defer t
  :mode
  (("\\.cmake\\'"          . cmake-ts-mode)
   ("^CMakeLists\\.txt\\'" . cmake-ts-mode)))

(use-package emacs-lisp-mode
  :ensure nil
  :defer t
  :mode ("\\.el\\'" . emacs-lisp-mode))

(use-package ielm
  :ensure nil
  :defer t
  :bind ("C-c I" . ielm))

(use-package json-ts-mode
  :ensure nil
  :defer t
  :mode
  (("\\.json\\'" . json-ts-mode)
   ("\\.jsonc\\'". json-ts-mode)))

(use-package lisp-mode
  :ensure nil
  :defer t
  :mode
  (("\\.lisp\\'" . lisp-mode)
   ("\\.cl\\'"   . lisp-mode)
   ("\\.asd\\'"  . lisp-mode))
  :interpreter ("sbcl" . lisp-mode))

(use-package lua-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.lua\\'" . lua-ts-mode)
  :custom
  (lua-ts-inferior-lua "luajit"))

(use-package markdown-ts-mode
  :ensure nil
  :defer t
  :mode
  (("\\.md\\'"    . markdown-ts-mode)
   ("^README\\'"  . markdown-ts-mode)
   ("^INSTALL\\'" . markdown-ts-mode)))

(defvar python-mode-map)
(use-package python-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.py\\'" . python-ts-mode)
  :interpreter
  (("uv"      . python-ts-mode)
   ("python3" . python-ts-mode))
  :bind
  (:map python-mode-map
	("C-c C-k c" . python-skeleton-class)
	("C-c C-k d" . python-skeleton-def)
	("C-c C-k f" . python-skeleton-for)
	("C-c C-k i" . python-skeleton-if)
	("C-c C-k m" . python-skeleton-import)
	("C-c C-k t" . python-skeleton-try)
	("C-c C-k w" . python-skeleton-while))

  :custom
  (python-indent-offset 4)
  (python-shell-interpreter "python3")
  :config
  (keymap-unset python-mode-map "C-c C-t"))

(use-package sh-mode
  :ensure nil
  :defer t
  :interpreter
  (("sh"  . sh-mode)
   ("zsh" . sh-mode)))

(use-package toml-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.toml\\'" . toml-ts-mode))

(use-package nxml-mode
  :ensure nil
  :defer t
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
  :ensure nil
  :defer t
  :mode
  (("\\.yml\\'"  . yaml-ts-mode)
   ("\\.yaml\\'" . yaml-ts-mode)))


(provide '04-tree-sitter-lang-config)
;;; 04-tree-sitter-lang-config.el ends here
