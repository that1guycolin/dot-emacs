;;; 05-project-management.el --- Project management and file navigation -*- lexical-binding: t; -*-

;;; Packages included:
;; deadgrep, disproject, editorconfig, perspective, perspective-project-bridge,
;; project, project-treemacs, rg, treemacs, treemacs-nerd-icons,
;; treemacs-perspective

;;; Commentary:
;; Support project functionality in Emacs.  Git integration for said projects
;; occurs in "09-git-tools.el".

;;; Code:
;; =======  PROJECT SUPPORT  =======
;; `project.el' (project manager)
;; `disproject' (transient dispatch for project.el)
;; `deadgrep' (global ripgrep search)
;; `rg' (project ripgrep search & more)
;; `perspective' (separate workspaces for separate projects)
;; `perspective-project-bridge' (integrate project.el & perspective)
;; `docker' (Docker support for Emacs)
;; =================================
(defvar user/projects-directory)
(defvar user/scripts-directory)
(defvar org-directory)
(defvar user-emacs-directory)

(use-package project
  :ensure nil
  :functions
  project-remember-projects-under project-prompt-project-dir

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
		   "~/dotfiles"
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
  (("<f5>"  . deadgrep)
   ("C-c r" . deadgrep)))

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
  :functions
  persp-mode persp-is-current-buffer persp-ibuffer-set-filter-groups
  persp-switch-to-buffer* persp-ibuffer persp-kill-buffer* persp-buffer-menu
  user/buffer-by-filename persp-add-buffer persp-curr persp-switch
  
  :init
  (persp-mode 1)

  :custom
  (persp-mode-prefix-key (kbd "M-p"))
  (persp-switch-to-buffer-behavior 'switch)

  :config
  (setq switch-to-prev-buffer-skip
	(lambda (_win buff _bury-or-kill)
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
                                   (bs-show "all"))))

  (bind-keys
   ("C-x b"   . persp-switch-to-buffer*)
   ("C-x C-b" . persp-ibuffer)
   ("C-x k"   . persp-kill-buffer*)
   ("C-x C-B" . persp-buffer-menu))

  (require 'seq)
  (defun user/buffer-by-filename (loc expr)
    "Filter all buffers whose filename contains EXPR.

LOC can be one of:
:prefix   Match files whose filename starts with EXPR.
:suffix   Match files whose filename ends with EXPR.
:full     Match files whose filename equals EXPR.
:ext      Match files whose extension equals EXPR (do not include the '.').
:contains Match files whose filename contains EXPR."
    (mapcar #'buffer-name
	    (seq-filter
	     (lambda (buf)
	       (let* ((fname (buffer-file-name buf)))
		 (when fname
		   (pcase loc
		     (:prefix (string-prefix-p expr
					       (file-name-nondirectory fname)))
		     (:suffix (string-suffix-p expr
					       (file-name-nondirectory fname)))
		     (:full   (string= expr (file-name-nondirectory fname)))
		     (:ext    (if (string-prefix-p expr ".")
				  (string= expr (file-name-extension fname t))
				(string= expr (file-name-extension fname))))
		     (:contains (string-match-p (regexp-quote expr)
						(file-name-nondirectory fname)))
		     (_ (error "%s is not a valid value for loc" loc))))))
	     (buffer-list))))

  (defun user/add-list-to-persp (loc expr &optional msg)
    "Add list of buffers returned by `user/buffer-by-filename' to active persp.
