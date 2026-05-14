;;; 14-misc-packages.el --- Misc & Dashboard -*- lexical-binding: t; -*-
;;; Packages included:
;; dashboard, emacs-everywhere, free-keys, telega

;;; Commentary:
;; Packages that don't fit nicely into another category or, as is the case with
;; dashboard, benefit from loading near the end of the startup process.

;;; Code:
;; =======  MISC  =======
;; `telega' - (chat in Emacs)
;; `free-keys' (buffer of available keybinds)
;; `popper' (keep certain buffers hidden, but within arm's reach)
;; `emacs-everywhere'
;; ======================
(declare-function user/function-after-emacsclient-frame "01-bootstrap-core.el")
(use-package telega
  :defer t
  :bind ("C-c g" . telega)
  :functions
  telega-mode-line-mode user/telega-setup telega-appindicator-mode
  telega-auto-download-mode telega-autoplay-mode telega-chat-auto-fill-mode
  telega-highlight-text-mode telega-notifications-mode telega-root-auto-fill-mode
  telega-transient-keymaps-mode
  
  :init
  (setq telega-use-images t)
  (defun user/telega-setup (&optional frame)
    "Define settings for telega."
    (with-selected-frame (or frame (selected-frame))
      (when (display-graphic-p)
        (telega-mode-line-mode 1))))
  (if (daemonp)
      (add-hook 'after-make-frame-functions #'user/telega-setup)
    (add-hook 'telega-load-hook #'user/telega-setup))

  :config
  (telega-appindicator-mode 1)
  (telega-auto-download-mode 1)
  (telega-autoplay-mode 1)
  (telega-chat-auto-fill-mode 1)
  (telega-highlight-text-mode 1)
  (telega-notifications-mode 1)
  (telega-root-auto-fill-mode 1)
  (telega-transient-keymaps-mode 1)
  
  (message "Telega loaded successfully."))

(use-package free-keys
  :defer t
  :bind ("C-c C-=" . free-keys))

(keymap-global-unset "M-'")
(use-package popper
  :functions
  popper-toggle popper-cycle popper-toggle-type
  :custom
  (popper-reference-buffers
   '("\\*Messages\\*" "Output\\*$" "\\*Async Shell Command\\*" help-mode
     helpful-mode compilation-mode "^\\*mistty.*\\*$" mistty-mode
     "^\\*vterm.*\\*$" vterm-mode "^\\*ghostel.*\\*$" ghostel-mode
     "^\\*eat.*\\*$" eat-mode free-keys-mode))
  :config
  (popper-mode +1)
  (popper-echo-mode +1)
  (bind-keys
   ("C-'"   . popper-toggle)
   ("M-'"   . popper-cycle)
   ("C-M-'" . popper-toggle-type)))

;; Configuration is done primarly in DE.
(use-package emacs-everywhere
  :config
  ;; Customizing the frame appearance for a "popup" feel
  (setq emacs-everywhere-frame-parameters
        '((name . "emacs-everywhere") (width . 80) (height . 20)
	  (menu-bar-lines . 0) (tool-bar-lines . 0)
	  (vertical-scroll-bars . nil))))


;; =======  DASHBOARD  =======
(use-package dashboard
  :demand t
  :functions
  dashboard-insert-startupify-lists dashboard-initialize
  dashboard-setup-startup-hook dashboard-refresh-buffer
  dashboard-display-icons-p

  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-display-icons-p t)
  (dashboard-set-file-icons t)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-banner-logo-title "Welcome back")
  (dashboard-projects-backend 'project-el)
  (dashboard-items `((agenda   . 5)
		     (projects . ,(length (project-known-project-roots)))
		     (recents  . 5)))
  
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook)

  (add-hook 'server-after-make-frame-hook
	    #'(lambda ()
		(user/function-after-emacsclient-frame
		 #'dashboard-refresh-buffer))))


(provide '14-misc-packages)
;;; 14-misc-packages.el ends here
