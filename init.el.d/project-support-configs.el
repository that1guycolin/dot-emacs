;;; project-support-configs.el --- Projects in Emacs -*- lexical-binding: t; -*-

;;; Commentary:
;; Provide support for project directories.  Git integration setup.

;;; Packages included:
;; deadgrep, disproject, envrc, forge, license-templates, magit,
;; magit-git-toolbelt, magit-pre-commit, projectile, transient, treemacs,
;; treemacs-magit, treemacs-nerd-icons, treemacs-projectile

;;; Code:
;; 'magit' (straight git integration); 'forge' (specific online code repo);
;; Additional extensions for help with

(use-package transient
  :demand t)

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
  :after magit
  :demand t)

(use-package license-templates
  :commands (license-templates-new-file license-templates-insert))

(use-package magit-git-toolbelt
  :commands magit-git-toolbelt
  :after magit)

(use-package magit-pre-commit
  :commands magit-pre-commit-mode
  :after magit)

(use-package envrc
  :commands envrc-global-mode)

;; 'projectile' (project manager); 'treemacs' (project navigation)
;; Additional extensions for both.
(keymap-global-unset "C-x p")
(use-package projectile
  :demand t
  :functions projectile-mode
  :custom
  (projectile-project-search-path '("~/projects/" "~/scripts/" "~/.emacs.d"))
  (projectile-completion-system 'default)
  (projectile-switch-project-action #'projectile-find-file)
  (projectile-track-known-projects-automatically t)
  (projectile-enable-caching 'persistent)
  (projectile-indexing-method 'hybrid)
  (add-to-list 'projectile-globally-ignored-directories "^node_modules$")
  (add-to-list 'projectile-globally-ignored-directories "^\\.venv$")
  (add-to-list 'projectile-globally-ignored-directories "^\\.uv$")
  :config
  (projectile-mode +1))

(use-package disproject
  :bind ( :map ctl-x-map
          ("p" . disproject-dispatch)))

(use-package deadgrep
  :bind ("<f5>" . deadgrep))

(use-package treemacs
  :bind
  (("C-c t" . treemacs)
   ("M-0"   . treemacs-select-window)
   (:map treemacs-mode-map
         ("C-x p e"   . treemacs-add-and-display-current-project-exclusively)
         ("C-x p f"   . treemacs-project-follow-mode)
         ("h"           . user/treemacs-show-files-toggle)
         ("<backspace>" . treemacs-root-up)))
  :functions (treemacs-toggle-show-dotfiles
              treemacs-hide-gitignored-files-mode
              treemacs-git-commit-diff-mode)
  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)
  (treemacs-filewatch-mode t)
  (treemacs-git-mode 'deferred)
  :config
  (treemacs-git-commit-diff-mode)
  (treemacs-toggle-show-dotfiles)
  (treemacs-hide-gitignored-files-mode)
  (defun user/treemacs-show-files-toggle ()
    "Toggle showing dotfiles and gitignored files in treemacs buffer."
    (interactive)
    (treemacs-toggle-show-dotfiles)
    (if treemacs-hide-gitignored-files-mode
        (setq treemacs-hide-gitignored-files-mode nil)
      (setq treemacs-hide-gitignored-files-mode t)))
  (keymap-global-set "M-o" #'user/treemacs-show-files-toggle))

(use-package treemacs-magit
  :after (magit treemacs)
  :demand t)

(use-package treemacs-projectile
  :after (projectile treemacs)
  :demand t)

(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :demand t)

(provide 'project-support-configs)
;;; project-support-configs.el ends here
