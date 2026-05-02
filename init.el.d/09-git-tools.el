;;; 09-git-tools.el --- Git(hub) integration & tooling -*- lexical-binding: t; -*-

;;; Packages included:
;; diff-hl, forge, git-commit-ts-mode, git-modes, magit, magit-git-toolbelt,
;; treemacs-magit

;;; Commentary:
;; Packages that simplify working with gits.  At present, this configuration is
;; setup to mainly work with Github.  Github auth token needed for forge stored
;; in "~/.authinfo.gpg"
;; see "https://docs.magit.vc/forge/Setup-for-Githubcom.html" for instructions.

;;; Code:
(use-package magit
  :ensure (magit :source "MELPA" :package "magit" :id magit :fetcher github
		 :repo "magit/magit"
		 :files ("lisp/magit*.el" "lisp/git-*.el" "docs/*"
			 "docs/AUTHORS.md" "LICENSE" ".dir-locals.el"
			 ("git-hooks" "git-hooks/*")
			 (:exclude "lisp/magit-section.el"))
		 :type git :protocol https :inherit t :depth treeless)
  :bind
  (("C-x g"   . magit-status)
   ("C-x M-g" . magit-dispatch)
   ("C-c M-g" . magit-file-dispatch))
  :custom
  (magit-refresh-status-buffer t)
  (magit-define-global-key-bindings 'default)
  (magit-save-repository-buffers t))

(use-package forge
  :after magit
  :hook (magit-status-mode . (lambda ()
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

(defvar magit-mode-map)
(use-package magit-git-toolbelt
  :after magit
  :bind (:map magit-mode-map
	      ("/" . magit-git-toolbelt)))

(use-package treemacs-magit
  :ensure (:wait t)
  :after treemacs magit)


(provide '09-git-tools)
;;; 09-git-tools.el ends here
