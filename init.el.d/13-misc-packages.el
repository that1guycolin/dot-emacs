;;; 13-misc-packages.el --- Misc & Dashboard -*- lexical-binding: t; -*-

;;; Packages included:
;; dashboard, emacs-everywhere free-keys, mistty, telega, vterm, with-editor

;;; Commentary:
;; Packages that don't fit nicely into another category or, as is the case with
;; dashboard, benefit from loading near the end of the startup process.

;;; Code:
;; =======  SHELLS  =======
;; `mistty' (comit layer)
;; `vterm' (fully functional terminal)
;; ========================
(use-package mistty
  :bind ("C-c s m" . mistty)
  :functions mistty-send-key
  :defines mistty-prompt-map
  :config
  (bind-keys
   :map mistty-prompt-map
   ("M-<up>" . mistty-send-key)
   ("M-<down>" . mistty-send-key)
   ("M-<left>" . mistty-send-key)
   ("M-<right>" . mistty-send-key)))

(use-package vterm
  :defer t
  :bind
  (("C-c s v" . vterm)
   ("C-c s V" . vterm-other-window)))

(defvar user/ghostel-directory
  (expand-file-name "other/ghostel" user-emacs-directory)
  "Location of cloned repo for package `ghostel'.")

(unless (file-exists-p user/ghostel-directory)
  (call-process "git" nil "*Git Clone Output*" nil "clone" "--recurse-submodules"
		"https://github.com/dakra/ghostel.git" user/ghostel-directory))

(use-package ghostel
  :ensure nil
  :load-path user/ghostel-directory
  :bind ("C-c s g" . ghostel)
  :init
  (setq ghostel-module-auto-install nil)
  :config
  (unless (file-exists-p
	   (expand-file-name "ghostel-module.so" user/ghostel-directory))
    (ghostel-module-compile)))

(use-package with-editor
  :hook
  ((shell-mode  . with-editor-export-editor)
   (eshell-mode . with-editor-export-editor)
   (vterm-mode  . with-editor-export-editor)))


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
  (dashboard-projects-backend 'projectile)
  (dashboard-items `((agenda   . 5)
		     (projects . ,(length projectile-known-projects))
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


(provide '13-misc-packages)
;;; 13-misc-packages.el ends here
