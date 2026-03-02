;;; project-support-configs.el --- Projects in Emacs -*- lexical-binding: t; -*-

;;; Commentary:
;; Provide support for project directories.  Git integration setup.

;;; Packages included:
;; deadgrep, disproject, envrc, forge, license-templates, magit,
;; magit-git-toolbelt, magit-pre-commit, projectile, transient, treemacs,
;; treemacs-magit, treemacs-projectile

;;; Code:
;; 'magit' (straight git integration); 'forge' (specific online code repo);
;; Additional extensions for help with commits.
(use-package transient)

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

(use-package license-templates
  :commands (license-templates-new-file license-templates-insert))

(use-package magit-git-toolbelt
  :after magit
  :bind (:map magit-mode-map
	      ("/" . magit-git-toolbelt)))

(use-package magit-pre-commit
  :after magit
  :bind (:map magit-mode-map
	      ("@" . magit-pre-commit-mode)))

(use-package envrc
  :bind ("C-c v" . envrc-global-mode))

;; 'projectile' (project manager); 'treemacs' (project navigation)
;; Additional extensions for both.
(keymap-global-unset "C-x p")
(use-package projectile
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
  :after projectile
  :bind (:map ctl-x-map
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
  :functions (treemacs-git-commit-diff-mode)
  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-git-commit-diff-mode 1))

(use-package treemacs-magit
  :after (magit treemacs))

(use-package treemacs-projectile
  :after (projectile treemacs))

(provide 'project-support-configs)
;;; project-support-configs.el ends here
