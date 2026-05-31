;;; 02-completion-setup.el --- Completion stack -*- lexical-binding: t; -*-

;;; Packages included:
;; cape, corfu, emacs, helpful, marginalia, orderless, savehist, tempel,
;; tempel-collection, vertico

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
;; `corfu' (inline completion)
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
		(cons #'tempel-complete completion-at-point-functions))
    (tempel-abbrev-mode 1))
  :bind
  (("M-+" . tempel-complete)
   ("M-*" . tempel-insert))
  :hook
  ((text-mode prog-mode conf-mode) . user/tempel-setup-capf)
  :functions
  tempel-complete tempel-abbrev-mode)

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

(dolist (bind '("C-h f" "C-h v" "C-h k" "C-h x" "C-h F" "C-z"))
  (keymap-global-unset bind))

(use-package helpful
  :ensure (:wait t)
  :demand t
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h x" . helpful-command)
   ("C-h ;" . helpful-at-point)
   ("C-h F" . helpful-function)
   ("C-h z" . helpful-kill-buffers)))

(use-package emacs
  :ensure nil
  :demand t
  :preface
  (defun user/check-parens-with-message ()
    "Run `check-parens'.  Print a message when all parentheses match."
    (interactive)
    (when (not (check-parens))
      (message "All parentheses match!")))

  (defun user/ibuffer-hook-functions ()
    "Group of functions to include in `ibuffer-mode-hook'."
    (hl-line-mode 1)
    (ibuffer-auto-mode 1))

  :bind
  (("C-c x"   . toggle-frame-maximized)
   ("C-c ("   . user/check-parens-with-message)
   ("C-c #"   . display-line-numbers-mode)
   ("C-c C-#" . global-display-line-numbers-mode)
   ("C-c C-!" . restart-emacs))
  :functions ibuffer-auto-mode
  :custom
  (auto-save-visited-interval 60)
  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (read-extended-command-predicate #'command-completion-default-include-p)
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  :config
  (dolist (lib '(bs cl-lib hl-line mouse seq subr-x))
    (require lib))

  (global-display-fill-column-indicator-mode 1)
  (context-menu-mode 1)
  (auto-save-visited-mode 1)
  (add-hook 'ibuffer-mode-hook #'user/ibuffer-hook-functions))


(provide '02-completion-setup)
;;; 02-completion-setup.el ends here
