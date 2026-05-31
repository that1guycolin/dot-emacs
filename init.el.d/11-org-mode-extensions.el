;;; 11-org-mode-extensions.el --- Extensions for Org-mode -*- lexical-binding: t; -*-

;;; Packages included:
;; djvu, el2org, magit-org-todos, nov, ob-rust, org-edna, org-make-toc, org-mem,
;; org-modern, org-modern-indent, org-node, org-noter, org-noter-pdftools,
;; org-pdftools, org-pomodoro, org-project-capture, org-tidy, pdf-tools

;;; Commentary:
;; Provide extensions for Emacs' Org-mode.  NOTE: Many extensions in this file
;; would typically load with the `:after' keyword.  I load them with `:demand'
;; only because org-mode loads with a `wait' directive in the first init file.

;;; Code:
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
	   :source "MELPA" :package "org-project-capture" :fetcher github
	   :id org-project-capture :repo "colonelpanic8/org-project-capture"
	   :files ("org-project-capture.el"
		   "org-project-capture-backend.el"
		   "org-category-capture.el" "README.org"))
  :demand t
  :preface
  (defvar org-refile-targets)
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
  
  :bind
  (("C-c C-p c" . org-project-capture-capture-for-current-project)
   ("C-c C-p p" . org-project-capture-project-todo-completing-read)
   ("C-c C-p a" . org-project-capture-agenda-for-current-project))
  
  :custom
  (org-project-capture-per-project-filepath "TODO.org")
  :config
  (require 'org-category-capture)
  (dolist (project (project-known-project-roots))
    (let ((project-todo (expand-file-name "TODO.org" project)))
      (when (file-exists-p project-todo)
	(add-to-list 'org-agenda-files project-todo))))
  
  (unless (boundp 'org-refile-targets)
    (setq org-refile-targets '((nil :maxlevel . 9)
                               (org-agenda-files :maxlevel . 9)))))

(use-package magit-org-todos
  :defer t
  :hook (magit-mode . magit-org-todos-autoinsert)
  :custom
  (magit-org-todos-filename "TODO.org"))


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
  (declare-function org-id-get-create "org-id")
  (defvar org-directory)

  (defun user/setup-org-mem ()
    "Initialize the org-mem id database."
    (org-id-update-id-locations)
    (org-mem-roamy-db-mode 1)
    (org-mem-updater-mode 1))

  (defun user/org-mem-wait-15 ()
    "Wait 15 seconds before org-mem setup.."
    (run-at-time 15 nil #'user/setup-org-mem))

  :hook (emacs-startup . user/org-mem-wait-15)
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
  (declare-function org-id-new "org-id")
  
  (defun user/org-node-new-file (&optional title id)
    "Create a new file containing a new node.  Set as `org-node-creation-fn'.
This user-defined function customizes the \=':PROPERTIES:' block from
`org-node-new-file' in \"org-node.el\"."
    (unless title (or (setq title org-node-proposed-title)
  		      (error "Proposed title was nil")))
    (org-node-pop-to-fresh-file-buffer title)
    (goto-char (point-max))
    (let ((file-id (if id id (org-id-new))))
      (insert ":PROPERTIES:"
	      "\nID": file-id
	      "\n:END:"
	      "\n#+TITLE: " title
	      "\n#+AUTHOR:"
	      "\n#+ID:" file-id
  	      "\n#+FILETAGS:"
	      "\n"))
    (push (current-buffer) org-node--new-unsaved-buffers)
    (run-hooks 'org-node-creation-hook))

  :bind-keymap ("M-o" . org-node-global-prefix-map)
  :commands org-node-org-prefix-map
  :functions
  org-node-pop-to-fresh-file-buffer org-node-cache-mode
  org-node-complete-at-point-mode org-node-backlink-mode
  :defines org-node-backlink-do-drawers
  :init
  (keymap-set org-mode-map "M-o" #'org-node-org-prefix-map)
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

  (require 'org-node-backlink)
  (setq org-node-backlink-do-drawers nil)
  (org-node-backlink-mode 1))

(use-package pdf-tools
  :ensure (pdf-tools
	   :source nil :package "pdf-tools" :id pdf-tools :fetcher github
	   :repo "that1guycolin/pdf-tools"
	   :files (:defaults "README" ("build" "Makefile") ("build" "server"))
	   :type git :protocol https :inherit t :depth treeless)
  
  :defer t
  :magic ("%PDF" . pdf-view-mode)
  :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
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
  (org-noter-default-notes-file-names '("notes.org")))

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
  :after (org-noter org-pdftools)
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

;; =======  BABEL  =======
;; `ob-rust'
;; =======================
(use-package ob-rust
  :after org
  :custom
  (org-babel-rust-command "rust-script")
  :config
  (add-to-list 'org-babel-load-languages '(rust . t)))


;; =======  MISC  =======
;; `el2org' (make .org from .el)
;; `org-make-toc' (table-of-contents)
;; `org-modern' `org-modern-indent' (improve org l&f)
;; `org-pomodoro' (manage time)
;; `org-tidy' (invisible drawers)
;; ======================
(use-package el2org
  :defer t
  :bind
  (("C-c 2 f" . el2org-generate-file)
   ("C-c 2 r" . el2org-generate-readme)
   ("C-c 2 h" . el2org-generate-html)
   ("C-c 2 o" . el2org-generate-org)))

(use-package org-make-toc
  :defer t
  :bind (:map org-mode-map
	      ("C-^" . org-make-toc-insert)
	      ("C-&" . org-make-toc-set))
  :hook (org-mode . org-make-toc-mode)
  :custom
  (org-make-toc-insert-custom-ids t))

(use-package org-modern
  :defer t
  :hook (org-mode . org-modern-mode)
  :custom
  (org-auto-align-tags t)
  (org-tags-column 0)
  (org-fold-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-agenda-tags-column 'auto)
  (org-ellipsis "…"))

(use-package org-modern-indent
  :ensure (org-modern-indent
	   :host github :repo "jdtsmith/org-modern-indent" :files (:defaults)
	   :method https)
  :defer t
  :hook (org-modern-mode . org-modern-indent-mode))

(use-package org-pomodoro
  :defer t
  :bind (:map org-mode-map
	      ("C-c P" . org-pomodoro))
  :custom
  (org-pomodoro-manual-break t))

(use-package org-tidy
  :ensure (:wait t)
  :defer t
  :bind ("C-:" . org-tidy-toggle)
  :hook (org-mode . org-tidy-mode)
  :custom
  (org-tidy-top-property-style 'invisible)
  (org-tidy-properties-style 'invisible))


(provide '11-org-mode-extensions)
;;; 11-org-mode-extensions.el ends here
