;;; 09-git-tools.el --- Git(hub) integration & tooling -*- lexical-binding: t; -*-

;;; Packages included:
;; diff-hl, forge, git-commit-ts-mode, git-modes, magit, magit-git-toolbelt,
;; treemacs-magit

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
  :preface (defvar user/diff-hl-dispatch)
  :bind ("C-x v o" . diff-hl-mode)
  :hook
  (((prog-mode text-mode) . diff-hl-mode)
   (magit-post-refresh    . diff-hl-magit-post-refresh))
  :custom
  (diff-hl-show-staged-changes nil)
  :config
  (transient-define-prefix user/diff-hl-dispatch ()
    "Custom transient for diff highlight commands."
    ["Diff Highlight Mode"
     [("*" "Show Hunk"       diff-hl-show-hunk)
      ("=" "Goto Hunk"       diff-hl-diff-goto-hunk)
      ("S" "Stage"           diff-hl-stage-dwim)
      ("n" "Revert"          diff-hl-revert-hunk)]

     [("[" "Previous Hunk"   diff-hl-previous-hunk)
      ("]" "Next Hunk"       diff-hl-next-hunk)
      ("{" "Show Prev. Hunk" diff-hl-show-hunk-previous)
      ("}" "Show Next Hunk"  diff-hl-show-hunk-next)]]))

(use-package git-modes
  :defer t
  :mode ("\\.dockerignore\\'" . gitignore-mode))

(use-package treemacs-magit
  :ensure (:wait t)
  :after (treemacs magit))


(provide '09-git-tools)
;;; 09-git-tools.el ends here
