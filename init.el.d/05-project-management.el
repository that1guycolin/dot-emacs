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
(use-package projectile
  :commands projectile-mode
  :functions
  projectile-project-root
  user/dirvish-at-project-root
  project-projectile
  user/projectile-ignore-elpaca-packages
  :custom
  (projectile-project-search-path '("~/projects/" "~/scripts/"))
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

  (defun user/file-explorer-at-project-root ()
    "Open Dirvish at the current Projectile project root.  Calling Dired instead
of calling Dirvish directly ensures that the function will work whether or not
Dirvish is loaded."
    (when-let ((root (projectile-project-root)))
      (dired root)))
  (setq projectile-switch-project-action #'user/file-explorer-at-project-root)

  (defun user/projectile-ignore-elpaca-packages (project-root)
    "Return non-nil if PROJECT-ROOT is inside the Elpaca directory."
    (let ((elpaca-dir (expand-file-name "elpaca/" user-emacs-directory)))
      (string-prefix-p elpaca-dir project-root)))

  (setq projectile-ignored-project-function
        #'user/projectile-ignore-elpaca-packages))

(use-package disproject
  :bind (:map ctl-x-map
              ("p" . disproject-dispatch)))

(use-package editorconfig
  :hook ((prog-mode . editorconfig-mode)
	 (markdown-mode . editorconfig-mode)))


;; =======  TREEMACS  =======
(use-package treemacs
  :commands treemacs treemacs-refresh
  :defer t
  :functions
  treemacs-filewatch-mode
  treemacs-git-mode
  treemacs-git-commit-diff-mode
  treemacs-select-window
  treemacs-project-follow-mode
  treemacs-root-up
  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)
  :config
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-git-commit-diff-mode 1)
  (bind-keys
   ("M-0" . treemacs-select-window)
   :map treemacs-mode-map
   ("C-x p f" . treemacs-project-follow-mode)
   ("<backspace>" . treemacs-root-up)))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :functions treemacs-nerd-icons-config
  :config
  (treemacs-nerd-icons-config))


(provide '05-project-management)
;;; 05-project-management.el ends here
