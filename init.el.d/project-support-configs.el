;;; project-support-configs.el --- Projects in Emacs -*- lexical-binding: t; -*-

;;; Commentary:
;; Provide support for project directories.  Git integration setup.

;;; Packages included:
;; deadgrep, disproject, editorconfig, envrc, forge, magit, magit-git-toolbelt,
;; magit-pre-commit, projectile, treemacs, treemacs-magit, treemacs-nerd-icons

;;; Code:
;; =======  GIT  =======
;; 'magit' (straight git integration)
;; 'forge' (specific online code repo);
;; Additional extensions for help with commits.
;; =====================
(use-package magit
  :bind
  (("C-x g"   . magit-status)
   ("C-x M-g" . magit-dispatch)
   ("C-c M-g" . magit-file-dispatch))
  :custom
  (magit-refresh-status-buffer nil)
  (magit-define-global-key-bindings 'default)
  (magit-save-repository-properties t))

(use-package forge
  :after magit)

(use-package magit-git-toolbelt
  :after magit
  :bind (:map magit-mode-map
	      ("/" . magit-git-toolbelt)))

(use-package magit-pre-commit
  :after magit
  :bind (:map magit-mode-map
	      ("@" . magit-pre-commit-mode)))


;; =======  PROJECTILE  =======
;; 'projectile' (project manager)
;; 'disproject' (transient buffer)
;; 'deadgrep' (better searching)
;; ============================
(keymap-global-unset "C-x p")
(use-package projectile
  :functions
  (projectile-mode
   projectile-reset-known-projects
   project-projectile)
  :custom
  (projectile-project-search-path '("~/projects/" "~/scripts/"))
  (projectile-completion-system #'vertico)
  (projectile-track-known-projects-automatically t)
  (projectile-enable-caching 'persistent)
  (projectile-indexing-method 'hybrid)
  :config
  (add-to-list 'projectile-globally-ignored-directories "^node_modules$")
  (add-to-list 'projectile-globally-ignored-directories "^\\.venv$")
  (add-to-list 'projectile-globally-ignored-directories "^\\.uv$")
  (projectile-mode +1)
  (add-hook 'project-find-functions #'project-projectile))

(use-package disproject
  :after projectile
  :bind (:map ctl-x-map
              ("p" . disproject-dispatch)))

(use-package deadgrep
  :bind ("<f5>" . deadgrep))

;; =======  TREEMACS  =======
;; 'treemacs' (project-consious directory-navigator)
;; various extensions
;; ==========================
(use-package treemacs
  :hook (elpaca-after-init-hook . treemacs-start-on-boot)
  :functions
  (treemacs-filewatch-mode
   treemacs-git-mode
   treemacs-git-commit-diff-mode
   treemacs-select-window
   treemacs-project-follow-mode
   treemacs-root-up
   user/projectile-treemacs-anywhere-dispatch)
  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)
  :config
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-git-commit-diff-mode 1)
  (bind-keys
   ("C-c t" . user/projectile-treemacs-anywhere-dispatch)
   ("M-0" . treemacs-select-window))
  (bind-keys
   :map treemacs-mode-map
   ("C-x p f" . treemacs-project-follow-mode)
   ("<backspace>" . treemacs-root-up)))


(with-eval-after-load 'transient
  (transient-define-prefix
    user/projectile-treemacs-anywhere-dispatch ()
    "Globally available commands for Treemacs & Projectile."
    [
     ["Treemacs" :pad-keys t
      ("t" "Toggle" treemacs)
      ("T" "Refresh" treemacs-refresh)]

     ["Treemacs - Current View"
      ("v f" "Focus to active file" treemacs-find-file)
      ("v d" "Add directory" treemacs-select-directory)
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
      ("w d" "Delete" treemacs-remove-workspace)
      ("w p" "treemacs-projectile" treemacs-projectile)]

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
       projectile-reset-known-projects)]]))

(use-package treemacs-projectile
  :demand t
  :after (treemacs projectile))

(use-package treemacs-nerd-icons
  :functions treemacs-nerd-icons-config
  :config
  (treemacs-nerd-icons-config))

(use-package treemacs-magit
  :after magit)


;; =======  GENERIC  =======
(use-package editorconfig
  :hook ((prog-mode . editorconfig-mode)
	 (markdown-mode . editorconfig-mode)))

(use-package envrc
  :bind (:map prog-mode-map
	      ("C-c C-v" . envrc-global-mode)))

(provide 'project-support-configs)
;;; project-support-configs.el ends here