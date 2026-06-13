;;; 04-tree-sitter-lang-config.el --- Enable tree-sitter support -*- lexical-binding: t; -*-

;;; Packages included:
;; bash-ts-mode, cmake-ts-mode, dockerfile-ts-mode, emacs-lisp-mode,
;; json-ts-mode, lisp-mode, lua-ts-mode, markdown-ts-mode, nxml-mode,
;; python-ts-mode, sh-mode, toml-ts-mode, treesit, yaml-ts-mode

;;; Commentary:
;; Activates and configures Emacs' built-in tree-sitter supported languages.

;;; Code:
;; =======  GLOBAL TREESIT PACKAGES  =======
(use-package treesit
  :ensure nil
  :demand t
  :mode (("\\.tsx\\'" . tsx-ts-mode))
  :custom
  (treesit-font-lock-level 4)
  (treesit-language-source-alist
   '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
     (common-lisp .  ("https://github.com/tree-sitter-grammars/tree-sitter-commonlisp"))
     (cmake . ("https://github.com/uyha/tree-sitter-cmake"))
     (css . ("https://github.com/tree-sitter/tree-sitter-css"))
     (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
     (dockerfile . ("https://github.com/camdencheek/tree-sitter-dockerfile"))
     (fish . ("https://github.com/ram02z/tree-sitter-fish"))
     (emacs-lisp . ("https://github.com/Wilfred/tree-sitter-elisp"))
     (gitcommit . ("https://github.com/gbprod/tree-sitter-gitcommit"))
     (go . ("https://github.com/tree-sitter/tree-sitter-go"))
     (html . ("https://github.com/tree-sitter/tree-sitter-html"))
     (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"
		    "master" "src"))
     (json . ("https://github.com/tree-sitter/tree-sitter-json"))
     (kdl . ("https://github.com/tree-sitter-grammars/tree-sitter-kdl"))
     (lua . ("https://github.com/MunifTanjim/tree-sitter-lua"))
     (make . ("https://github.com/alemuller/tree-sitter-make"))
     (markdown . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown"
		  "split_parser" "tree-sitter-markdown/src"))
     (markdown-inline . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown"
			 "split_parser" "tree-sitter-markdown-inline/src"))
     (powershell . ("https://github.com/airbus-cert/tree-sitter-powershell"))
     (python . ("https://github.com/tree-sitter/tree-sitter-python"))
     (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))
     (toml . ("https://github.com/ikatyang/tree-sitter-toml"))
     (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript"
	     "master" "tsx/src"))
     (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript"
		    "master" "typescript/src"))
     (yaml . ("https://github.com/ikatyang/tree-sitter-yaml"))
     (zsh . ("https://github.com/georgeharker/tree-sitter-zsh"))))
  :config
  (dolist
      (remaped
       '((bash-mode		 . bash-ts-mode)
	 (cmake-mode		 . cmake-ts-mode)
	 (css-mode		 . css-ts-mode)
	 (go-mode		 . go-ts-mode)
	 (json-mode		 . json-ts-mode)
	 (js-json-mode		 . json-ts-mode)
	 (js2-mode		 . json-ts-mode)
	 (lua-mode		 . lua-ts-mode)
	 (rust-mode		 . rust-ts-mode)
	 (typescript-mode	 . typescript-ts-mode)
	 (conf-toml-mode	 . toml-ts-mode)
	 (yaml-mode		 . yaml-ts-mode)))
    (add-to-list 'major-mode-remap-alist remaped)))


;; =======  MODE CONFIGURATIONS  =======
(use-package bash-ts-mode
  :ensure nil
  :defer t
  :interpreter "bash"
  :mode "\\.bash\\'")

(use-package cmake-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.cmake\\'" "^CMakeLists\\.txt\\'"))

(use-package dockerfile-ts-mode
  :ensure nil
  :defer t
  :mode "^Dockerfile\\'")

(use-package emacs-lisp-mode
  :ensure nil
  :defer t
  :mode "\\.el\\'")

(use-package json-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.json\\'" "\\.jsonc\\'"))

(use-package lisp-mode
  :ensure nil
  :defer t
  :interpreter "sbcl"
  :mode ("\\.lisp\\'" "\\.cl\\'" "\\.asd\\'"))

(use-package lua-ts-mode
  :ensure nil
  :defer t
  :mode "\\.lua\\'"
  :custom
  (lua-ts-inferior-lua "luajit"))

(use-package markdown-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.md\\'" "^README\\'" "^INSTALL\\'"))

(use-package python-ts-mode
  :ensure nil
  :defer t
  :preface
  (defvar python-base-mode-map)
  
  :bind
  (:map python-base-mode-map
	("C-c C-k c" . python-skeleton-class)
	("C-c C-k d" . python-skeleton-def)
	("C-c C-k f" . python-skeleton-for)
	("C-c C-k i" . python-skeleton-if)
	("C-c C-k m" . python-skeleton-import)
	("C-c C-k t" . python-skeleton-try)
	("C-c C-k w" . python-skeleton-while))
  :interpreter ("python3" "uv")
  :mode "\\.py\\'"
  
  :functions
  python-skeleton-class python-skeleton-def python-skeleton-for
  python-skeleton-if python-skeleton-import python-skeleton-try
  python-skeleton-while
  :custom
  (python-indent-offset 4)
  (python-shell-interpreter "python3")
  :config
  (keymap-unset python-base-mode-map "C-c C-t"))

(use-package sh-mode
  :ensure nil
  :defer t
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

  (defun user/fix-zsh-error-echoes (dir)
    "Replace `echo \"ERROR:` with `echo >&2 \"ERROR:` on all .zsh files in DIR."
    (interactive "DDirectory: ")
    (dolist (file (directory-files-recursively dir "\\.zsh\\'"))
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
  :interpreter ("sh" "zsh")
  :mode "\\.zsh\\'"
  :config
  (add-hook 'sh-mode-hook #'user/enable-zsh-error-echo-fix))

(use-package toml-ts-mode
  :ensure nil
  :defer t
  :mode "\\.toml\\'")

(use-package nxml-mode
  :ensure nil
  :defer t
  :mode ("\\.xml\\'" "\\.xsd\\'" "\\.xslt\\'" "\\.svg\\'" "\\.rss\\'"
	 "\\.pom\\'")
  :custom
  (nxml-child-indent 2)
  (nxml-attribute-indent 2)
  (nxml-slash-auto-complete-flag t))

(use-package yaml-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.yml\\'" "\\.yaml\\'"))


(provide '04-tree-sitter-lang-config)
;;; 04-tree-sitter-lang-config.el ends here
