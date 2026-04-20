;;; 10-org-mode-extensions.el --- Extensions for Org-mode -*- lexical-binding: t; -*-

;;; Packages included:
;; org-edna, org-gtd, org-projectile, toc-org

;;; Commentary:
;; Provide extensions for Emacs' Org-mode.

;;; Code:
(defvar org-directory)
(defvar org-refile-targets)

;; =======  TASKS  =======
;; `org-edna' (cond. task completion)
;; `org-gtd' (get-things-done)
;; `org-project-capture' (integrate org-mode & projectile)
;; =======================
(use-package org-edna
  :after org
  :functions org-edna-mode
  :config
  (org-edna-mode 1))

(use-package org-gtd
  :after org
  :functions
  org-gtd-mode org-gtd-capture org-gtd-engage org-gtd-process-inbox
  org-gtd-show-all-next org-gtd-reflect-stuck-projects org-gtd-organize
  org-gtd-agenda-transient
  :defines
  org-gtd-update-ack
  
  :init
  (setq org-gtd-update-ack "4.0.0")
  (setq org-gtd-directory (expand-file-name "tasks" org-directory))

  :custom
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|" "DONE(d!)" "CNCL(c)")))
  (org-gtd-keyword-mapping '((todo     . "TODO")
			     (next     . "NEXT")
			     (wait     . "WAIT")
			     (done     . "DONE")
			     (canceled . "CNCL")))
  (org-gtd-refile-to-any-target nil)
  (org-gtd-refile-prompt-for-types '(project-heading project-task))
  
  :config
  (org-gtd-mode 1)
  (bind-keys
   ("C-c d c" . org-gtd-capture)
   ("C-c d e" . org-gtd-engage)
   ("C-c d p" . org-gtd-process-inbox)
   ("C-c d n" . org-gtd-show-all-next)
   ("C-c d s" . org-gtd-reflect-stuck-projects)))

(with-eval-after-load 'org-gtd
  (setq org-agenda-files (list org-gtd-directory))
  (bind-keys
   :map org-gtd-clarify-mode-map
   ("C-c c" . org-gtd-organize)))
(with-eval-after-load 'org-agenda
  (bind-keys
   :map org-agenda-mode-map
   ("C-c ." . org-gtd-agenda-transient)))

(use-package org-project-capture
  :ensure (org-project-capture
	   :source "MELPA"
	   :package "org-project-capture"
	   :id org-project-capture
	   :repo "colonelpanic8/org-project-capture"
	   :fetcher github
	   :files ("org-project-capture.el"
		   "org-project-capture-backend.el"
		   "org-projectile.el")
	   :type git
	   :protocol https
	   :inherit t
	   :depth treeless)
  :after org
  :functions
  org-project-capture-capture-for-current-project
  org-project-capture-project-todo-completing-read
  org-project-capture-agenda-for-current-project

  :config
  (require 'org-projectile)
  (setq
   org-project-capture-default-backend (make-instance
					'org-project-capture-projectile-backend)
   org-project-capture-per-project-filepath "TODO")

  (with-eval-after-load 'projectile
    (dolist (project projectile-known-projects)
      (let ((ptodo (expand-file-name "TODO" project)))
      	(when (file-exists-p ptodo)
	  (progn
      	    (add-to-list 'org-refile-targets `(,ptodo t))
	    (add-to-list 'org-agenda-files ptodo))))))
  
  (bind-keys
   ("C-c p c" . org-project-capture-capture-for-current-project)
   ("C-c p p" . org-project-capture-project-todo-completing-read)
   ("C-c p a" . org-project-capture-agenda-for-current-project)))

(use-package magit-org-todos
  :after magit
  :functions magit-org-todos-autoinsert
  :custom
  (magit-org-todos-filename "TODO")
  :config
  (magit-org-todos-autoinsert))


