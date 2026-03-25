;;; 13-misc-packages.el --- Misc & Dashboard -*- lexical-binding: t; -*-

;;; Packages included:
;; dashboard, emacs-everywhere, free-keys, mistty, popper, transient, vterm,
;; with-editor

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

(use-package with-editor
  :hook
  ((shell-mode  . with-editor-export-editor)
   (eshell-mode . with-editor-export-editor)
   (vterm-mode  . with-editor-export-editor)
   (term-exec   . with-editor-export-editor))
  :config
  (defun user/emacsclient-for-session ()
    "If XDG_DESKTOP_SESSION = \"wayland\", use the Emacs pgtk build.
Otherwise, use the lucid build."
    (let ((session-type (getenv "XDG_SESSION_TYPE")))
      (if (and session-type (string= session-type "wayland"))
          (setq with-editor-emacsclient-program-suffixes (list "-pgtk"))
	(setq  with-editor-emacsclient-program-suffixes (list "-lucid"))
	(or session-type "Unknown")))))


;; =======  MISC  =======
;; `telega' - (chat in Emacs)
;; `popper' (toggle popups)
;; `free-keys' (buffer of available keybinds)
;; `emacs-everywhere'
;; ======================
(use-package telega
  :commands telega
  :functions
  telega-mode-line-mode
  user/telega-daemon-setup
  :defer t
  :init
  (setq telega-use-images t)

  (defun user/telega-daemon-setup (&optional frame)
    "Define settings for telega when running Emacs in daemon-mode."
    (with-selected-frame (or frame (selected-frame))
      (when (display-graphic-p)
        (telega-mode-line-mode 1))))

  (if (daemonp)
      (add-hook 'after-make-frame-functions #'user/telega-daemon-setup)
    (add-hook 'telega-load-hook #'user/telega-daemon-setup))

  :config
  (setq telega-completing-read-function 'completing-read
        telega-notifications-mode t)
  (message "Telega loaded successfully."))

(use-package popper
  :defer t
  :bind ("C-c P" . popper-mode)
  :functions
  popper-mode
  popper-echo-mode
  popper-toggle
  popper-cycle
  popper-toggle-type

  :defines popper-mode-map
  
  :custom
  (popper-reference-buffers
   '("\\*Messages\\*"
     "Output\\*$"
     "\\*Async Shell Command\\*"
     help-mode
     compilation-mode))

  :config
  (popper-mode +1)
  (popper-echo-mode +1)
  (bind-keys
   :map popper-mode-map
   ("C-`"   . popper-toggle)
   ("M-`"   . popper-cycle)
   ("C-M-`" . popper-toggle-type)))

(use-package free-keys
  :defer t
  :commands free-keys)

;; Configuration is done primarly in DE.
(use-package emacs-everywhere)


;; =======  DASHBOARD  =======
(use-package dashboard
  :demand t
  
  :functions
  dashboard-insert-startupify-lists
  dashboard-initialize
  dashboard-setup-startup-hook
  dashboard-open
  user/smart-dashboard-items
  user/dashboard-cleanup-org-buffers
  user/emacsclient-dashboard

  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-banner-logo-title "Welcome back")

  :config
  (defun user/smart-dashboard-items ()
    "Set dashboard items based on whether or not projectile is loaded."
    (if (featurep 'projectile)
	(progn
	  (setq dashboard-projects-backend 'projectile
		dashboard-items '(
				  ;; (agenda . 10)
				  (projects . 5)
				  (recents . 5))))
      (progn
	(setq dashboard-items '(
				;; (agenda . 10)
				(recents . 10))))))
  (user/smart-dashboard-items)
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook)

  (defun user/dashboard-cleanup-org-buffers ()
    "Close any `org-agenda' buffers that are open but unmodified."
    (interactive)
    (let ((agenda-files (mapcar #'expand-file-name (org-agenda-files))))
      (dolist (buf (buffer-list))
        (let ((file (buffer-file-name buf)))
          (when (and file
                     (member (expand-file-name file) agenda-files)
                     (not (buffer-modified-p buf))
                     (not (get-buffer-window buf)))
            (progn
	      (kill-buffer buf)
	      (message "Cleaned org-agenda buffers.")))))))
  (bind-keys
   :map dashboard-mode-map
   ("c" . user/dashboard-cleanup-org-buffers))
  
  (defun user/emacsclient-dashboard (frame)
    "Show the dashboard every time a new FRAME is opened."
    (with-selected-frame frame
      (user/smart-dashboard-items)
      (dashboard-open)))
  (add-hook 'after-make-frame-functions #'user/emacsclient-dashboard))

(provide '13-misc-packages)
;;; 13-misc-packages.el ends here
