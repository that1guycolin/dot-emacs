;;; 02-completion-setup.el --- Completion stack -*- lexical-binding: t; -*-

;;; Packages included:
;; cape, corfu, emacs, helpful, marginalia, orderless, savehist, vertico

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
  :config
  (savehist-mode 1)
  (add-to-list 'savehist-additional-variables 'corfu-history))

(use-package orderless
  :init
  (setq
   completion-styles '(orderless basic)
   completion-category-overrides '((file (styles basic partial-completion)))
   completion-category-defaults nil))

(use-package vertico
  :functions vertico-mode
  :custom
  (vertico-resize t)
  (vertico-cycle t)
  :config
  (vertico-mode 1))

(use-package marginalia
  :functions
  marginalia-mode
  marginalia-cycle
  :config
  (marginalia-mode 1)
  (bind-keys
   :map minibuffer-local-map
   ("M-A" . marginalia-cycle))
  (bind-keys
   :map completion-list-mode-map
   ("M-A" . marginalia-cycle)))

(use-package corfu
  :functions
  global-corfu-mode
  corfu-history-mode
  corfu-popupinfo-mode
  corfu-next
  corfu-previous
  corfu-complete
  corfu-quit
  corfu-reset
  corfu-popupinfo-toggle
  corfu-popupinfo-scroll-down
  corfu-popupinfo-scroll-up
  
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
  (corfu-popupinfo-mode 1)

  (bind-keys
   :map corfu-map
   ("C-n"   . corfu-next)
   ("C-p"   . corfu-previous)
   ("TAB"   . corfu-complete)
   ("RET"   . corfu-complete)
   ("C-RET" . corfu-reset)
   ("M-d"   . corfu-popupinfo-toggle)
   ("M-n"   . corfu-popupinfo-scroll-down)
   ("M-p"   . corfu-popupinfo-scroll-up)))

(use-package cape
  :bind ("C-c TAB" . cape-prefix-map)
  :functions
  cape-dabbrev
  cape-file
  cape-elisp-block
  cape-history
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-hook 'completion-at-point-functions #'cape-history))

(keymap-global-unset "C-h f")
(keymap-global-unset "C-h v")
(keymap-global-unset "C-h k")
(keymap-global-unset "C-h x")
(keymap-global-unset "C-h F")

(use-package helpful
  :functions
  helpful-callable
  helpful-variable
  helpful-key
  helpful-command
  helpful-at-point
  helpful-function
  :config
  (bind-keys
   ("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h x" . helpful-command)
   ("C-h ;" . helpful-at-point)
   ("C-h F" . helpful-function)))

(defun user/check-parens-with-message ()
  "Run `check-parens'.  Print a message when all parentheses match."
  (interactive)
  (when (not (check-parens))
    (message "All parentheses match!")))

(keymap-global-unset "C-z")
(use-package emacs
  :ensure nil
  :bind
  (("C-c x"   . toggle-frame-maximized)
   ("C-c ("   . user/check-parens-with-message)
   ("C-c #"   . display-line-numbers-mode)
   ("C-c C-#" . global-display-line-numbers-mode)
   ("C-c C-!" . restart-emacs))

  :custom
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  :config
  (context-menu-mode 1)
  (global-visual-line-mode 1))


(provide '02-completion-setup)
;;; 02-completion-setup.el ends here
