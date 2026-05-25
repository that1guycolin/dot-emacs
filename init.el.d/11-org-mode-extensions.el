;;; 11-org-mode-extensions.el --- Extensions for Org-mode -*- lexical-binding: t; -*-

;;; Packages included:
;; djvu, el2org, magit-org-todos, nov, org-caldav, org-edna, org-gtd, org-mem,
;; org-modern, org-modern-indent, org-node, org-noter, org-noter-pdftools,
;; org-pdftools, org-pomodoro, org-project-capture, pdf-tools, toc-org

;;; Commentary:
;; Provide extensions for Emacs' Org-mode.

;;; Code:
(defvar org-refile-targets)

;; =======  TASKS  =======
;; `org-edna' (cond. task completion)
;; `org-project-capture' (integrate org-mode & projectile)
;; `magit-org-todos' (display TODO items in magit buffer)
;; =======================
(use-package org-edna
  :defer t
  :hook (org-mode . org-edna-mode))

(use-package org-project-capture
  :ensure (org-project-capture
	   :source "MELPA" :package "org-project-capture"
	   :id org-project-capture :repo "colonelpanic8/org-project-capture"
	   :fetcher github :files ("org-project-capture.el"
				   "org-project-capture-backend.el"
				   "org-category-capture.el" "README.org"))
  :demand t
  :preface
  (defvar org-refile-targets)
  
  :bind
  (("C-c C-p c" . org-project-capture-capture-for-current-project)
   ("C-c C-p p" . org-project-capture-project-todo-completing-read)
   ("C-c C-p a" . org-project-capture-agenda-for-current-project))
  
  :custom
  (org-project-capture-per-project-filepath "TODO")
  :config
  (require 'org-category-capture)
  (dolist (project (project-known-project-roots))
    (let ((project-todo (expand-file-name "TODO" project)))
      (when (file-exists-p project-todo)
	(add-to-list 'org-agenda-files project-todo))))
  
  (unless (boundp 'org-refile-targets)
    (setq org-refile-targets '((nil :maxlevel . 9)
                               (org-agenda-files :maxlevel . 9)))))

(use-package magit-org-todos
  :defer t
  :hook (magit-mode . magit-org-todos-autoinsert)
  :custom
  (magit-org-todos-filename "TODO"))


;; =======  KNOWLEDGE  =======
;; `org-mem' (org metadata index)
;; `org-node' (fast & simple note management)
;; `pdf-tools' (view pdf in Emacs)
;; `org-noter' (annotate documents)
;; `org-pdftools' (integrate org & `pdf-tools')
;; `org-noter-pdftools' (annotate pdf files)
;; ===========================
(use-package org-mem
  :after org
  :preface
  (declare-function org-id-update-id-locations "org")
  (defvar org-directory)
  (declare-function org-id-get-create "org-id")
  (defun user/setup-org-mem ()
    "Initialize the org-mem id database."
    (org-id-update-id-locations)
    (org-mem-roamy-db-mode 1)
    (org-mem-updater-mode 1))
  :hook (emacs-startup . (lambda ()
			   (run-at-time 15 nil #'user/setup-org-mem)))
  :functions
  org-mem-roamy-db-mode org-mem-updater-mode org-mem-reset org-mem-await
  org-mem-tip-if-empty
  :custom
  (org-mem-watch-dirs
   (list (expand-file-name org-directory)))
  (org-mem-roamy-do-overwrite-real-db nil))

(use-package org-node
  :defer t
  :preface
  (defun user/org-node-new-file (&optional title id)
    "Create a new file containing a new node.  Set as `org-node-creation-fn'.
