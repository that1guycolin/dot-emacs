;;; 14-misc-packages.el --- Misc & Dashboard -*- lexical-binding: t; -*-

;;; Packages included:
;; dashboard, emacs-everywhere free-keys, mistty, telega, vterm, with-editor

;;; Commentary:
;; Packages that don't fit nicely into another category or, as is the case with
;; dashboard, benefit from loading near the end of the startup process.

;;; Code:
;; =======  MISC  =======
;; `telega' - (chat in Emacs)
;; `popper' (toggle popups)
;; `free-keys' (buffer of available keybinds)
;; `emacs-everywhere'
;; ======================
(use-package telega
  :bind ("C-c g" . telega)
  :functions
  telega-mode-line-mode
  user/telega-setup
  telega-notifications-mode
  :defer t
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
  (setq telega-completing-read-function 'completing-read)
  (telega-notifications-mode 1)
  (message "Telega loaded successfully."))

(use-package free-keys
  :defer t
  :bind ("C-c C-=" . free-keys))

;; Configuration is done primarly in DE.
(use-package emacs-everywhere
  :config
  ;; Customizing the frame appearance for a "popup" feel
  (setq emacs-everywhere-frame-parameters
        '((name . "emacs-everywhere")
          (width . 80)
          (height . 20)
          (menu-bar-lines . 0)
          (tool-bar-lines . 0)
          (vertical-scroll-bars . nil))))


;; =======  DASHBOARD  =======
(use-package dashboard
  :demand t
  
  :functions
  dashboard-insert-startupify-lists dashboard-initialize
  dashboard-setup-startup-hook dashboard-refresh-buffer
  dashboard-display-icons-p user/dashboard-cleanup-org-buffers
  user/emacsclient-dashboard

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

  (bind-keys
   :map dashboard-mode-map
   ("c" . user/dashboard-cleanup-org-buffers))
  
  (defun user/emacsclient-dashboard (frame)
    "Show the dashboard every time a new FRAME is opened."
    (with-selected-frame frame
      (dashboard-refresh-buffer)))
  (add-hook 'after-make-frame-functions #'user/emacsclient-dashboard))


(provide '14-misc-packages)
;;; 14-misc-packages.el ends here
