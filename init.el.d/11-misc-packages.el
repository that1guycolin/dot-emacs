;;; 11-misc-packages.el --- Misc & Dashboard -*- lexical-binding: t; -*-

;;; Packages included:
;; dashboard, emacs-everywhere, mistty, popper, vterm

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


;; =======  MISC  =======
;; `popper' (toggle popups)
;; `emacs-everywhere'
;; =========================
(use-package popper
  :defer t
  :bind ("C-c P" . popper-mode)
  :functions
  popper-mode
  popper-echo-mode
  popper-toggle
  popper-cycle
  popper-toggle-type
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

;; Configuration is done primarly in DE.
(use-package emacs-everywhere)


;; =======  TRANSIENT  =======
(use-package transient
  :functions
  user/projectile-treemacs-anywhere-dispatch
  user/llm-dispatch
  :config
  (transient-define-prefix
   user/projectile-treemacs-anywhere-dispatch ()
   "Globally available commands for Treemacs & Projectile."
   [
    ["Treemacs" :pad-keys t
     ("t" "Toggle" treemacs)
     ("T" "Refresh" treemacs-refresh)
     ("j" "treemacs-projectile" treemacs-projectile)]
    
    ["Treemacs - Current View"
     ("v f" "Focus to active file" treemacs-find-file)
     ("v p" "Add project" treemacs-add-project-to-workspace)
     ("v a" "Add active project"
      treemacs-add-and-display-current-project)
     ("v c" "Collapse" treemacs-collapse-all-projects)
     ("v r" "Reset view (current project only)"
      treemacs-add-and-display-current-project-exclusively)]
    
    ["Treemacs - Workspaces"
     ("w e" "Edit" treemacs-edit-workspaces)
     ("w s" "Switch" treemacs-switch-workspace)
     ("w n" "New" treemacs-create-workspace)
     ("w r" "Rename" treemacs-rename-workspace)
     ("w d" "Delete" treemacs-remove-workspace)]
    
    ["Projectile"
     ("i" "Info" projectile-project-info)
     ("o" "Switch to p" projectile-switch-project)
     ("s" "Switch to open p" projectile-switch-open-project)
     ("d" "Open p in dired/dirvish" projectile-dired)
     ("r" "Recent p files" projectile-recentf)]
    [""
     ("n" "Next p buffer" projectile-next-project-buffer)
     ("p" "Previous p buffer" projectile-previous-project-buffer)
     ("S" "Save all p buffers" projectile-save-project-buffers)
     ("X" "Kill all p buffers" projectile-kill-buffers)
     ("f" "Find references in p" projectile-find-references)]
    [""
     ("h" "Replace in p" projectile-replace)
     ("g" "Ripgrep search in p" projectile-ripgrep)
     ("m" "MisTTY Buffer @ p root" mistty-in-project)
     ("C" "Clear known \'p\'s" projectile-clear-known-projects)
     ("R" "Reset known \'p\'s"
      projectile-reset-known-projects)]])

  (transient-define-prefix
   user/llm-dispatch ()
   "Commands to interact with LLMs in Emacs."
   ["Gptel"
    ("g ." "Activate @ cursor" gptel-send)
    ("g b" "Chat buffer" gptel)
    ("g s" "Switch backend" user/switch-gptel-backend)])
  
  (bind-keys
   ("C-c t" . user/projectile-treemacs-anywhere-dispatch)
   ("C-c C-a" . user/llm-dispatch)))


;; =======  DASHBOARD  =======
(use-package dashboard
  :demand t
  :functions
  dashboard-insert-startupify-lists
  dashboard-initialize
  dashboard-setup-startup-hook
  dashboard-refresh-buffer
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-banner-logo-title "Welcome back")
  (dashboard-items '((agenda . 10)
                     (recents  . 5)))
  :config
  (when (featurep 'projectile)
    (setq dashboard-projects-backend 'projectile
	  dashboard-items '((agenda . 10)
			    (projects . 5)
			    (recents . 5))))
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook)
  (setq initial-buffer-choice "*dashboard*")
  (add-hook 'after-make-frame-functions
            (lambda (frame)
              (with-selected-frame frame
		(dashboard-refresh-buffer)
                (setq initial-buffer-choice "*dashboard*")))))


(provide '11-misc-packages)
;;; 11-misc-packages.el ends here
