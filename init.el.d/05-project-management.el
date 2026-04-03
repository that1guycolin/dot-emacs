;;; 05-project-management.el --- Project management and file navigation -*- lexical-binding: t; -*-

;; Packages included:
;; disproject, editorconfig, projectile, treemacs, treemacs-nerd-icons,
;; treemacs-projectile

;;; Commentary:
;; Support project functionality in Emacs.  Git integration for said projects
;; occurs in step 7.

;;; Code:
;; =======  PROJECT SUPPORT  =======
;; `projectile' (project manager)
;; `disproject' (assist navigation btwn projects)
;; `editorconfig' (support .editorconfig)
;; =================================
(keymap-global-unset "C-x p")
(declare-function dirvish "dirvish")
(declare-function transient-define-prefix "transient")
(use-package projectile
  :functions
  projectile-mode projectile-project-root user/file-explorer-at-project-root project-projectile user/projectile-ignore-elpaca-packages user/projectile-commander-dispatch user/dired-or-dirvish-at-project-root

  :custom
  (projectile-project-search-path '("~/projects/"
				    "~/scripts/"
				    "~/org"
				    "~/.emacs.d"))
  (projectile-completion-system 'default)
  (projectile-track-known-projects-automatically t)
  (projectile-enable-caching 'persistent)
  (projectile-indexing-method 'alien)

  :config
  (add-to-list 'projectile-globally-ignored-directories "^node_modules$")
  (add-to-list 'projectile-globally-ignored-directories "^\\.venv$")
  (add-to-list 'projectile-globally-ignored-directories "^\\.uv$")
  (projectile-mode +1)
  (add-hook 'project-find-functions #'project-projectile)

  (defun user/file-explorer-at-project-root (explr)
    "Open EXPLR at the current Projectile project root."
    (when-let ((root (projectile-project-root)))
      (funcall explr root)))

  (defun user/dired-or-dirvish-at-project-root ()
    "When active, open Dirvish at the current Projectile project root.
If not active, call Dired instead of Dirvish."
    (if (featurep 'dirvish)
	(user/file-explorer-at-project-root 'dirvish)
      (user/file-explorer-at-project-root 'dired)))
  (setq projectile-switch-project-action
	#'user/dired-or-dirvish-at-project-root)

  (defun user/projectile-ignore-elpaca-packages (project-root)
    "Return non-nil if PROJECT-ROOT is inside the Elpaca directory."
    (let ((elpaca-dir (expand-file-name "elpaca/" user-emacs-directory)))
      (string-prefix-p elpaca-dir project-root)))

  (setq projectile-ignored-project-function
        #'user/projectile-ignore-elpaca-packages)

  (declare-function projectile-ag "projectile")
  (declare-function projectile-ripgrep "projectile")
  (defun user/interactive-projectile-ag ()
    "Call projectile-ag interactively."
    (interactive)
    (call-interactively #'projectile-ag))
  (defun user/interactive-projectile-ripgrep ()
    "Call projectile-ripgrep interactively."
    (interactive)
    (call-interactively #'projectile-ripgrep))

  (defvar user/projectile-commander-dispatch nil)
  (transient-define-prefix
    user/projectile-commander-dispatch ()
    "Replace Projectile Commander with a transient buffer.
The keybindings are exactly the same."
    ["Projectile Commander"
     [("D" "Open project root in dired." projectile-dired)
      ("R" "Regerate the project's [e|g] tags." projectile-regenerate-tags)
      ("T" "Find test file in project." projectile-find-test-file)
      ("V" "Browse dirty projects" projectile-browse-dirty-projects)]
     [("a" "Run ag on a project." user/interactive-projectile-ag)
      ("b" "Switch to project buffer." projectile-switch-to-buffer)
      ("d" "Find directory in project." projectile-find-dir)
      ("e" "Find recently visited file in project." projectile-recentf)]
     [("f" "Find file in project." projectile-find-file)
      ("g" "Run grep on project." projectile-grep)
      ("j" "Find tag in project." projectile-find-tag)
      ("k" "Kill all project buffers." projectile-kill-buffers)]
     [("o" "Run mutli-occur on project buffers." projectile-multi-occur)
      ("p" "Run ripgrep on project." user/interactive-projectile-ripgrep)
      ("r" "Replace a string in the project." projectile-replace)
      ("s" "Switch project." projectile-switch-project)]
     [("v" "Open project root in vc-dir or magit." projectile-vc)]])
  (bind-keys
   :map ctl-x-map
   ("p" . user/projectile-commander-dispatch)))

(use-package editorconfig
  :hook ((prog-mode . editorconfig-mode)
	 (markdown-mode . editorconfig-mode)))


;; =======  TREEMACS  =======
(use-package treemacs
  :commands treemacs treemacs-refresh
  :defer t

  :functions
  treemacs-filewatch-mode treemacs-git-mode treemacs-git-commit-diff-mode
  treemacs-select-window treemacs-project-follow-mode treemacs-root-up
  treemacs-get-local-window treemacs-hide-gitignored-files-mode

  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)

  :config
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-git-commit-diff-mode 1)
  (add-hook 'treemacs-post-buffer-init-hook
	    (lambda () (treemacs-hide-gitignored-files-mode 1)))
  
  (bind-keys
   :map treemacs-mode-map
   ("C-x p f" . treemacs-project-follow-mode)
   ("<backspace>" . treemacs-root-up)))

(defvar user/projectile-treemacs-anywhere-dispatch nil)
(declare-function user/toggle-treemacs-no-ignored "05-project-management.el")
(declare-function user/projectile-treemacs-anywhere-dispatch
		  "05-project-management.el")
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
    ("d" "Open p in dirvish" projectile-dired)
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
(bind-keys ("C-c t" . user/projectile-treemacs-anywhere-dispatch))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :functions treemacs-nerd-icons-config
  :config
  (treemacs-nerd-icons-config))


(provide '05-project-management)
;;; 05-project-management.el ends here