This user-defined function customizes the \=':PROPERTIES:' block from
`org-node-new-file' in \"org-node.el\"."
    (unless title (or (setq title org-node-proposed-title)
  		      (error "Proposed title was nil")))
    (org-node-pop-to-fresh-file-buffer title)
    (goto-char (point-max))
    (if id
	(insert ":PROPERTIES:"
		"\nID": id
		"\n:END:"
		"\n#+TITLE: " title
		"\n#+AUTHOR:"
		"\n#+ID:" id
  		"\n#+FILETAGS:"
		"\n")
      (let ((id (org-id-new)))
	(insert ":PROPERTIES:"
		"\nID": id
		"\n:END:"
		"\n#+TITLE: " title
		"\n#+AUTHOR:"
		"\n#+ID:" id
  		"\n#+FILETAGS:"
		"\n"))
      (push (current-buffer) org-node--new-unsaved-buffers)
      (run-hooks 'org-node-creation-hook)))

  (defun user/org-node-create-properties-block ()
    "Create an org-node properties block at an interactively-selected heading."
    (interactive)
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org-mode"))
    (goto-char (user/org-get-heading-location))
    (org-id-get-create)
    (org-node-ensure-crtime-property))
  
  :bind-keymap ("M-o" . org-node-global-prefix-map)
  :bind-keymap (:map org-mode-map
		     ("M-o" . org-node-org-prefix-map))

  :functions
  org-node-cache-mode org-node-backlink-mode org-node-complete-at-point-mode
  org-node-ensure-crtime-property org-node-pop-to-fresh-file-buffer
  user/org-node-new-file user/org-node-cache-ensure
  :defines
  org-node-proposed-title org-node-proposed-id org-node--new-unsaved-buffers
  org-node-creation-fn org-node-backlink-do-drawers
  
  :custom
  (org-node-creation-fn #'user/org-node-new-file)
  (org-node-file-directory-ask t)
  (org-node-prefer-with-heading nil)
  (org-node--first-init nil)
  
  :config
  (org-node-cache-mode 1)
  (unless org-mem-updater-mode
    (org-mem-updater-mode 1))
  (org-mem-reset nil "Org-node waiting for org-mem...")
  (org-mem-await "Org-node waiting for org-mem..." 60)
  (org-mem-tip-if-empty)
  (org-node-complete-at-point-mode 1)

  (use-package org-node-backlink
    :after org-node
    :custom (org-node-backlink-do-drawers nil)
    :config (org-node-backlink-mode 1))
  (require 'org-node-backlink)
  (with-eval-after-load 'org-node-backlink
    (setq org-node-backlink-do-drawers nil)
    (org-node-backlink-mode 1)))

(use-package pdf-tools
  :ensure (pdf-tools
	   :source nil :package "pdf-tools" :id pdf-tools :fetcher github
	   :repo "that1guycolin/pdf-tools"
	   :files (:defaults "README" ("build" "Makefile") ("build" "server"))
	   :type git :protocol https :inherit t :depth treeless)
  :functions pdf-tools-install
  :custom
  (pdf-view-display-size 'fit-page)
  (pdf-info-asynchronous t)
  :config
  (pdf-tools-install))

(use-package nov
  :after org-noter)

(use-package djvu
  :after org-noter)

(use-package org-noter
  :defer t
  :bind
  (("C-c n n". org-noter)
   :map dired-mode-map
   ("N"      . org-noter-start-from-dired))
  :custom
  (org-noter-auto-save-last-location t)
  (org-noter-notes-search-path (expand-file-name "notes" org-directory))
  (org-noter-default-notes-file-names '("notes.org"))
  :config
  (use-package org-noter-pdftools
    :after org-noter))

(use-package org-pdftools
  :ensure (org-pdftools
	   :source nil :package "org-pdftools" :id org-pdftools
	   :fetcher github :repo "that1guycolin/org-pdftools"
	   :files ("org-pdftools.el") :old-names (org-pdfview)
	   :type git :protocol https :inherit t :depth treeless)
  :defer t
  :hook (org-mode . org-pdftools-setup-link))

(use-package org-noter-pdftools
  :ensure (org-noter-pdftools
	   :source nil :package "org-noter-pdftools" :id org-noter-pdftools
	   :repo "that1guycolin/org-pdftools" :fetcher github
	   :files ("org-noter-pdftools.el")
	   :type git :protocol https :inherit t :depth treeless)
  :after org-pdftools
  :preface
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
  
  :functions
  org-noter-insert-note org-noter--get-precise-info org-noter--parse-root
  org-noter--doc-approx-location org-entry-delete org-entry-put
  org-noter--pretty-print-location org-noter-pdftools-jump-to-note
  
  :config
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
	   :host github :repo "jdtsmith/org-modern-indent" :files (:defaults)
	   :method https)
  :config
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))

(use-package org-caldav
  :after org-gtd org-project-capture
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
  (with-eval-after-load 'markdown-mode
    (bind-keys
     :map markdown-mode-map
     ("C-c C-o" . toc-org-markdown-follow-thing-at-point))))

(use-package el2org
  :ensure (:wait t)
  :defer t
  :bind
  (("C-c 2 f" . el2org-generate-file)
   ("C-c 2 r" . el2org-generate-readme)
   ("C-c 2 h" . el2org-generate-html)
   ("C-c 2 o" . el2org-generate-org)))


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

(declare-function persp-new "perspectives.el")
(declare-function persp-switch "perspectives.el")
(declare-function user/add-list-to-persp "05-project-management.el")
(declare-function persp-switch-last "perspectives.el")
(defun user/create-org-persp (&optional _args)
  "Create a persp called \"org\".  Add open TODO and .org files to the persp."
  (interactive)
  (persp-new "org")
  (persp-switch "org")
  (user/add-list-to-persp :ext "org" "Added %s to org persp")
  (user/add-list-to-persp :full "TODO" "Added %s to org persp")
  (persp-switch-last))

(add-hook 'emacs-startup-hook #'user/create-org-persp)
(declare-function user/function-after-emacsclient-frame "01-bootstrap-core.el")
(add-hook 'server-after-make-frame-hook
	  #'(lambda ()
	      (user/function-after-emacsclient-frame
	       #'user/create-org-persp)))

(declare-function org-map-entries "org")
(declare-function org-get-heading "org")
(defun user/org-get-heading-location ()
  "Prompt to select a heading in the current document, and return its location.
Location is the value of the character at which the heading begins in
the current document."
  (interactive)
  (let* ((options (org-map-entries
		   (lambda ()
		     (let ((heading (org-get-heading t t t t))
			   (pos (point)))
		       (cons heading pos)))
		   nil 'file))
	 (choice (completing-read "Heading: " options nil t)))
    (cdr (assoc choice options))))

(provide '11-org-mode-extensions)
;;; 11-org-mode-extensions.el ends here
