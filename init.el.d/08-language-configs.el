;;; 08-language-configs.el --- Packages & settings for select languages -*- lexical-binding: t; -*-

;;; Packages included:
;; adjust-parens, auto-rename-tag, auto-virtualenv, checkdoc, eask-mode,
;; elisp-def, eros, eros-inspector, fish-mode, flycheck-eask, flycheck-package,
;; glsl-mode, grip-mode, ini-mode, inspector, kdl-mode, lisp-semantic-hl,
;; live-py-mode, macrostep, markdown-mode, modern-sh, morlock, python-x, sly,
;; suggest, tree-inspector, yaml-pro

;;; Commentary:
;; Provide packages and settings that enhance Emacs support for specific markup,
;; scripting, & coding languages.

;;; Code:
(defun user/smart-set-fill-column (value)
  "Set `fill-column' to VALUE only if it hasn't been changed by a local config."
  (when (eq fill-column (default-value 'fill-column))
    (setq fill-column value))
  (turn-on-auto-fill))

;; =======  PYTHON  =======
;; `python-x' (enhance built-in python(-ts)-mode)
;; `live-py-mode' (live coding)
;; `auto-virtualenv' (virtual env support)
;; ========================
(add-hook 'python-ts-mode-hook
          (lambda ()
            (add-hook 'hack-local-variables-hook
                      (lambda () (user/smart-set-fill-column 72))
                      nil t)))

(use-package python-x
  :defer t
  :hook (python-ts-mode . python-x-setup))

(use-package live-py-mode
  :defer t
  :bind (:map python-ts-mode-map
              ("C-c L" . live-py-mode)))

(use-package auto-virtualenv
  :hook (python-ts-mode . auto-virtualenv-setup)
  :custom
  (auto-virtualenv-verbose t))


;; =======  SHELL SCRIPTS  =======
;; `modern-sh' (enhaced sh-mode & bash(-ts)-mode)
;; `fish-mode' (fish shell support)
;; `eldoc-cmake' (doc support in cmake-ts-mode)
;; ===============================
(use-package modern-sh
  :defer t
  :hook
  ((bash-ts-mode . modern-sh-mode)
   (sh-mode      . modern-sh-mode))
  :functions modern-sh-menu
  :config
  (bind-keys
   :map bash-ts-mode-map
   ("<f8>"    . modern-sh-menu)
   ("C-c C-m" . modern-sh-menu)
   :map sh-mode-map
   ("<f8>"    . modern-sh-menu)
   ("C-c C-m" . modern-sh-menu)))

(use-package fish-mode
  :defer t
  :mode ("\\.fish\\'")
  :interpreter ("fish")
  :config
  (setq fish-enable-auto-indent t))

(use-package eldoc-cmake
  :defer t
  :hook (cmake-ts-mode . eldoc-cmake-enable))


;; =======  MARKUP/CONFIG  =======
;; `dockerfile-mode' (support Dockerfiles)
;; `glsl-mode' (support OpenGL Shading Language)
;; `ini-mode' (config file support)
;; `json-mode' (needed for json to work in org)
;; `kdl-mode' (support .kdl)
;; `markdown-mode', `markdown-toc',
;; `grip-mode' (support md, gfm)
;; `auto-rename-tag' (xml tag assistant)
;; `yaml-pro' (enhanced .yaml support)
;; ===============================
(use-package dockerfile-mode
  :defer t
  :mode ("^Dockerfile\\'"))

(use-package glsl-mode
  :defer t
  :mode ("\\.glsl\\'" . glsl-mode))

(use-package ini-mode
  :defer t
  :mode
  (("\\.ini\\'"     . ini-mode)
   ("\\.desktop\\'" . ini-mode)
   ("\\.hook\\'"    . ini-mode)))

(use-package json-mode
  :defer t
  :mode ("\\.json\\'" . json-mode))

(use-package kdl-mode
  :defer t
  :mode ("\\.kdl\\'" . kdl-mode))

(use-package markdown-mode
  :defer t
  :mode ("README\\.md\\'" . gfm-mode)
  :functions user/switch-markdown-command
  :init
  (setq markdown-command "cmark")
  :config
  (defun user/switch-markdown-command (command)
    "Change the value of `markdown-command' to COMMAND."
    (interactive
     (list (completing-read "Select md backend: "
                            '("cmark" "cmark-gfm" "pandoc") nil t)))
    (setq markdown-command command))

  (add-hook 'markdown-mode-hook
            (lambda ()
              (add-hook 'hack-local-variables-hook
			(lambda () (user/smart-set-fill-column 100))
			nil t)))
  
  (bind-keys
   :map markdown-mode-command-map
   ("C-c" . user/switch-markdown-command)))

(use-package grip-mode
  :after markdown-mode
  :functions grip-mode
  :defines grip-command
  :config
  (bind-keys
   :map markdown-mode-command-map
   ("g" . grip-mode))
  (setq grip-command 'auto))

(use-package auto-rename-tag
  :defer t
  :hook (nxml-mode . auto-rename-tag-mode))

(use-package yaml-pro
  :defer t
  :hook (yaml-ts-mode . yaml-pro-mode))


;; =======  (E)LISP  =======
;; ALL:
;; `lisp-semantic-hl'
;; `adjust-parens' (smart '()')
;; -------------------------
;; EMACS LISP
;; `morlock' (additional font hl)
;; `checkdoc' (style checker)
;; `elisp-def' (go directly to symbol def)
;; `eros' (see function results in buffer)
;; `suggest' (find function to accomplish X)
;; `macrostep' (interactive macro stepper)
;; -------------------------
;; SBCL
;; `sly' (modern slime)
;; =========================
(use-package lisp-semantic-hl
  :defer t
  :hook
  ((emacs-lisp-mode . lisp-semantic-hl-mode)
   (lisp-mode       . lisp-semantic-hl-mode)))

(use-package adjust-parens
  :defer t
  :hook
  ((emacs-lisp-mode . adjust-parens-mode)
   (lisp-mode       . adjust-parens-mode)))

(use-package morlock
  :defer t
  :hook (emacs-lisp-mode . morlock-mode))

(use-package checkdoc
  :ensure nil
  :commands
  checkdoc-defun checkdoc-current-buffer)

(use-package elisp-def
  :defer t
  :hook
  (emacs-lisp-mode . elisp-def-mode))

(use-package inspector
  :functions inspector-inspect-expression
  :custom
  (inspector-switch-to-buffer nil)
  :config
  (bind-keys
   ("M-I e" . inspector-inspect-expression)))

(use-package tree-inspector
  :functions
  tree-inspector-inspect-expression tree-inspector-inspect-last-sexp
  :config
  (bind-keys
   ("M-I t" . tree-inspector-inspect-expression)
   ("M-I s" . tree-inspector-inspect-last-sexp)))

(use-package eros
  :defer t
  :hook (emacs-lisp-mode . eros-mode))

(use-package eros-inspector
  :after eros
  :functions
  eros-inspector-eval-last-sexp eros-inspector-eval-defun
  :config
  (keymap-global-set "<remap> <eros-eval-last-sexp>"
		     #'eros-inspector-eval-last-sexp)
  (keymap-global-set "<remap> <eros-eval-defun>" #'eros-inspector-eval-defun))

(use-package suggest
  :defer t
  :bind (:map emacs-lisp-mode-map
	      ("C-c C-S" . suggest)))

(use-package macrostep
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c C-m" . macrostep-expand)))

(use-package sly
  :defer t
  :hook (lisp-mode . sly-editing-mode)
  :commands sly
  :functions sly-init-string
  :custom
  (inferior-lisp-program "sbcl")
  (sly-lisp-implementations
   '((sbcl ("sbcl" "--dynamic-space-size" "2048")
           :coding-system utf-8-unix)))

  :config
  (let ((ql-setup "~/.quicklisp/setup.lisp"))
    (when (file-exists-p ql-setup)
      (setq sly-lisp-implementations
            (mapcar (lambda (impl)
                      (append impl
                              (list
			       :init (lambda (port-filename coding-system)
                                       (format "(progn (load \"%s\") %s)\n"
                                               (expand-file-name ql-setup)
                                               (sly-init-string
						port-filename
						coding-system))))))
                    sly-lisp-implementations))))
  (add-to-list 'sly-contribs 'sly-mrepl))


;; =======  PACKAGING  =======
;; `eask-mode' (Eask file syntax)
;; `flycheck-eask' (lint Eask files)
;; `flycheck-package' (lint Emacs' pacakges)
;; ======================
(use-package eask-mode
  :defer t
  :mode ("Eask\\'"))

(use-package flycheck-eask
  :defer t
  :hook (eask-mode . flycheck-eask-setup))

(use-package flycheck-package
  :defer t
  :hook (emacs-lisp-mode . flycheck-package-setup))


(provide '08-language-configs)
;;; 08-language-configs.el ends here
