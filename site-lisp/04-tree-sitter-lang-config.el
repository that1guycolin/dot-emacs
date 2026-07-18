;;; 04-tree-sitter-lang-config.el --- Enable tree-sitter support -*- lexical-binding: t; -*-

;;; Packages included:
;; bash-ts-mode, cmake-ts-mode, dockerfile-ts-mode, emacs-lisp-mode,
;; json-ts-mode, lisp-mode, lua-ts-mode, markdown-ts-mode, nxml-mode,
;; python-ts-mode, sh-mode, toml-ts-mode, treesit, yaml-ts-mode

;;; Commentary:
;; Activates and configures Emacs' built-in tree-sitter supported languages.

;;; Code:
;;; Global:
(use-package treesit
  :ensure nil
  :demand t
  :preface
  (declare-function no-littering-expand-var-file-name "no-littering")
  (defvar user/remapped-langs-alist
    '((bash-mode              . bash-ts-mode)
      (cmake-mode             . cmake-ts-mode)
      (css-mode               . css-ts-mode)
      (dockerfile-mode        . dockerfile-ts-mode)
      (go-mode                . go-ts-mode)
      (json-mode              . json-ts-mode)
      (js-json-mode           . json-ts-mode)
      (lua-mode               . lua-ts-mode)
      (rust-mode              . rust-ts-mode)
      (typescript-mode        . typescript-ts-mode)
      (conf-toml-mode         . toml-ts-mode)
      (xml-mode               . xml-ts-mode)
      (yaml-mode              . yaml-ts-mode))
    "Alist of cons cells mapping orig lang modes to their treesit versions.")
  
  :mode ("\\.tsx\\'" . tsx-ts-mode)
  :init (setq treesit-extra-load-path
              (list (no-littering-expand-var-file-name "tree-sitter")))
  :custom (treesit-font-lock-level 4)
  :config
  (setq
   treesit-language-source-alist
   '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
     (common-lisp . ("https://github.com/tree-sitter-grammars/tree-sitter-commonlisp"))
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
     (xml . ("https://github.com/tree-sitter-grammars/tree-sitter-xml"))
     (yaml . ("https://github.com/ikatyang/tree-sitter-yaml"))
     (zsh . ("https://github.com/georgeharker/tree-sitter-zsh"))))
  (dolist (remaped user/remapped-langs-alist)
    (add-to-list 'major-mode-remap-alist remaped)))


;;; Mode configurations:
(use-package bash-ts-mode
  :ensure nil
  :defer t
  :interpreter "bash"
  :mode "\\.bash\\'")

(use-package cmake-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.cmake\\'" "CMakeLists\\.txt\\'"))

(use-package dockerfile-ts-mode
  :ensure nil
  :defer t
  :mode ("Dockerfile\\'" "Containerfile\\'")
  :config
  (add-hook 'dockerfile-ts-mode-hook
            (lambda () (setq-local fill-column 1000))))

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
  :custom (lua-ts-inferior-lua "luajit"))

(use-package markdown-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.md\\'" "README\\'" "INSTALL\\'"))

(use-package python-ts-mode
  :ensure nil
  :defer t
  :preface (defvar python-base-mode-map)
  :bind (:map python-base-mode-map
              ("C-c C-k c" . python-skeleton-class)
              ("C-c C-k d" . python-skeleton-def)
              ("C-c C-k f" . python-skeleton-for)
              ("C-c C-k i" . python-skeleton-if)
              ("C-c C-k m" . python-skeleton-import)
              ("C-c C-k t" . python-skeleton-try)
              ("C-c C-k w" . python-skeleton-while))
  :interpreter ("python3" "uv")
  :mode "\\.py\\'"
  :functions (python-skeleton-class
              python-skeleton-def python-skeleton-for python-skeleton-if
              python-skeleton-import python-skeleton-try python-skeleton-while)
  :custom
  (python-indent-offset 4)
  (python-shell-interpreter "python3")
  :config (keymap-unset python-base-mode-map "C-c C-t"))

(use-package sh-mode
  :ensure nil
  :defer t
  :interpreter ("sh" "zsh" "dash")
  :mode ("\\.zsh\\'" "\\.dash\\'"))

(use-package rustic-ts-mode
  :ensure nil
  :defer t
  :mode "\\.rs\\'")

(use-package toml-ts-mode
  :ensure nil
  :defer t
  :mode "\\.toml\\'")

(use-package nxml-mode
  :ensure nil
  :defer t
  :mode ("\\.xml\\'"
         "\\.xsd\\'" "\\.xslt\\'" "\\.svg\\'" "\\.rss\\'" "\\.pom\\'")
  :custom
  (nxml-child-indent 2)
  (nxml-attribute-indent 2)
  (nxml-slash-auto-complete-flag t))

(use-package yaml-ts-mode
  :ensure nil
  :defer t
  :preface
  :mode ("\\.yml\\'" "\\.yaml\\'")
  :config
  (add-hook 'yaml-ts-mode-hook
	    (lambda () (setq-local fill-column 1000))))


(provide '04-tree-sitter-lang-config)
;;; 04-tree-sitter-lang-config.el ends here
