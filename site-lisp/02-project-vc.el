;;; 02-project-vc.el --- Projects & Workspaces -*- lexical-binding: t; -*-

;;; Packages included:
;; activities, consult-project-extra, diff-hl, disproject, forge,
;; git-commit-ts-mode, git-link, git-modes, magit, project, project-treemacs,
;; treemacs, treemacs-magit

;;; Commentary:
;; Packages to assist with project management in Emacs.  The first section
;; focuses on the built-in `project.el' package, which is fortunately so robust
;; as-is that most of the additional packages are small quality of life
;; improvements.  The middle portion of this file is dedicated to
;; version-control, which in Emacs is synonymous with `magit'.  The typical
;; `magit' toolchain is configured to my personal preferences.  The third and
;; final section of the config focuses on treemacs, which provides a utilitarian
;; & user-friendly side-buffer containing the current project's directory.
;;
;; `Project.el' & related packages are loaded with `:demand t'; `magit' &
;; `treemacs' related packages are deferred.

;;; Code:
;;; Projects:
(use-package project
  :ensure nil
  :demand t
  :preface
  (declare-function no-littering-expand-etc-file-name "no-littering")
  (defvar android-home)
  (defvar user/projects-directory)
  (defvar user/scripts-directory)
  (defvar org-directory)

  (defun user/current-project-root ()
    "Return the current project's root directory or nil if not in project."
    (when-let* ((project (project-current nil)))
      (project-root project)))
  
  (defun user/project-reset-projects ()
    "Clear the project list and repopulate it."
    (interactive)
    (dolist (project (project-known-project-roots))
      (project-forget-project project))
    (message "Cleared all projects")
    ;; Scan these directories recursively
    (dolist (dir (list user/projects-directory user/scripts-directory))
      (project-remember-projects-under dir t))
    ;; Scan these directories (but not their subdirectories)
    (let ((dotfiles-dir
           (if (equal system-type 'android)
               (concat android-home "/dotfiles")
             "~/dotfiles")))
      (dolist (dir (list user-emacs-directory org-directory dotfiles-dir))
        (project-remember-projects-under (expand-file-name dir))))
    (message "Successfully repopulated projects list"))

  :functions (project-remember-projects-under)
  :init (setq project-list-file
              (no-littering-expand-etc-file-name "project-list.eld"))
  :custom
  (project-list-exclude
   (list (regexp-quote (expand-file-name elpaca-directory))
         (regexp-quote (expand-file-name "~/dotfiles/terminals/alacritty"))))
  (project-vc-ignores '("^node_modules$" "^\\.venv$" "^\\.uv$")))

;; transient dispatch for project.el
(use-package disproject
  :defer t
  :preface (keymap-global-unset "C-x p")
  :bind (:map ctl-x-map ("p" . disproject-dispatch))
  :config (transient-append-suffix 'disproject-dispatch "M-x"
            '("R" "Reset Projects" user/project-reset-projects)))

(use-package consult-project-extra
  :demand t
  :bind (("C-c p f" . consult-project-extra-find)
         ("C-c p o" . consult-project-extra-find-other-window))
  :custom (consult-project-function #'consult-project-extra-project-fn)
  :config (with-eval-after-load 'disproject
            (transient-append-suffix 'disproject-dispatch "&"
              '("C f" "Consult Project Find" consult-project-extra-find))
            (transient-append-suffix 'disproject-dispatch "C f"
              '("C o" "C. P. Find Other Window"
                consult-project-extra-find-other-window))))

;; Save frame-state & tab-state
(use-package activities
  :demand t
  :preface
  (defvar edebug-inhibit-emacs-lisp-mode-bindings t)
  (setq edebug-inhibit-emacs-lisp-mode-bindings t)

  (defvar-keymap user/activities-map
    :doc "Functions from the package activities.el"
    "n"          #'activities-new
    "d"          #'activities-define
    "r"          #'activities-resume
    "p"          #'activities-suspend
    "k"          #'activities-kill
    "s"          #'activities-switch
    "b"          #'activities-switch-buffer
    "v"          #'activities-revert
    "l"          #'activities-list
    "C-r"        #'activities-rename
    "C-d"        #'activities-discard)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      user/activities-map
      "n"        "New Activity"
      "d"        "Define Activity"
      "r"        "Resume Activity"
      "p"        "Suspend Activity"
      "k"        "Kill Activity"
      "s"        "Switch Activity"
      "b"        "Switch Buffer (in current activity)"
      "v"        "Revert Activity"
      "l"        "List Activities"
      "C-r"      "Rename Activity"
      "C-d"      "Discard Activity"))
  :bind-keymap ("C-x C-a" . user/activities-map)
  :functions (activities-new
              activities-define activities-resume activities-suspend
              activities-kill activities-switch activities-switch-buffer
              activities-revert activities-list activities-rename
              activities-discard activities-mode activities-tabs-mode)
  :init
  (activities-mode 1)
  (activities-tabs-mode 1))


;;; VC/Git:
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


;;; Treemacs:
(use-package treemacs
  :defer t
  :preface
  (defun user/treemacs-switch-workspace-focus ()
    "Run `treemacs-switch-workspace' and ensure the Treemacs window is focused.
The ending behaviour, where treemacs is selected, then unselected, then
selected again,"
    (interactive)
    (call-interactively #'treemacs-switch-workspace)
    (let ((treemacs-win (treemacs-get-local-window)))
      (when (and treemacs-win (not (eq treemacs-win (selected-window))))
        (select-window treemacs-win)
        (when (fboundp 'treemacs-project-follow-mode)
          (other-window 1))
        (select-window treemacs-win))))

  (defun user/toggle-gitignored-wait-2 (&rest _args)
    "Toggle `treemacs-hide-gitignored-files-mode' if treemacs window.
Wait two seconds before activating the mode."
    (pcase (treemacs-current-visibility)
      ('visible
       (run-at-time 2 nil
                    #'(lambda ()
                        (treemacs-hide-gitignored-files-mode 1))))
      ('exists
       (run-at-time 2 nil
                    #'(lambda ()
                        (treemacs-hide-gitignored-files-mode 1))))
      ('none (ignore))))
  (advice-add 'treemacs :after #'user/toggle-gitignored-wait-2)

  (defun user/close-treemacs (&rest _args)
    "If a treemacs window exists, close it."
    (when (eq 'visible (treemacs-current-visibility))
      (treemacs)))

  :bind (("C-c t t"     . treemacs)
         :map treemacs-mode-map
         ("C-x j"       . treemacs-project-follow-mode)
         ("<backspace>" . treemacs-root-up))
  :commands (treemacs treemacs-refresh)
  :functions (treemacs-filewatch-mode
              treemacs-git-mode treemacs-git-commit-diff-mode
              treemacs-select-window treemacs-project-follow-mode
              treemacs-root-up treemacs-get-local-window
              treemacs-hide-gitignored-files-mode
              treemacs--select-workspace-by-name treemacs-switch-workspace)
  :defines (treemacs-mode-map)
  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)
  :config
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-git-commit-diff-mode 1)
  (treemacs-project-follow-mode 1)
  (advice-add 'disproject-dispatch :before #'user/close-treemacs))

;; Integrations
(use-package project-treemacs
  :after (treemacs)
  :demand t
  :functions (project-treemacs-mode)
  :config (project-treemacs-mode 1))

(use-package treemacs-magit
  :after (treemacs magit)
  :demand t)


(provide '02-project-vc)
;;; 02-project-vc.el ends here

