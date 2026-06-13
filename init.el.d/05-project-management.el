;;; 05-project-management.el --- Projects & Workspaces -*-lexical-binding: t; -*-

;;; Packages included:
;; activities, consult-project-extra, deadgrep, disproject, docker, project,
;; rg, treemacs, treemacs-nerd-icons

;;; Commentary:
;; Support project functionality in Emacs.  Git integration for said projects
;; occurs in "09-git-tools.el".

;;; Code:
;; =======  PROJECTS  =======
;; `project.el' (management)
;; `disproject' (transient dispatch for project.el)
;; `consult-project-extra' (integration)
;; `deadgrep' (global ripgrep search)
;; `rg' (project ripgrep search & more)
;; `activities' (save frame-state)
;; `docker' (Docker support)
;; ==========================
(use-package project
  :ensure nil
  :demand t
  :preface
  (defvar user/projects-directory)
  (defvar user/scripts-directory)
  (defvar org-directory)
  (defvar user-emacs-directory)

  (defun user/project-reset-projects ()
    "Clear the project list and repopulate it."
    (interactive)
    (dolist (project (project-known-project-roots))
      (project-forget-project project))
    (message "Cleared all projects")
    ;; Scan these directories recursively
    (dolist (dir (list user/projects-directory user/scripts-directory))
      (project-remember-projects-under dir t))
    ;; Scan these directories (but not their subdirectories)
    (dolist (dir (list user-emacs-directory org-directory "~/dotfiles"))
      (project-remember-projects-under (expand-file-name dir)))
    (message "Successfully repopulated projects list"))

  :functions project-remember-projects-under
  :custom
  (project-list-exclude
   (list (regexp-quote (expand-file-name elpaca-directory))
	 (regexp-quote (expand-file-name "~/dotfiles/terminals/alacritty"))))
  (project-vc-ignores '("^node_modules$" "^\\.venv$" "^\\.uv$")))

(use-package disproject
  :defer t
  :preface
  (keymap-global-unset "C-x p")
  :bind (:map ctl-x-map
	      ("p" . disproject-dispatch)))

(use-package consult-project-extra
  :after (consult project)
  :bind
  (("C-c p f" . consult-project-extra-find)
   ("C-c p o" . consult-project-extra-find-other-window))
  :custom
  (consult-project-function #'consult-project-extra-project-fn)
  :config
  (transient-append-suffix 'disproject-dispatch "&"
    '("C f" "Consult Project Find" consult-project-extra-find))
  (transient-append-suffix 'disproject-dispatch "C f"
    '("C o" "C. P. Find Other Window" consult-project-extra-find-other-window)))

(use-package activities
  :defer t
  :preface
  (defvar edebug-inhibit-emacs-lisp-mode-bindings t)
  (setq edebug-inhibit-emacs-lisp-mode-bindings t)

  (defvar-keymap user/activities-map
    :prefix t
    :doc "Functions from the package activities.el"
    "n" #'activities-new
    "d" #'activities-define
    "r" #'activities-resume
    "p" #'activities-suspend
    "k" #'activities-kill
    "s" #'activities-switch
    "b" #'activities-switch-buffer
    "v" #'activities-revert
    "l" #'activities-list)
  :bind-keymap ("C-x C-a" . user/activities-map)
  :functions
  activities-new activities-define activities-resume activities-suspend
  activities-kill activities-switch activities-switch-buffer activities-revert
  activities-list activities-mode activities-tabs-mode

  :init
  (activities-mode 1)
  (activities-tabs-mode 1))

(use-package docker
  :defer t
  :bind ("C-c D" . docker)
  :custom
  (docker-command "podman"))

(use-package deadgrep
  :defer t
  :bind
  (("<f5>"    . deadgrep)
   ("C-c C-r" . deadgrep)))

(use-package rg
  :defer t
  :bind (("C-c g" . rg-menu)
	 :map isearch-mode-map
	 ("M-s r" . rg-isearch-menu))
  :config
  (require 'rg-isearch))


;; =======  TREEMACS  =======
;; `treemacs' (functional side panel)
;; `project-treemacs' (project.el + treemacs integration)
;; `treemacs-nerd-icons' (nerd-icons + treemacs integration)
;; ==========================
(use-package treemacs
  :defer t
  :preface
  (defun user/treemacs-switch-workspace-focus ()
    "Run `treemacs-switch-workspace' and ensure the Treemacs window is focused.
The ending behaviour, where treemacs is selected, then unselected, then
selected again,"
    (interactive)
    (call-interactively #'treemacs-switch-workspace)
    (let ((treemacs-win (treemacs-get-local-window)))
      (when (and treemacs-win (not (eq treemacs-win (selected-window))))
	(select-window treemacs-win)
	(when (fboundp 'treemacs-project-follow-mode)
	  (other-window 1))
	(select-window treemacs-win))))

  (defun user/toggle-gitignored-wait-2 (&rest _args)
    "Toggle `treemacs-hide-gitignored-files-mode' if treemacs window.
Wait two seconds before activating the mode."
    (pcase (treemacs-current-visibility)
      ('visible
       (run-at-time 2 nil
		    #'(lambda ()
			(treemacs-hide-gitignored-files-mode 1))))
      ('exists
       (run-at-time 2 nil
		    #'(lambda ()
			(treemacs-hide-gitignored-files-mode 1))))
      ('none (ignore))))
  (advice-add 'treemacs :after #'user/toggle-gitignored-wait-2)

  (defun user/close-treemacs (&rest _args)
    "If a treemacs window exists, close it."
    (when (eq 'visible (treemacs-current-visibility))
      (treemacs)))

  (defvar user/project-treemacs-anywhere-dispatch)
  (transient-define-prefix
    user/project-treemacs-anywhere-dispatch ()
    "Globally available commands for Treemacs & Project.el."
    ["Treemacs" :pad-keys t
     ["Project"
      ("t" "Toggle"                    treemacs)
      ("T" "Refresh"                   treemacs-refresh)
      ("d" "Disproject"                disproject-dispatch)
      ("r" "Rename Project"            treemacs-rename-project)]

     ["View"
      ("v f" "Focus to active file"    treemacs-find-file)
      ("v p" "Add Project"             treemacs-add-project-to-workspace)
      ("v c" "Collapse Other Projects" treemacs-collapse-other-projects)
      ("v C" "Collapse"                treemacs-collapse-all-projects)
      ("v r" "Current Project Only"    treemacs-create-workspace-from-project)]
     
     ["Workspace" :pad-keys t
      ("w e" "Edit"                    treemacs-edit-workspaces)
      ("w s" "Switch"                  user/treemacs-switch-workspace-focus)
      ("w n" "New"                     treemacs-create-workspace)
      ("w r" "Rename"                  treemacs-rename-workspace)
      ("w d" "Delete"                  treemacs-remove-workspace)]]

    ["Project.el" :pad-keys t
     ["Search"
      ("x" "Project Find Regexp"       project-find-regexp)
      ("q" "Project Replace Regexp"    project-query-replace-regexp)
      ("f" "Project Find File"         project-find-file)
      ("s" "Project Search"            project-search)
      ("a" "Add Project"               (lambda () (interactive)
				         (call-interactively
				          #'project-remember-project)))]
     
     ["Shell"
      ("S" "Project Shell"             project-shell)
      ("E" "Project EShell"            project-eshell)
      ("A" "Project Async Shell Cmd"   project-async-shell-command)
      ("C" "Project Shell Cmd"         project-shell-command)]
     
     ["Other"
      ("D" "Set Project Dir-Locals"    project-customize-dirlocals)
      ("R" "Ripgrep Project"           rg-project)
      ("G" "DWIM Ripgrep Project"      rg-dwim-project-dir)
      ("Z" "Forget Zombie Projects"    project-forget-zombie-projects)
      ("p r" "Reset Known Projects"    user/project-reset-projects)]])

  :bind
  (("C-c t"       . user/project-treemacs-anywhere-dispatch)
   :map treemacs-mode-map
   ("C-x j"       . treemacs-project-follow-mode)
   ("<backspace>" . treemacs-root-up))
  :commands treemacs treemacs-refresh
  :functions
  treemacs-filewatch-mode treemacs-git-mode treemacs-git-commit-diff-mode
  treemacs-select-window treemacs-project-follow-mode treemacs-root-up
  treemacs-get-local-window treemacs-hide-gitignored-files-mode
  treemacs--select-workspace-by-name treemacs-switch-workspace
  :defines treemacs-mode-map

  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)

  :config
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-git-commit-diff-mode 1)
  (treemacs-project-follow-mode 1)
  (advice-add 'disproject-dispatch :before #'user/close-treemacs))

(use-package treemacs-nerd-icons
  :after treemacs
  :functions treemacs-nerd-icons-config
  :config
  (treemacs-nerd-icons-config))


(provide '05-project-management)
;;; 05-project-management.el ends here
