;;; 05-project-management.el --- Project management and file navigation -*- lexical-binding: t; -*-

;; Packages included:
;; disproject, editorconfig, projectile, treemacs, treemacs-nerd-icons,
;; treemacs-projectile

;;; Commentary:
;; Support project functionality in Emacs.  Git integration for said projects
;; occurs in step 7.

;;; Code:
;; =======  PROJECT SUPPORT  =======
;; `disproject' (transient dispatch for project.el)
;; `editorconfig' (support .editorconfig)
;; =================================

  :custom
  :config
  (dolist (dir '("^node_modules$" "^\\.venv$" "^\\.uv$"))
  
(use-package disproject
  :defer t
  :bind (:map ctl-x-map
              ("p" . disproject-dispatch)))

  (bind-keys

(use-package editorconfig
  :hook ((prog-mode . editorconfig-mode)
	 (text-mode . editorconfig-mode)))


;; =======  TREEMACS  =======
;; `treemacs' (functional side panel)
;; `treemacs-projectile' (projectile + treemacs integration)
;; `treemacs-nerd-icons' (nerd-icons + treemacs integration)
;; ==========================
(use-package treemacs
  :commands treemacs treemacs-refresh
  :defer t

  :functions
  treemacs-filewatch-mode treemacs-git-mode treemacs-git-commit-diff-mode
  treemacs-select-window treemacs-project-follow-mode treemacs-root-up
  treemacs-get-local-window treemacs-hide-gitignored-files-mode
  treemacs--select-workspace-by-name treemacs-switch-workspace
  user/treemacs-switch-workspace-and-focus

  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)

  :config
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-git-commit-diff-mode 1)
  (add-hook 'treemacs-post-buffer-init-hook
	    #'treemacs-hide-gitignored-files-mode)

  (defun user/treemacs-switch-workspace-and-focus ()
    "Run `treemacs-switch-workspace' and ensure the Treemacs window is focused."
    (interactive)
    (call-interactively #'treemacs-switch-workspace)
    (let ((treemacs-win (treemacs-get-local-window)))
      (when (and treemacs-win (not (eq treemacs-win (selected-window))))
	(select-window treemacs-win))))
  
  (bind-keys
   :map treemacs-mode-map
   ("C-x p f" . treemacs-project-follow-mode)
   ("<backspace>" . treemacs-root-up)))

  :after treemacs)

(use-package treemacs-nerd-icons
  :after treemacs
  :functions treemacs-nerd-icons-config
  :config
  (treemacs-nerd-icons-config))

(transient-define-prefix
  [
   ["Treemacs" :pad-keys t
    ("t" "Toggle" treemacs)
    ("T" "Refresh" treemacs-refresh)

   ["Treemacs - Current View"
    ("v f" "Focus to active file" treemacs-find-file)
   
   ["Treemacs - Workspaces"
    ("w e" "Edit" treemacs-edit-workspaces)
    ("w s" "Switch" user/treemacs-switch-workspace-and-focus)
    ("w n" "New" treemacs-create-workspace)
    ("w r" "Rename" treemacs-rename-workspace)
    ("w d" "Delete" treemacs-remove-workspace)]
   


(provide '05-project-management)
;;; 05-project-management.el ends here
