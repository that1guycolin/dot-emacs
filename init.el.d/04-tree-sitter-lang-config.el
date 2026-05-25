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
  :defer t
  :ensure nil
  :mode ("\\.bash\\'"  . bash-ts-mode)
  :interpreter ("bash" . bash-ts-mode))

(use-package cmake-ts-mode
  :defer t
  :ensure nil
  :mode
  (("\\.cmake\\'" . cmake-ts-mode)
   ("^CMakeLists\\.txt\\'" . cmake-ts-mode)))

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
  :interpreter ("sbcl"  . lisp-mode))

(use-package lua-ts-mode
  :defer t
  :ensure nil
  :mode ("\\.lua\\'" . lua-ts-mode)
  :custom
  (lua-ts-inferior-lua "luajit"))

(use-package markdown-ts-mode
  :defer t
  :ensure nil
  :mode
  (("\\.md\\'"    . markdown-ts-mode)
   ("^README\\'"  . markdown-ts-mode)
   ("^INSTALL\\'" . markdown-ts-mode)))

(use-package python-ts-mode
  :defer t
  :ensure nil
  :mode ("\\.py\\'" . python-ts-mode)
  :interpreter
  (("uv"      . python-ts-mode)
   ("python3" . python-ts-mode))

  :functions
  python-skeleton-class python-skeleton-def python-skeleton-for
  python-skeleton-if python-skeleton-import python-skeleton-try
  python-skeleton-while
  :defines
  python-indent-offset python-indent-guess-indent-offset
  python-ts-mode-map

  :custom
  (python-indent-offset 4)
  (python-indent-guess-indent-offset nil)
  (python-shell-interpreter "python3")
  :config
  (bind-keys
   :map python-ts-mode-map
   ("C-c C-k c" . python-skeleton-class)
   ("C-c C-k d" . python-skeleton-def)
   ("C-c C-k f" . python-skeleton-for)
   ("C-c C-k i" . python-skeleton-if)
   ("C-c C-k m" . python-skeleton-import)
   ("C-c C-k t" . python-skeleton-try)
   ("C-c C-k w" . python-skeleton-while))
  (keymap-unset python-ts-mode-map "C-c C-t"))

(use-package sh-mode
  :defer t
  :ensure nil
  :preface
  (defun user/zsh-redirect-error-echoes ()
    "Redirect ERROR echo calls to stderr in zsh buffers."
    (when (derived-mode-p 'sh-mode)
      (save-excursion
	(goto-char (point-min))
	(while (search-forward "echo \"ERROR:" nil t)
          (replace-match "echo >&2 \"ERROR:" t t)))))

  (defun user/enable-zsh-error-echo-fix ()
    "Enable automatic stderr redirection for zsh files."
    (when (and (derived-mode-p 'sh-mode)
               (boundp 'sh-shell)
               (string= sh-shell "zsh"))
      (add-hook 'before-save-hook #'user/zsh-redirect-error-echoes nil t)))

  (defun my/fix-zsh-error-echoes (directory)
    "Replace `echo \"ERROR:` with `echo >&2 \"ERROR:` in all .zsh files under DIRECTORY."
    (interactive "DDirectory: ")
    (dolist (file (directory-files-recursively directory "\\.zsh\\'"))
      (with-temp-buffer
	(insert-file-contents file)
	(goto-char (point-min))
	(let ((modified nil))
          (while (search-forward "echo \"ERROR:" nil t)
            (replace-match "echo >&2 \"ERROR:" t t)
            (setq modified t))
          (when modified
            (write-region nil nil file nil 'silent)
            (message "Updated: %s" file))))))
  :mode ("\\.zsh\\'")
  :interpreter ("sh" "zsh")
  :config
  (add-hook 'sh-mode-hook #'user/enable-zsh-error-echo-fix))

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
  (("\\.yml\\'"  . yaml-ts-mode)
   ("\\.yaml\\'" . yaml-ts-mode)))


(provide '04-tree-sitter-lang-config)
;;; 04-tree-sitter-lang-config.el ends here
