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
;; `magit-org-todos' (display TODO items in magit buffer)
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
  (org-gtd-refile-prompt-for-types '(single-action
				     project-heading
				     project-task))
  
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
   org-project-capture-default-backend
   (make-instance 'org-project-capture-projectile-backend)
   org-project-capture-per-project-filepath "TODO")

  (with-eval-after-load 'projectile
    (dolist (project projectile-known-projects)
      (let ((ptodo (expand-file-name "TODO" project)))
      	(when (file-exists-p ptodo)
	  (add-to-list 'org-agenda-files ptodo)))))
  
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

(unless (boundp 'org-refile-targets)
  (setq org-refile-targets '((nil :maxlevel . 9)
                             (org-agenda-files :maxlevel . 9))))


;; =======  KNOWLEDGE  =======
;; `org-mem' (org metadata index)
;; `org-node' (fast & simple note management)
;; `pdf-tools' (view pdf in Emacs)
;; `org-noter' (annotate documents)
;; `org-pdftools' (integrate org & `pdf-tools')
;; `org-noter-pdftools' (annotate pdf files)
;; ===========================
(use-package org-mem
  :functions org-mem-updater-mode
  :custom
  (org-mem-watch-dirs (list "~/org/knowledge-base/"))
  :config
  (org-mem-updater-mode 1))

(use-package org-node
  :functions
  org-node-global-prefix-map org-node-org-prefix-map org-node-cache-mode
  org-node-backlink-mode org-node-complete-at-point-mode
  org-node-pop-to-fresh-file-buffer user/org-node-new-file
  :defines
  org-node-proposed-title org-node-proposed-id org-node--new-unsaved-buffers
  org-node-creation-fn

  :init
  (keymap-global-set "C-c k" org-node-global-prefix-map)
  (keymap-set org-mode-map "C-c n" org-node-org-prefix-map)

  :custom
  (org-node-file-directory-ask t)
  (org-node-prefer-with-heading nil)
  (org-node-backlink-do-drawers nil)
  (auto-save-visited-interval 60)

  :config
  (org-node-cache-mode 1)
  (org-node-backlink-mode 1)
  (auto-save-visited-mode 1)
  (org-node-complete-at-point-mode 1)
  
  (defun user/org-node-new-file (&optional title id)
    "Create a new file with a new node.
  Designed for `org-node-creation-fn'.  This function customizes the
  insert block from `org-node-new-file'."
    (unless title (or (setq title org-node-proposed-title)
  		      (error "Proposed title was nil")))
    (unless id (or (setq id org-node-proposed-id)
  		   (error "Proposed ID was nil")))
    (org-node-pop-to-fresh-file-buffer title)
    (insert ":PROPERTIES:"
  	    "\n:ID:       " id
  	    "\n:END:"
  	    "\n#+TITLE: " title
  	    "\n#+FILETAGS:"
  	    "\n")
    (goto-char (point-max))
    (push (current-buffer) org-node--new-unsaved-buffers)
    (run-hooks 'org-node-creation-hook))
  
  (setq org-node-creation-fn #'user/org-node-new-file))

(use-package pdf-tools
  :ensure (pdf-tools
	   :source nil
	   :package "pdf-tools"
	   :id pdf-tools
	   :fetcher github
	   :repo "that1guycolin/pdf-tools"
	   :files (:defaults "README" ("build" "Makefile") ("build" "server"))
	   :type git
	   :protocol https
	   :inherit t
	   :depth treeless)
  :functions pdf-tools-install
  :custom
  (pdf-view-display-size 'fit-page)
  (pdf-info-asynchronous t)
  :config
  (pdf-tools-install))

(use-package org-noter
  :functions org-noter-start-from-dired
  :custom
  (org-noter-set-auto-save-last-location t)
  :config
  (require 'org-noter-pdftools)
  (bind-keys
   :map dired-mode-map
   ("C-c C-n" . org-noter-start-from-dired)))

(use-package org-pdftools
  :ensure (org-pdftools
	   :source nil
	   :package "org-pdftools"
	   :id org-pdftools
	   :fetcher github
	   :repo "that1guycolin/org-pdftools"
	   :files ("org-pdftools.el")
	   :old-names (org-pdfview)
	   :type git
	   :protocol https
	   :inherit t
	   :depth treeless)
  :hook (org-mode . org-pdftools-setup-link))

(use-package org-noter-pdftools
  :ensure (org-noter-pdftools
	   :source nil
	   :package "org-noter-pdftools"
	   :id org-noter-pdftools
	   :repo "that1guycolin/org-pdftools"
	   :fetcher github
	   :files ("org-noter-pdftools.el")
	   :type git
	   :protocol https
	   :inherit t
	   :depth treeless)

  :functions
  org-noter-insert-note org-noter--get-precise-info org-noter--parse-root
  org-noter--doc-approx-location org-entry-delete org-entry-put
  org-noter--pretty-print-location org-noter-pdftools-jump-to-note
  
  :config
  (defun org-noter-pdftools-insert-precise-note (&optional toggle-no-questions)
    (interactive "P")
    (org-noter--with-valid-session
     (let ((org-noter-insert-note-no-questions
	    (if toggle-no-questions
                (not org-noter-insert-note-no-questions)
              org-noter-insert-note-no-questions))
           (org-pdftools-use-isearch-link t)
           (org-pdftools-use-freepointer-annot t))
       (org-noter-insert-note (org-noter--get-precise-info)))))

  (defun org-noter-set-start-location (&optional arg)
    "When opening a session with this document, go to the current location.
With a prefix ARG, remove start location."
    (interactive "P")
    (org-noter--with-valid-session
     (let ((inhibit-read-only t)
           (ast (org-noter--parse-root))
           (location (org-noter--doc-approx-location
		      (when (called-interactively-p 'any) 'interactive))))
       (with-current-buffer (org-noter--session-notes-buffer session)
         (org-with-wide-buffer
          (goto-char (org-element-property :begin ast))
          (if arg
              (org-entry-delete nil org-noter-property-note-location)
            (org-entry-put nil org-noter-property-note-location
                           (org-noter--pretty-print-location location))))))))

  (with-eval-after-load 'pdf-annot
    (add-hook 'pdf-annot-activate-handler-functions
	      #'org-noter-pdftools-jump-to-note)))


;; =======  MISC  =======
;; `org-pomodoro' (manage time)
;; `org-modern' `org-modern-indent' (improve org l&f)
;; `org-caldev' (nextcloud cal sync)
;; `toc-org' (table-of-contents)
;; `el2org' (make .org from .el)
;; ======================
(use-package org-pomodoro
  :functions org-pomodoro
  :custom
  (org-pomodoro-manual-break t)
  :config
  (bind-keys
   :map org-mode-map
   ("C-c P" . org-pomodoro)))

(use-package org-modern
  :functions global-org-modern-mode
  :custom
  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-fold-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-agenda-tags-column 0)
  (org-ellipsis "…")
  :config
  (global-org-modern-mode 1))

(use-package org-modern-indent
  :ensure (org-modern-indent
	   :host github
	   :repo "jdtsmith/org-modern-indent"
	   :files (:defaults)
	   :method https)
  :config
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))

(use-package org-caldav
  :after (org-gtd org-project-capture)
  :custom
  (org-caldav-url
   "https://use11.thegood.cloud/remote.php/dav/calendars/colinloeffler%40gmail.com")
  (org-caldav-calendar-id "org-tasks")
  (org-caldav-inbox (expand-file-name "~/org/tasks/inbox.org"))
  (org-caldav-files org-agenda-files)
  (org-icalendar-timezone "America/Chicago")
  (org-icalendar-include-todo 'all)
  (org-caldav-sync-todo t)
  (org-icalendar-categories '(local-tags)))

(defvar markdown-mode-map)
(use-package toc-org
  :functions toc-org-markdown-follow-thing-at-point
  :hook
  ((org-mode      . toc-org-mode)
   (markdown-mode . toc-org-mode))
  :config
  (add-hook 'markdown-mode-hook
	    #'(lambda ()
		(bind-keys
		 :map markdown-mode-map
		 ("C-c C-o" . toc-org-markdown-follow-thing-at-point)))))

(use-package org-autolist
  :hook (org-mode . org-autolist-mode))

(use-package el2org
  :defer t
  :bind
  (("C-c 2 f" . el2org-generate-file)
   ("C-c 2 r" . el2org-generate-readme)
   ("C-c 2 h" . el2org-generate-html)
   ("C-c 2 o" . el2org-generate-org)))


;; =======  FUNCTIONS & VARIABLES  =======
(defvar org-babel-lisp-eval-fn)
(declare-function sly-eval "sly")
(org-babel-do-load-languages 'org-babel-load-languages
			     '((emacs-lisp . t)
			       (lisp       . t)
			       (lua        . t)
			       (makefile   . t)
			       (org        . t)
			       (python     . t)
			       (shell      . t)))
(setq org-babel-lisp-eval-fn #'sly-eval)

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
(declare-function org-fold-hide-drawer-all "org")
(add-hook 'org-mode-hook #'org-fold-hide-drawer-all)


(provide '10-org-mode-extensions)
;;; 10-org-mode-extensions.el ends here