;; =======  KNOWLEDGE  =======
;; `org-roam' (capture and organize knowledge)
;; `org-roam-ql' (query knowledge-db)
;; ===========================
(use-package org-roam
  :after org
  :functions
  org-roam-db-autosync-mode org-roam-node-insert org-roam-node-find
  org-roam-capture user/org-roam-global-prefix-map
  :custom
  (org-roam-directory (expand-file-name "knowledge-base" org-directory))
  (org-roam-db-location (expand-file-name "org-roam.db" org-directory))
  :config
  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))
  (org-roam-db-autosync-mode 1)
  (defvar-keymap user/org-roam-global-prefix-map
    :doc "Prefix for org-roam-commands that can be called at any time."
    :prefix 'user/org-roam-global-prefix-map
    "i" #'org-roam-node-insert
    "f" #'org-roam-node-find
    "c" #'org-roam-capture)
  (bind-keys ("C-c r" . user/org-roam-global-prefix-map)))

(use-package org-roam-ql
  :after (org-roam)
  :bind ((:map org-roam-mode-map
	       ("v" . org-roam-ql-buffer-dispatch))
         (:map minibuffer-mode-map
	       ("C-c n i" . org-roam-ql-insert-node-title))))


;; =======  MISC  =======
;; `org-superstar' (pretty bullets)
;; `org-caldev' (nextcloud cal sync)
;; `org-make-toc' (table-of-contents)
;; ======================
(use-package org-superstar
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-special-todo-items t)
  (org-superstar-todo-bullet-alist '(("TODO(t)" . 8226)
				     ("NEXT(n)" . 8227)
				     ("WAIT(w)" . 8259)
				     ("DONE(d)" . 10687)
				     ("CNCL(c)" . 9702))))

(use-package org-caldav
  :after (org org-gtd org-project-capture)
  :custom
  (org-caldav-url
   "https://use11.thegood.cloud/remote.php/dav/calendars/colinloeffler%40gmail.com")
  (org-caldav-calendar-id "org-tasks")
  (org-caldav-inbox (expand-file-name "~/org/tasks/inbox.org"))
  (org-caldav-files nil)
  (org-icalendar-timezone "America/Chicago")
  (org-icalendar-include-todo 'all)
  (org-caldav-sync-todo t)
  (org-icalendar-categories '(local-tags)))

(use-package org-make-toc
  :defer t
  :bind (:map org-mode-map
	      ("C-c T i" . org-make-toc-insert)
	      ("C-c T m" . org-make-toc))
  :custom
  (org-make-toc-insert-custom-ids t))

(use-package pdf-tools
  :defer t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :functions pdf-tools-install pdf-view-midnight-minor-mode
  :custom
  (pdf-view-display-size 'fit-page)
  (pdf-info-asynchronous t)
  :config
  (pdf-tools-install)
  (add-hook 'pdf-view-mode-hook #'pdf-view-midnight-minor-mode))

(use-package el2org
  :defer t
  :bind
  (("C-c 2 f" . el2org-generate-file)
   ("C-c 2 r" . el2org-generate-readme)
   ("C-c 2 h" . el2org-generate-html)
   ("C-c 2 o" . el2org-generate-org)))

(use-package org-autolist
  :hook (org-mode . org-autolist-mode))


;; =======  FUNCTIONS & VARIABLES  =======
(defun user/convert-md-links-to-org ()
  "Convert all [label](link) patterns in the current buffer to [[link][label]]."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\\[\\([^]]+\\)\\](\\([^)]+\\))" nil t)
      (replace-match "[[\\2][\\1]]" nil nil))))

(defun user/remove-org-todo ()
  "Delete a TODO file in the org-directory if it exists.

Because the org-directory is a git repo, there is a possibility of
accidentally createing a TODO file.  A TODO file in the org-directory is
by definition redundant, since any TODO items should go in the tasks
folder."
  (interactive)
  (let ((org-dir-todo (expand-file-name "TODO" org-directory)))
    (if (file-exists-p org-dir-todo)
	(progn
	  (delete-file org-dir-todo)
	  (message "Removed org-directory TODO file."))
      (when (called-interactively-p 'any)
	(message "There is no TODO file in the org directory.")))))

(add-hook 'org-mode-hook #'user/remove-org-todo)


(provide '10-org-mode-extensions)
;;; 10-org-mode-extensions.el ends here
