;;; 05-project-management.el --- Projects & Workspaces -*-lexical-binding: t; -*-

;;; Packages included:
;; activities, consult-project-extra, deadgrep, disproject, docker, project,
;; project-treemacs, rg, treemacs, treemacs-nerd-icons

;;; Commentary:
;; Support project functionality in Emacs.  Git integration for said projects
;; occurs in "09-git-tools.el".

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
               (expand-file-name "dotfiles" android-home)
             "~/dotfiles")))
      (dolist (dir (list user-emacs-directory org-directory dotfiles-dir))
        (project-remember-projects-under (expand-file-name dir))))
    (message "Successfully repopulated projects list"))

  :functions project-remember-projects-under
  :init
  (setq
   project-list-file (no-littering-expand-etc-file-name "project-list.eld"))
  :custom
  (project-list-exclude
   (list (regexp-quote (expand-file-name elpaca-directory))
         (regexp-quote (expand-file-name "~/dotfiles/terminals/alacritty"))))
  (project-vc-ignores '("^node_modules$" "^\\.venv$" "^\\.uv$")))

;; transient dispatch for project.el
(use-package disproject
  :defer t
  :preface
  (keymap-global-unset "C-x p")
  :bind (:map ctl-x-map
              ("p" . disproject-dispatch))
  :config
  (transient-append-suffix 'disproject-dispatch "M-x"
    '("R" "Reset Projects" user/project-reset-projects)))

(use-package consult-project-extra
  :demand t
  :bind
  (("C-c p f" . consult-project-extra-find)
   ("C-c p o" . consult-project-extra-find-other-window))
  :custom
  (consult-project-function #'consult-project-extra-project-fn)
  :config
  (with-eval-after-load 'disproject
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
  :functions
  activities-new activities-define activities-resume activities-suspend
  activities-kill activities-switch activities-switch-buffer activities-revert
  activities-list activities-rename activities-discard activities-mode
  activities-tabs-mode

  :init
  (activities-mode 1)
  (activities-tabs-mode 1))

;; Podman/container integration
(use-package docker
  :defer t
  :bind ("C-c D" . docker)
  :custom
  (docker-command "podman"))

;; Global rg integration
(use-package deadgrep
  :defer t
  :bind
  (("<f5>"    . deadgrep)
   ("C-c C-r" . deadgrep)))

;; Project rg integration & more
(use-package rg
  :defer t
  :bind (("C-c g" . rg-menu)
         :map isearch-mode-map
         ("M-s r" . rg-isearch-menu))
  :config
  (require 'rg-isearch))


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

  :bind
  (("C-c t t"     . treemacs)
   :map treemacs-mode-map
   ("C-x j"       . treemacs-project-follow-mode)
   ("<backspace>" . treemacs-root-up))
  :commands treemacs treemacs-refresh
  :functions
  treemacs-filewatch-mode treemacs-git-mode treemacs-git-commit-diff-mode
  treemacs-select-window treemacs-project-follow-mode treemacs-root-up
  treemacs-get-local-window treemacs-hide-gitignored-files-mode
  treemacs--select-workspace-by-name treemacs-switch-workspace
  :defines treemacs-mode-map

  :custom
  (treemacs-width 35)
  (treemacs-is-never-other-window t)

  :config
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred)
  (treemacs-git-commit-diff-mode 1)
  (treemacs-project-follow-mode 1)
  (advice-add 'disproject-dispatch :before #'user/close-treemacs))

(use-package project-treemacs
  :after treemacs)
  :functions (project-treemacs-mode)
  :config (project-treemacs-mode 1))

(use-package treemacs-nerd-icons
  :after treemacs
  :functions treemacs-nerd-icons-config
  :config
  (treemacs-nerd-icons-config))


(provide '05-project-management)
;;; 05-project-management.el ends here

