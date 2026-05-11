;;; 07-language-configs.el --- Packages & settings for select languages -*- lexical-binding: t; -*-

;;; Packages included:
;; adjust-parens, auto-rename-tag, auto-virtualenv, checkdoc, dockerfile-mode,
;; dwim-coder-mode eask-mode, eldoc-cmake, elisp-def, eros, eros-inspector,
;; fish-mode, glsl-mode, grip-mode, ini-mode, inspector, kdl-mode,
;; lisp-semantic-hl, live-py-mode, macrostep, markdown-mode, modern-sh, morlock,
;; python-x, sly, suggest, tree-inspector, yaml-pro

;;; Commentary:
;; Provide packages and settings that enhance Emacs support for specific markup,
;; scripting, & coding languages.

;;; Code:
(defun user/smart-set-fill-column (value)
  "Set `fill-column' to VALUE only if it hasn't been changed by a local config."
  (when (eq fill-column (default-value 'fill-column))
    (setq fill-column value))
  (turn-on-auto-fill))


;; =======  (E)LISP  =======
;; ALL:
;; `adjust-parens' (smart '()')
;; `lisp-semantic-hl'
;; -------------------------
;; EMACS LISP
;; `checkdoc' (style checker)
;; `elisp-def' (go directly to symbol def)
;; `eros' (see function results in buffer)
;; `inspector' (inspection tool for emacs-lisp objects)
;; `eros-inspector' (combine functionality of eros & inspector)
;; `macrostep' (interactive macro stepper)
;; `morlock' (additional font hl)
;; `suggest' (find function to accomplish X)
;; `tree-inspector' (tree-style view for inspector)
;; -------------------------
;; SBCL
;; `sly' (modern slime)
;; =========================
(use-package adjust-parens
  :defer t
  :hook
  ((emacs-lisp-mode . adjust-parens-mode)
   (lisp-mode       . adjust-parens-mode)))

(use-package lisp-semantic-hl
  :defer t
  :hook
  ((emacs-lisp-mode . lisp-semantic-hl-mode)
   (lisp-mode       . lisp-semantic-hl-mode)))

(use-package checkdoc
  :ensure nil
  :commands checkdoc-defun checkdoc-current-buffer)

(use-package elisp-def
  :defer t
  :hook (emacs-lisp-mode . elisp-def-mode))

(use-package eros
  :defer t
  :hook (emacs-lisp-mode . eros-mode))

(use-package inspector
  :defer t
  :bind ("M-I e" . inspector-inspect-expression)
  :custom
  (inspector-switch-to-buffer nil))

(use-package eros-inspector
  :after eros inspector
  :functions
  eros-inspector-eval-last-sexp eros-inspector-eval-defun
  :config
  (keymap-global-set "<remap> <eros-eval-last-sexp>"
		     #'eros-inspector-eval-last-sexp)
  (keymap-global-set "<remap> <eros-eval-defun>" #'eros-inspector-eval-defun))

(use-package macrostep
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c C-m" . macrostep-expand)))

(use-package morlock
  :defer t
  :hook (emacs-lisp-mode . morlock-mode))

(use-package suggest
  :defer t
  :bind (:map emacs-lisp-mode-map
	      ("C-c C-S" . suggest)))

(use-package tree-inspector
  :defer t
  :bind
  (("M-I t" . tree-inspector-inspect-expression)
   ("M-I s" . tree-inspector-inspect-last-sexp)))

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


;; =======  PYTHON  =======
;; `auto-virtualenv' (virtual env support)
;; `dwim-coder-mode' (hacks to reduce effort)
;; `live-py-mode' (live coding)
;; `python-x' (enhance built-in python(-ts)-mode)
;; ========================
(defvar python-ts-mode-map)
(add-hook 'python-ts-mode-hook
          (lambda ()
            (add-hook 'hack-local-variables-hook
                      (lambda () (user/smart-set-fill-column 72)
			nil t))))

(use-package auto-virtualenv
  :hook (python-ts-mode . auto-virtualenv-setup)
  :custom
  (auto-virtualenv-verbose t))

(use-package dwim-coder-mode
  :hook
  ((c-ts-mode      . dwim-coder-mode)
   (python-ts-mode . dwim-coder-mode)
   (rust-ts-mode   . dwim-coder-mode)))

(use-package live-py-mode
  :defer t
  :bind (:map python-ts-mode-map
              ("C-c L" . live-py-mode)))

(use-package python-x
  :defer t
  :hook (python-ts-mode . python-x-setup))


;; =======  SHELL SCRIPTS  =======
;; `fish-mode' (fish shell support)
;; ===============================
(use-package fish-mode
  :defer t
  :mode ("\\.fish\\'")
  :interpreter ("fish")
  :custom
  (fish-enable-auto-indent t))


;; =======  CONFIG FILE MODES  =======
;; `dockerfile-mode' (support Dockerfiles)
;; `eask-mode' (support Eask files)
;; `glsl-mode' (support OpenGL Shading Language)
;; `ini-mode' (config file support)
;; `kdl-mode' (support .kdl)
;; ===================================
(use-package dockerfile-mode
  :defer t
  :mode ("^Dockerfile\\'" . dockerfile-mode))

(use-package eask-mode
  :defer t
  :mode ("^Eask\\'" . eask-mode))

(use-package glsl-mode
  :defer t
  :mode ("\\.glsl\\'" . glsl-mode))

(use-package ini-mode
  :defer t
  :mode
  (("\\.ini\\'"     . ini-mode)
   ("\\.desktop\\'" . ini-mode)
   ("\\.hook\\'"    . ini-mode)))

(use-package kdl-mode
  :defer t
  :mode ("\\.kdl\\'" . kdl-mode))

(use-package systemd
  :defer t
  :mode
  (("\\.service\\'" . systemd-mode)
   ("\\.socket\\'"  . systemd-mode)))

;; =======  ENHANCE BUILT-INS  =======
;; `auto-rename-tag' (xml tag assistant)
;; `eldoc-cmake' (doc support in cmake-ts-mode)
;; `grip-mode' (support for gfm)
;; `yaml-pro' (enhanced .yaml support)
;; ===================================
(use-package auto-rename-tag
  :defer t
  :hook (nxml-mode . auto-rename-tag-mode))

(use-package eldoc-cmake
  :defer t
  :hook (cmake-ts-mode . eldoc-cmake-enable))

(defvar markdown-ts-mode-map)
(use-package grip-mode
  :defer t
  :commands grip-mode
  :defines grip-command
  :config
  (bind-keys
   :map markdown-ts-mode-map
   ("C-c j" . grip-mode))
  (setq grip-command 'auto))

(use-package yaml-pro
  :ensure (:wait t)
  :defer t
  :hook (yaml-ts-mode . yaml-pro-mode))


(provide '07-language-configs)
;;; 07-language-configs.el ends here
