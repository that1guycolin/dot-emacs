;;; 09-git-tools.el --- Git(hub) integration & tooling -*- lexical-binding: t; -*-

;;; Packages included:
;; diff-hl, forge, git-commit-ts-mode, git-link, git-modes, magit,
;; treemacs-magit

;;; Commentary:
;; Packages that simplify working with gits.  At present, this configuration is
;; setup to mainly work with Github.  For setup, see
;; "https://docs.magit.vc/forge/Setup-for-Githubcom.html".

;;; Code:
(use-package magit
  :defer t
  :bind (("C-x g"   . magit-status)
         ("C-x M-g" . magit-dispatch)
         ("C-c M-g" . magit-file-dispatch))
  :defines (magit-mode-map)
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
  :functions (forge-pull)
  :custom (forge-pull-notifications t))

(use-package diff-hl
  :defer t
  :bind ("C-x v o" . diff-hl-mode)
  :hook (((prog-mode text-mode) . diff-hl-mode)
         (magit-post-refresh    . diff-hl-magit-post-refresh))
  :functions (diff-hl-show-hunk
              diff-hl-diff-goto-hunk diff-hl-stage-dwim diff-hl-revert-hunk
              diff-hl-previous-hunk diff-hl-next-hunk diff-hl-show-hunk-previous
              diff-hl-show-hunk-next)
  :custom (diff-hl-show-staged-changes nil)
  :config
  (defvar-keymap user/diff-hl-functions
    :doc "Functions to use in diff-hl-mode."
    "*" #'diff-hl-show-hunk
    "=" #'diff-hl-diff-goto-hunk
    "S" #'diff-hl-stage-dwim
    "n" #'diff-hl-revert-hunk
    "[" #'diff-hl-previous-hunk
    "]" #'diff-hl-next-hunk
    "{" #'diff-hl-show-hunk-previous
    "}" #'diff-hl-show-hunk-next)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      user/diff-hl-functions
      "*" "Show Hunk"
      "=" "Goto Hunk"
      "S" "Stage"
      "n" "Revert"
      "[" "Previous Hunk"
      "]" "Next Hunk"
      "{" "Show Prev. Hunk"
      "}" "Show Next Hunk"))
  (keymap-global-set "C-x v ?" user/diff-hl-functions))

(use-package git-commit-ts-mode
  :defer t
  :mode "\\COMMIT_EDITMSG\\'")

(use-package git-link
  :defer t
  :preface
  (defvar-keymap user/git-link-functions-map
    :doc "Useful functions from the package `git-link'."
    "l" #'git-link
    "c" #'git-link-commit
    "h" #'git-link-homepage)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      user/git-link-functions-map
      "l" "Link to current buffer"
      "c" "Link to specified commit"
      "h" "Link to repo homepage"))
  :bind-keymap ("C-c C-y" . user/git-link-functions-map)
  :functions (git-link git-link-commit git-link-homepage))

(use-package git-modes
  :defer t
  :mode ("\\.dockerignore\\'" . gitignore-mode))

(use-package treemacs-magit
  :after (treemacs magit)
  :demand t)


(provide '09-git-tools)
;;; 09-git-tools.el ends here
