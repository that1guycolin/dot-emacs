;;; 07-git-tools.el --- Git(hub) integration & tooling -*- lexical-binding: t; -*-

;;; Packages included:
;; forge, git-modes, magit, magit-git-toolbelt, magit-pre-commit, treemacs-magit,
;; with-editor

;;; Commentary:
;; Packages that simplify working with gits.  At present, this configuration is
;; setup to mainly work with Github.  Github auth token needed for forge stored
;; in "~/.authinfo.gpg"
;; see "https://docs.magit.vc/forge/Setup-for-Githubcom.html" for instructions.

;;; Code:
(use-package magit
  :bind
  (("C-x g"   . magit-status)
   ("C-x M-g" . magit-dispatch)
   ("C-c M-g" . magit-file-dispatch))
  :custom
  (magit-refresh-status-buffer nil)
  (magit-define-global-key-bindings 'default)
  (magit-save-repository-buffers t))

(use-package forge
  :after magit
  :hook
  (magit-status-mode . (lambda ()
			 (when (fboundp 'forge-pull)
                           (call-interactively #'forge-pull))))
  :custom
  (forge-pull-notifications t))

(use-package git-commit-ts-mode
  :defer t
  :mode "\\COMMIT_EDITMSG\\'")

(use-package diff-hl
  :defer t
  :bind ("C-c h" . diff-hl-mode)
  :config
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

(use-package git-modes
  :defer t
  :mode ("\\.dockerignore\\'" . gitignore-mode))

(use-package magit-git-toolbelt
  :after magit
  :bind (:map magit-mode-map
	      ("/" . magit-git-toolbelt)))

(use-package treemacs-magit
  :after treemacs magit)


(provide '07-git-tools)
;;; 07-git-tools.el ends here
