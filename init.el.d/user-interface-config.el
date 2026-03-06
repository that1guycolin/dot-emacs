;;; user-interface-config.el --- Emacs configuration for visual settings -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for the Emacs user workspace, including the theme, font,
;; startup screen (dashboard), and completion UI
;; (corfu, vertico, orderless, marginalia).

;;; Packages included:
;; cape, corfu, dashboard, emacs, marginalia, nerd-icons, nerd-icons-corfu,
;; orderless, savehist, tab-line-nerd-icons, vertico

;;; Code:
;; =======  LOOK & FEEL  =======
;; Theme: `weyland-yutani'
;; Font: `CommitMonoNerdFontMono'
;; Icons: `NerdIcons'
;; =============================
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq custom-safe-themes t)

(load-theme 'weyland-yutani t)
(when (member "CommitMono Nerd Font Mono" (font-family-list))
  (set-face-attribute 'default nil
                      :family "CommitMono Nerd Font Mono"
                      :foundry "NerdFont"
                      :slant 'normal
                      :weight 'regular
                      :height 110
                      :width 'normal))

(use-package nerd-icons
  :defer t
  :functions nerd-icons-install-fonts
  :config
  (unless (member "Symbols Nerd Font Mono" (font-family-list))
    (when (window-system)
      (nerd-icons-install-fonts t))))


;; =======  WINDOWS/FRAMES  =======
;; 'dashboard' (startup buffer)
;; ================================
(use-package tab-line-nerd-icons
  :hook (elpaca-after-init . tab-line-nerd-icons-global-mode))

(use-package dashboard
  :functions (dashboard-setup-startup-hook
	      dashboard-insert-startupify-lists
	      dashboard-initialize
	      dashboard-open)
  :custom
  (dashboard-projects-backend 'projectile)
  (dashboard-startup-banner 'logo)
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-set-navigator t)
  (dashboard-navigation-cycle t)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-banner-logo-title "Welcome back")
  (dashboard-items '((bookmarks . 3)
                     (recents  . 7)
                     (projects . 5)))
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook)
  (add-hook 'before-make-frame-hook #'dashboard-open)
  (add-hook 'after-make-frame-functions (lambda (&rest _)
					  (switch-to-buffer "*dashboard*"))))


;; =======  COMPLETIONS  =======
;; 'corfu' (inline completion)
;; 'vertigo' (minibuffer completions)
;; 'savehist' (history across sessions)
;; 'orderless' (fuzzy matching)
;; 'marginalia' (rich annotations)
;; =============================
(use-package corfu
  :functions (global-corfu-mode corfu-history-mode corfu-popupinfo-mode)
  :custom
  (corfu-cycle t)
  (corfu-quit-at-boundary nil)
  (corfu-on-exact-match 'insert)
  :init
  (global-corfu-mode 1)
  (corfu-history-mode 1)
  (corfu-popupinfo-mode 1))

(use-package nerd-icons-corfu
  :config
  (add-to-list 'corfu-margin-formatters 'nerd-icons-corfu-formatter))

(use-package cape
  :bind ("C-c TAB" . cape-prefix-map)
  :functions (cape-dabbrev cape-file cape-elisp-block cape-history)
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-hook 'completion-at-point-functions #'cape-history))

(use-package vertico
  :functions vertico-mode
  :init
  (vertico-mode 1)
  :custom
  (vertico-resize t)
  (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (completion-category-defaults nil))

(use-package savehist
  :ensure nil
  :config
  (savehist-mode 1))

(use-package marginalia
  :bind
  ((:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
   (:map completion-list-mode-map
         ("M-A" . marginalia-cycle)))
  :functions marginalia-mode
  :init
  (marginalia-mode 1))

;; Helpful changes to emacs (suggested by 'corfu' and 'verigo').
(keymap-global-unset "C-z")
(use-package emacs
  :ensure nil
  :bind
  (("C-z"   . shell)
   ("C-c x" . toggle-frame-maximized)
   ("C-c (" . check-parens)
   ("C-c n" . display-line-numbers-mode)
   ("C-c N" . global-display-line-numbers-mode)
   ("C-c r" . restart-emacs))
  :custom
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  :config
  (context-menu-mode t))

(provide 'user-interface-config)
;;; user-interface-config.el ends here