;;; 09-git-tools.el --- Git(hub) integration & tooling -*- lexical-binding: t; -*-

;;; Packages included:
;; diff-hl, forge, git-commit-ts-mode, git-modes, magit, treemacs-magit

;;; Commentary:
;; Packages that simplify working with gits.  At present, this configuration is
;; setup to mainly work with Github.  For setup, see
;; "https://docs.magit.vc/forge/Setup-for-Githubcom.html".

;;; Code:
(use-package magit
  :defer t
  :bind
  (("C-x g"   . magit-status)
   ("C-x M-g" . magit-dispatch)
   ("C-c M-g" . magit-file-dispatch))
  :defines magit-mode-map
  :custom
  (magit-refresh-status-buffer t)
  (magit-define-global-key-bindings 'default)
  (magit-save-repository-buffers t))

(use-package forge
  :defer t
  :preface
  (defun user/interactive-forge-pull ()
    "Call forge-pull interactively."
    (interactive)
    (call-interactively #'forge-pull))
  :hook (magit-status-mode . user/interactive-forge-pull)
  :functions forge-pull
  :custom
  (forge-pull-notifications t))

(use-package git-commit-ts-mode
  :defer t
  :mode "\\COMMIT_EDITMSG\\'")

(use-package diff-hl
  :defer t
  :preface
  (defvar-keymap user/diff-hl-functions
    :prefix t
    :doc "Functions to use in diff-hl-mode."
    "*" '(menu-item "Show Hunk"       diff-hl-show-hunk)
    "=" '(menu-item "Goto Hunk"       diff-hl-diff-goto-hunk)
    "S" '(menu-item "Stage"           diff-hl-stage-dwim)
    "n" '(menu-item "Revert"          diff-hl-revert-hunk)
    "[" '(menu-item "Previous Hunk"   diff-hl-previous-hunk)
    "]" '(menu-item "Next Hunk"       diff-hl-next-hunk)
    "{" '(menu-item "Show Prev. Hunk" diff-hl-show-hunk-previous)
    "}" '(menu-item "Show Next Hunk"  diff-hl-show-hunk-next))
  :bind
  (("C-x v o" . diff-hl-mode)
   ("C-x v ?" . user/diff-hl-functions))
  :hook
  (((prog-mode text-mode) . diff-hl-mode)
   (magit-post-refresh    . diff-hl-magit-post-refresh))
  :custom
  (diff-hl-show-staged-changes nil))

(use-package git-modes
  :defer t
  :mode ("\\.dockerignore\\'" . gitignore-mode))

(use-package treemacs-magit
  :after (treemacs magit))


(provide '09-git-tools)
;;; 09-git-tools.el ends here
