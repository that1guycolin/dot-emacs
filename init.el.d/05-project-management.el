;;; 05-project-management.el --- Project management and file navigation -*- lexical-binding: t; -*-

;;; Packages included:
;; deadgrep, disproject, editorconfig, perspective, perspective-project-bridge,
;; project, project-treemacs, rg, treemacs, treemacs-nerd-icons,
;; treemacs-perspective

;;; Commentary:
;; Support project functionality in Emacs.  Git integration for said projects
;; occurs in step 7.

;;; Code:
;; =======  PROJECT SUPPORT  =======
;; `project.el' (project manager)
;; `disproject' (transient dispatch for project.el)
;; `deadgrep' (global ripgrep search)
;; `rg' (project ripgrep search & more)
;; `perspective' (separate workspaces for separate projects)
;; `perspective-project-bridge' (integrate project.el & perspective)
;; `editorconfig' (support .editorconfig)
;; =================================
(defvar user/projects-directory)
(defvar user/scripts-directory)
(defvar org-directory)
(defvar user-emacs-directory)

(use-package project
  :ensure nil
  :functions
  project-remember-projects-under
  :custom
  (project-list-exclude
   (list (concat "^" (regexp-quote (expand-file-name elpaca-directory)))))
  :config
  (dolist (dir '("^node_modules$" "^\\.venv$" "^\\.uv$"))
    (add-to-list 'project-vc-ignores dir))
  
  (defun user/project-reset-projects ()
    "Clear the project list and repopulate it."
    (interactive)
    (dolist (project (project-known-project-roots))
      (project-forget-project project))
    (message "Cleared all projects")
    (dolist (dir `(,user/projects-directory
		   ,user/scripts-directory
		   ,org-directory
		   ,(expand-file-name user-emacs-directory)))
      (project-remember-projects-under dir t))
    (message "Successfully repopulated projects list")))

(dolist (keybind '("C-x b" "C-x k" "C-x C-b" "C-x p"))
  (keymap-global-unset keybind))

(use-package disproject
  :defer t
  :bind (:map ctl-x-map
              ("p" . disproject-dispatch)))

(use-package deadgrep
  :defer t
  :bind
  (("<f5>" . deadgrep)
   (:map ctl-x-map
	 ("C-g" . deadgrep))))

(use-package rg
  :defer t
  :bind ("C-c s" . rg-menu)
  :config
  (require 'rg-isearch)
  (declare-function rg-isearch-menu "rg-isearch")
  (bind-keys
   :map isearch-mode-map
   ("M-s r" . rg-isearch-menu)))

(defvar ibuffer-sorting-mode)
(declare-function ibuffer-do-sort-by-alphabetic "ibuffer")
(use-package perspective
  :bind
  (("C-x b"   . persp-switch-to-buffer*)
   ("C-x C-b" . persp-ibuffer)
   ("C-x k"   . persp-kill-buffer*)
   ("C-x C-B" . persp-buffer-menu))
  :functions
  persp-mode persp-is-current-buffer persp-ibuffer-set-filter-groups
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  (persp-switch-to-buffer-behavior 'switch)
  :init
  (persp-mode 1)
  (setq switch-to-prev-buffer-skip
	(lambda (win buff bury-or-kill)
          (not (persp-is-current-buffer buff))))
  (add-hook 'ibuffer-hook
            (lambda ()
	      (persp-ibuffer-set-filter-groups)
	      (unless (eq ibuffer-sorting-mode 'alphabetic)
		(ibuffer-do-sort-by-alphabetic))))
  (require 'bs)
  (keymap-global-set "C-x B" #'(lambda (arg)
                                 (interactive "P")
                                 (if (fboundp 'persp-bs-show)
                                     (persp-bs-show arg)
                                   (bs-show "all")))))

(use-package perspective-project-bridge
  :hook (persp-mode . perspective-project-bridge-mode)
  :functions
  perspective-project-bridge-find-perspectives-for-all-buffers
  perspective-project-bridge-kill-perspectives
  :init
  (add-hook 'perspective-project-bridge-mode-hook
	    (lambda ()
	      (if perspective-project-bridge-mode
		  (perspective-project-bridge-find-perspectives-for-all-buffers)
		(perspective-project-bridge-kill-perspectives)))))

(use-package editorconfig
  :hook ((prog-mode . editorconfig-mode)
	 (text-mode . editorconfig-mode)))


;; =======  TREEMACS  =======
;; `treemacs' (functional side panel)
;; `project-treemacs' (project.el + treemacs integration)
;; `treemacs-perspective' (perspective + treemacs integration)
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

(use-package project-treemacs
  :after treemacs
  :functions project-treemacs-mode
  :config
  (project-treemacs-mode 1))

(use-package treemacs-perspective
  :after treemacs)

(use-package treemacs-nerd-icons
  :after treemacs
  :functions treemacs-nerd-icons-config
  :config
  (treemacs-nerd-icons-config))

(defvar user/project-treemacs-anywhere-dispatch nil)
(transient-define-prefix
  user/project-treemacs-anywhere-dispatch ()
  "Globally available commands for Treemacs & Project.el."
  [
   ["Treemacs" :pad-keys t
    ("t" "Toggle" treemacs)
    ("T" "Refresh" treemacs-refresh)
    ("A" "Add P" (lambda () (interactive)
		   (call-interactively #'project-remember-project)))
    ("R" "Rename P" treemacs-rename-project)
    ("o" "Switch P" project-switch-project)]

   ["Treemacs - Current View"
    ("v f" "Focus to active file" treemacs-find-file)
    ("v p" "Add P" treemacs-add-project-to-workspace)
    ("v c" "Collapse Other Ps" treemacs-collapse-other-projects)
    ("v C" "Collapse" treemacs-collapse-all-projects)
    ("v r" "Current P Only"
     treemacs-create-workspace-from-project)]
   
   ["Treemacs - Workspaces"
    ("w e" "Edit" treemacs-edit-workspaces)
    ("w s" "Switch" user/treemacs-switch-workspace-and-focus)
    ("w n" "New" treemacs-create-workspace)
    ("w r" "Rename" treemacs-rename-workspace)
    ("w d" "Delete" treemacs-remove-workspace)]
   
   ["Project.el"
    ("f r" "P Find Regexp" project-find-regexp)
    ("q" "P Replace Regexp" project-query-replace-regexp)
    ("s" "P Search" project-search)
    ("d" "P in Dirvish" project-dired)
    ("f f" "P Find File" project-find-file)]
   
   ["Project Shell"
    ("S" "P Shell" project-shell)
    ("e" "P EShell" project-shell)
    ("a" "P Async Shell Command" project-async-shell-command)
    ("c" "P Shell Command" project-shell-command)
    ("m" "MisTTY @ P root" mistty-in-project)]
   
   ["Other Project Functions"
    ("D" "Set P Dir-Locals" project-customize-dirlocals)
    ("r" "Ripgrep P" rg-project)
    ("g" "DWIM Ripgrep P" rg-dwim-project-dir)
    ("z" "Forget Zombie Ps" project-forget-zombie-projects)
    ("p r" "Reset Known Ps" user/project-reset-projects)]])
(keymap-global-set "C-c t" #'user/project-treemacs-anywhere-dispatch)


(provide '05-project-management)
;;; 05-project-management.el ends here
