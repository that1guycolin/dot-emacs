;;; 08-language-configs.el --- Packages & settings for select languages -*- lexical-binding: t; -*-

;;; Packages included:
;; adjust-parens, auto-rename-tag, checkdoc, eask-mode, elisp-def, eros,
;; fish-mode, flycheck-eask, grip-mode, kdl-mode, lisp-semantic-hl, live-py-mode,
;; macrostep, markdown-mode, markdown-toc, modern-sh, python-x, sly, suggest,
;; uv-mode, yaml-pro

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

;;(Use-Package uv-mode
;;  :defer t
;;  :hook ((python-ts-mode . user/uv-mode-auto-activate)
;;         (python-mode    . user/uv-mode-auto-activate))
;;  :functions
;;  uv-mode-root
;;  uv-mode
;;  uv-mode-set
;;  :init
;;  (defun user/uv-mode-auto-activate ()
;;    "Enable uv-mode and activate the nearest project .venv (if any)."
;;    (when (derived-mode-p 'python-base-mode)
;;      (when (uv-mode-root) <==NO SUCH THING AS uv-mode-root
;;        (uv-mode 1)
;;        (uv-mode-set)))))


;; =======  SHELL SCRIPTS  =======
;; `modern-sh' (enhaced sh-mode & bash(-ts)-mode)
;; `fish-mode' (fish shell support)
;; ===============================
(use-package modern-sh
  :defer t
  :hook
  ((bash-ts-mode . modern-sh-mode)
   (sh-mode . modern-sh-mode))
  :functions modern-sh-menu
  :config
  (bind-keys
   :map bash-ts-mode-map
   ("<f8>" . modern-sh-menu)
   :map sh-mode-map
   ("<f8>" . modern-sh-menu)))

(use-package fish-mode
  :defer t
  :mode ("\\.fish\\'")
  :interpreter ("fish")
  :config
  (setq fish-enable-auto-indent t))


;; =======  MARKUP/CONFIG  =======
;; `kdl-mode' (support .kdl)
;; `markdown-mode', `markdown-toc',
;; `grip-mode' (support md, gfm)
;; `auto-rename-tag' (xml tag assistant)
;; `yaml-pro' (enhanced .yaml support)
;; ===============================
(use-package ini-mode
  :defer t
  :mode
  (("\\.ini\\'"     . ini-mode)
   ("\\.desktop\\'" . ini-mode)
   ("\\.hook\\'"    . ini-mode))
  :bind ("C-c i" . ini-mode))

(use-package kdl-mode
  :defer t
  :mode ("\\.kdl\\'"))

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

(use-package markdown-toc
  :defer t
  :after markdown-mode
  :functions
  markdown-toc-follow-link-at-point
  markdown-toc-generate-or-refresh-toc
  markdown-toc-delete-toc
  markdown-toc-version
  :config
  (bind-keys
   :map markdown-mode-command-map
   ("C-." . markdown-toc-follow-link-at-point)
   ("C-t" . markdown-toc-generate-or-refresh-toc)
   ("C-d" . markdown-toc-delete-toc)
   ("C-v" . markdown-toc-version)))

(use-package grip-mode
  :defer t
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
;; `checkdoc' (style checker)
;; `elisp-def' (go directly to symbol def)
;; `morlock' (additional font hl)
;; `eros' (see function results in buffer)
;; `suggest' (find function to accomplish X)
;; `macrostep' (interactive macro stepper)
;; `lispxmp' (see results in buffer)
;; -------------------------
;; SBCL (ros)
;; `sly' (modern slime)
;; =========================
(use-package lisp-semantic-hl
  :defer t
  :hook
  ((emacs-lisp-mode . lisp-semantic-hl-mode)
   (lisp-mode . lisp-semantic-hl-mode)))

(use-package adjust-parens
  :defer t
  :hook
  ((emacs-lisp-mode . adjust-parens-mode)
   (lisp-mode . adjust-parens-mode)))

(use-package checkdoc
  :ensure nil
  :commands
  checkdoc-defun
  checkdoc-current-buffer)

(use-package elisp-def
  :defer t
  :hook
  ((emacs-lisp-mode . elisp-def-mode)
   (ielm-mode . elisp-def-mode)))

(use-package morlock
  :defer t
  :hook (emacs-lisp-mode . morlock-mode))

(use-package eros
  :defer t
  :hook (emacs-lisp-mode . eros-mode))

(use-package suggest
  :defer t
  :bind (:map emacs-lisp-mode-map
	      ("C-c S" . suggest)))

(use-package macrostep
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c m" . macrostep-expand)))

(use-package sly
  :defer t
  :commands
  sly
  sly-connect
  :hook (common-lisp-mode . sly)
  :custom
  (inferior-lisp-program "ros run")
  (sly-lisp-implementations '((ros ("ros" "run"))))
  (sly-default-lisp 'ros)
  (sly-net-coding-system 'utf-8-unix))


;; =======  EASK  =======
;; `eask-mode' (syntax for Eask files)
;; `flycheck-eask' (linting Eask files)
;; ======================
(use-package eask-mode
  :defer t
  :mode ("Eask\\'"))

(use-package flycheck-eask
  :defer t
  :hook (eask-mode . flycheck-eask-setup))


(provide '08-language-configs)
;;; 08-language-configs.el ends here
