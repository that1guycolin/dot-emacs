;;; 02-completion-setup.el --- Completion stack -*- lexical-binding: t; -*-

;;; Packages included:
;; cape, consult, corfu, embark, embark-consult, helpful, marginalia, orderless,
;; savehist, tempel, tempel-collection, vertico

;;; Commentary:
;; Completion UI stack; this needs to load early because many other packages
;; depend on these.  Also, Emacs UI can get real weird the first time you call
;; these functions unless loaded early in startup process.

;;; Code:
;; =======  COMPLETIONS  =======
;; `savehist' (history across sessions)
;; `orderless' (fuzzy matching)
;; `vertigo' (minibuffer completions)
;; `marginalia' (rich annotations)
;; `tempel' (new completion framework)
;; `corfu' (inline completion)
;; `consult' (gather data)
;; `embark' (mouse events on keyboard)
;; `embark-consult' (integration)
;; `helpful' (better help)
;; =============================
(use-package savehist
  :ensure nil
  :demand t
  :config
  (savehist-mode 1))

(use-package orderless
  :demand t
  :init
  (setq
   completion-styles '(orderless basic)
   completion-category-overrides '((file (styles basic partial-completion)))
   completion-category-defaults nil))

(use-package vertico
  :demand t
  :functions vertico-mode
  :custom
  (vertico-resize t)
  (vertico-cycle t)
  :config
  (vertico-mode 1))

(use-package marginalia
  :demand t
  :bind (:map minibuffer-local-map
	      ("M-A" . marginalia-cycle)
	      :map completion-list-mode-map
	      ("M-A" . marginalia-cycle))
  :functions marginalia-mode
  :config
  (marginalia-mode 1))

;; tempel goes here because it needs to load before corfu
(use-package tempel
  :demand t
  :preface
  (defun user/tempel-setup-capf ()
    "Locally add relevant tempel items to `completion-at-point-functions'."
    (setq-local completion-at-point-functions
		(cons #'tempel-complete completion-at-point-functions)))
  :bind
  (("M-+"   . tempel-insert)
   ("M-*"   . tempel-complete)
   :map tempel-map
   ("TAB"   . tempel-next)
   ("C-TAB" . tempel-previous))
  :hook ((text-mode prog-mode conf-mode) . user/tempel-setup-capf)
  :functions tempel-complete tempel-abbrev-mode
  :init (tempel-abbrev-mode 1))

(use-package tempel-collection
  :after tempel)

(use-package corfu
  :demand t
  :bind (:map corfu-map
	      ("C-n"   . corfu-next)
	      ("C-p"   . corfu-previous)
	      ("TAB"   . corfu-complete)
	      ("RET"   . corfu-complete)
	      ("C-RET" . corfu-reset)
	      ("M-d"   . corfu-popupinfo-toggle)
	      ("M-n"   . corfu-popupinfo-scroll-down)
	      ("M-p"   . corfu-popupinfo-scroll-up))
  :functions
  global-corfu-mode corfu-history-mode corfu-popupinfo-mode
  
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 4)
  (corfu-auto-delay 0.8)
  (corfu-cycle t)
  (corfu-quit-at-boundary t)
  (corfu-quit-no-match t)
  (corfu-on-exact-match 'insert)
  (corfu-popupinfo-delay nil)

  :config
  (global-corfu-mode 1)
  (corfu-history-mode 1)
  (add-to-list 'savehist-additional-variables 'corfu-history)
  (corfu-popupinfo-mode 1))

(use-package cape
  :demand t
  :bind ("C-c TAB" . cape-prefix-map)
  :functions
  cape-dabbrev cape-file cape-elisp-block cape-history
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-history))

(use-package consult
  :demand t
  :preface
  (declare-function consult-register-window "consult-register")
  (defvar register-preview-delay)
  (defvar xref-show-xrefs-function)
  (defvar xref-show-definitions-function)

  :bind
  (("C-c M-x"		 . consult-mode-command)
   ("C-c h"		 . consult-history)
   ("C-c k"		 . consult-kmacro)
   ("C-c M-m"		 . consult-man)
   ("C-c i"		 . consult-info)
   ([remap Info-search]	 . consult-info)

   ("C-x M-:"		 . consult-complex-command)
   ("C-x b"		 . consult-buffer)
   ("C-x 4 b"		 . consult-buffer-other-window)
   ("C-x 5 b"		 . consult-buffer-other-frame)
   ("C-x t b"		 . consult-buffer-other-tab)
   ("C-x r b"		 . consult-bookmark)

   ("C-x r j"		 . consult-register-load)
   ("C-x r s"		 . consult-register-store)
   ("C-x r M-r"		 . consult-register)

   ("M-y"		 . consult-yank-pop)

   ("M-s d"		 . consult-find)
   ("M-s g"		 . consult-grep)
   ("M-s G"		 . consult-git-grep)
   ("M-s r"		 . consult-ripgrep)
   ("M-s l"		 . consult-line)
   ("M-s L"		 . consult-line-multi)
   ("M-s k"		 . consult-keep-lines)
   ("M-s u"		 . consult-focus-lines)

   ([remap goto-line]	 . consult-goto-line)
   ([remap imenu]	 . consult-imenu))
  :functions
  consult--customize-put consult-xref

  :init
  (setq register-preview-delay 0.5)
  (with-eval-after-load 'consult-register
    (advice-add #'register-preview :override #'consult-register-window))

  :custom
  (consult-narrow-key "<")
  (consult-project-function #'consult--default-project-function)

  :config
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   :preview-key '(:debounce 0.4 any))

  (setq xref-show-xrefs-function #'consult-xref
	xref-show-definitions-function #'consult-xref))

(use-package embark
  :demand t
  :preface
  (defvar completion-category-overrides)
  (defvar display-buffer-alist)
  (defvar eldoc-documentation-strategy)
  (defvar prefix-help-command)

  :bind
  (("C-."   . embark-act)
   ("C-;"   . embark-dwim)
   ("C-h B" . embark-bindings))
  :functions
  embark-prefix-help-command embark-eldoc-first-target

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  (add-to-list
   'completion-category-overrides
   '(embark-keybinding (styles . (substring))))

  (add-to-list
   'display-buffer-alist
   '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
     nil
     (window-parameters (mode-line-format . none))))

  (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package helpful
  :demand t
  :preface
  (dolist (bind '("C-h f" "C-h v" "C-h k" "C-h x" "C-h F" "C-z"))
    (keymap-global-unset bind))
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h x" . helpful-command)
   ("C-h ;" . helpful-at-point)
   ("C-h F" . helpful-function)
   ("C-h z" . helpful-kill-buffers)))


(provide '02-completion-setup)
;;; 02-completion-setup.el ends here