Takes arguments EXPR and LOC to pass to `user/buffer-by-filename'.
Optionally, override the built-in message by including MSG in the
arguments.  Custom messages can include \"%s\" to insert the buffer name
into the message."
    (interactive
     (list
      (let ((loc-type-alist
	     '(("Filename starts with: " . :prefix)
	       ("Filename ends with: "   . :suffix)
	       ("Filename is equal to: " . :full)
	       ("File has extension: "   . :ext)
	       ("Filename contains: "    . :contains))))
	(cdr
	 (assoc
	  (completing-read "Search style: "
			   (mapcar #'car loc-type-alist) nil t)
	  loc-type-alist)))
      (read-string "Enter string to search for: ")))
    (dolist (buf (user/buffer-by-filename loc expr))
      (persp-add-buffer buf)
      (cond
       ((and msg (string-match-p "\\%s" msg))
	(message msg buf))
       (msg
	(message msg))
       (t
	(message "Added %s" buf))))))

(use-package perspective-project-bridge
  :functions
  perspective-project-bridge-mode
  perspective-project-bridge-find-perspectives-for-all-buffers
  perspective-project-bridge-kill-perspectives user/project-switch-perspective
  :config
  (perspective-project-bridge-mode 1)

  (defun user/project-switch-perspective (&rest _args)
    "Switch to a perspective for the current project."
    (interactive)
    (persp-switch (project-name))
    (perspective-project-bridge-find-perspectives-for-all-buffers))
  (advice-add 'project-switch-project :after #'user/project-switch-perspective))

(use-package docker
  :defer t
  :bind ("C-c D" . docker))


;; =======  TREEMACS  =======
;; `treemacs' (functional side panel)
;; `project-treemacs' (project.el + treemacs integration)
;; `treemacs-perspective' (perspective + treemacs integration)
;; `treemacs-nerd-icons' (nerd-icons + treemacs integration)
;; ==========================
(defvar treemacs-mode-map)
(use-package treemacs
  :commands treemacs treemacs-refresh
  :defer t
  :functions
  treemacs-filewatch-mode treemacs-git-mode treemacs-git-commit-diff-mode
  treemacs-select-window treemacs-project-follow-mode treemacs-root-up
  treemacs-get-local-window treemacs-hide-gitignored-files-mode
  treemacs--select-workspace-by-name treemacs-switch-workspace
  user/treemacs-switch-workspace-and-focus user/toggle-gitignored-wait-2
  user/close-treemacs

  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)

  :config
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-git-commit-diff-mode 1)
  (treemacs-project-follow-mode 1)

  (defun user/treemacs-switch-workspace-and-focus ()
    "Run `treemacs-switch-workspace' and ensure the Treemacs window is focused."
    (interactive)
    (call-interactively #'treemacs-switch-workspace)
    (let ((treemacs-win (treemacs-get-local-window)))
      (when (and treemacs-win (not (eq treemacs-win (selected-window))))
	(select-window treemacs-win))))

  (defun user/toggle-gitignored-wait-2 (&rest _args)
    "Toggle `treemacs-hide-gitignored-files-mode' if treemacs window.
Wait three seconds before activating the mode."
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
    (pcase (treemacs-current-visibility)
      ('visible (treemacs))
      ('exists  (treemacs))
      ('none    (ignore))))

  (advice-add 'disproject-dispatch :before #'user/close-treemacs)
  
  (bind-keys
   :map treemacs-mode-map
   ("C-x p f"     . treemacs-project-follow-mode)
   ("<backspace>" . treemacs-root-up)))

(use-package project-treemacs
  :after treemacs
  :functions project-treemacs-mode
  :config
  (project-treemacs-mode 1))

(use-package treemacs-perspective
  :after treemacs)

(use-package treemacs-nerd-icons
  :ensure
  :after treemacs
  :functions treemacs-nerd-icons-config
  :config
  (treemacs-nerd-icons-config))

(declare-function dirvish "10-file-management.el")
(defun user/project-switch-dirvish ()
  "Switch project, then open Dirvish at the project root."
  (interactive)
  (dirvish (project-prompt-project-dir))
  (persp-switch (project-name (project-current t))))

(defvar user/project-treemacs-anywhere-dispatch nil)
(transient-define-prefix
  user/project-treemacs-anywhere-dispatch ()
  "Globally available commands for Treemacs & Project.el."
  ["Treemacs" :pad-keys t
   ["Project"
    ("t" "Toggle" treemacs)
    ("T" "Refresh" treemacs-refresh)
    ("d" "Disproject" disproject-dispatch)
    ("r" "Rename Project" treemacs-rename-project)
    ("c" "Change Project" (lambda () (interactive)
			    (call-interactively
			     #'user/project-switch-dirvish)))]

   ["View"
    ("v f" "Focus to active file" treemacs-find-file)
    ("v p" "Add Project" treemacs-add-project-to-workspace)
    ("v c" "Collapse Other Projects" treemacs-collapse-other-projects)
    ("v C" "Collapse" treemacs-collapse-all-projects)
    ("v r" "Current Project Only"
     treemacs-create-workspace-from-project)]
   
   ["Workspace"
    ("w e" "Edit" treemacs-edit-workspaces)
    ("w s" "Switch" user/treemacs-switch-workspace-and-focus)
    ("w n" "New" treemacs-create-workspace)
    ("w r" "Rename" treemacs-rename-workspace)
    ("w d" "Delete" treemacs-remove-workspace)]]

  ["Project.el" :pad-keys t
   ["Search"
    ("x" "Project Find Regexp" project-find-regexp)
    ("q" "Project Replace Regexp" project-query-replace-regexp)
    ("f" "Project Find File" project-find-file)
    ("s" "Project Search" project-search)
    ("a" "Add Project" (lambda () (interactive)
			 (call-interactively #'project-remember-project)))]
   
   ["Shell"
    ("S" "Project Shell" project-shell)
    ("E" "Project EShell" project-shell)
    ("A" "Project Async Shell Command" project-async-shell-command)
    ("C" "Project Shell Command" project-shell-command)
    ("M" "MisTTY @ Project root" mistty-in-project)]
   
   ["Other"
    ("D" "Set Project Dir-Locals" project-customize-dirlocals)
    ("R" "Ripgrep Project" rg-project)
    ("G" "DWIM Ripgrep Project" rg-dwim-project-dir)
    ("Z" "Forget Zombie Projects" project-forget-zombie-projects)
    ("p r" "Reset Known Projects" user/project-reset-projects)]])
(keymap-global-set "C-c t" #'user/project-treemacs-anywhere-dispatch)


(provide '05-project-management)
;;; 05-project-management.el ends here
