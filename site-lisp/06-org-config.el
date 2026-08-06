;;; 06-org-config.el --- Org-Mode Setup -*- lexical-binding: t; -*-

;;; Packages included:
;; djvu, el2org, nov, ob-rust, org, org-appear, org-category-capture, org-chef,
;; org-edna, org-make-toc, org-mem, org-modern, org-modern-indent, org-node,
;; org-node-backlink, org-noter, org-noter-pdftools, org-pdftools,
;; org-pomodoro, org-project-capture, org-recur, org-super-agenda, org-tidy,
;; pdf-tools

;;; Commentary:
;; Set up Emacs' Org-mode.  Also, configure packages that extend Org's already
;; awesome power.

;;; Code:
(use-package org
  :defer t
  :preface
  (declare-function inhibit-mouse-mode "inhibit-mouse-mode")
  (declare-function that1guycolin/desktop-mobile "init.el")
  (declare-function sly-eval "sly")
;;;; Helper function
  (defun that1guycolin/org-check ()
    "User-error if buffer is not in `org-mode'."
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode")))

;;;; `org-id-prefix' functions
  (defun that1guycolin/org-id-prefix-slug (s)
    "Turn S into a safe(-ish) `org-id-prefix'."
    (when s
      (replace-regexp-in-string
       "-+" "-"
       (replace-regexp-in-string
        "[^[:alnum:]_]+" "-"
        (downcase s)))))

  (defun that1guycolin/get-parent-directory ()
    "Return parent directory name for current buffer."
    (when buffer-file-name
      (file-name-nondirectory
       (directory-file-name
        (file-name-directory buffer-file-name)))))

  (defun that1guycolin/org-id-context-prefix ()
    "Return `org-id-prefix' based on node level."
    (that1guycolin/org-check)
    (cond
     ((org-before-first-heading-p)
      (that1guycolin/get-parent-directory))
     ((save-excursion
        (org-back-to-heading t)
        (= (org-outline-level) 1))
      (when buffer-file-name
        (file-name-base buffer-file-name)))
     (t
      (save-excursion
        (org-back-to-heading t)
        (when (org-up-heading-safe)
          (org-get-heading t t t t))))))

  (defun that1guycolin/org-id-dynamic-prefix (orig-fn &rest args)
    "Dynamically compute org-id-prefix' each time an ID is created.
Designed to wrap around ORIG-FN `org-id-new' (accepting the same ARGS) when
creating org nodes."
    (defvar org-id-prefix)
    (let ((org-id-prefix
           (if (derived-mode-p 'org-mode)
               (or (that1guycolin/org-id-prefix-slug
                    (that1guycolin/org-id-context-prefix))
                   org-id-prefix)
             (that1guycolin/get-parent-directory))))
      (apply orig-fn args)))
  (advice-add 'org-id-new :around #'that1guycolin/org-id-dynamic-prefix)

;;;; Custom header settings
  (defun that1guycolin/org-get-heading-location ()
    "In an org-mode buffer, prompt user to pick a scope.
The scope could be the entire buffer or a heading within that buffer.
For entire buffer, return the top of the buffer."
    (that1guycolin/org-check)
    (let* ((doc-option `(,(buffer-name) . document))
           (heading-options
            (org-map-entries
             (lambda ()
               (let* ((path (org-get-outline-path t t))
                      (heading (org-get-heading t t t t))
                      (display (string-join
                                (append path (list heading)) " / ")))
                 (cons display (point))))
             nil 'file))
           (options (cons doc-option heading-options))
           (choice (completing-read "Location: " options nil t))
           (location (cdr (assoc choice options))))
      (if (eq location 'document)
          (point-min)
        location)))

  (defun that1guycolin/org-update-last-edit-dt ()
    "Update value of `LAST_EDIT' header in the active Org buffer.
The new value is the current date & time in this format:
YYYY-MM-DD DAY HH:MM:ss (e.g., 2026-03-15 SUN 14:24:06)"
    (when (derived-mode-p 'org-mode)
      (save-excursion
        (goto-char (point-min))
        (when (re-search-forward "^#\\+LAST_EDIT:[ \t]*.*$" nil t)
          (replace-match
           (format-time-string
            "#+LAST_EDIT: [%Y-%m-%d %a %H:%M:%S]"))))))
  (add-hook 'before-save-hook #'that1guycolin/org-update-last-edit-dt)

  (defun that1guycolin/org-top-drawer-p ()
    "Non-nil if the current file begins with a top-level property drawer."
    (that1guycolin/org-check)
    (save-excursion
      (goto-char (point-min))
      (looking-at org-property-drawer-re)))

  (defun that1guycolin/org-top-drawer-end ()
    "Go to the end of a properties drawer and insert a new line.
The function ends with the cursor on the new line."
    (goto-char (point-min))
    (while (looking-at org-property-drawer-re)
      (search-forward ":END:")
      (unless (bolp)
        (insert "\n"))))

  (defun that1guycolin/org-top-property-drawer-id ()
    "Return ID from a top-of-file-property-drawer, or nil."
    (if (that1guycolin/org-top-drawer-p)
        (save-restriction
          (narrow-to-region (match-beginning 0) (match-end 0))
          (goto-char (point-min))
          (when (re-search-forward "^:ID:[ \t]+\\(.+\\)$" nil t)
            (string-trim (match-string 1))))
      nil))

  (defun that1guycolin/org-gen-header (ti au id)
    "Insert a custom header block with TItle, AUthor & ID."
    (insert "#+TITLE: " ti
            "\n#+AUTHOR: " au
            "\n#+CREATED_DATE: " (format-time-string "[%Y-%m-%d %a %H:%M:%S]")
            "\n#+LAST_EDIT: "
            "\n#+ID: " id
            "\n#+FILETAGS: "))

;;;; Insert objects
  (defun that1guycolin/org-insert-properties-drawer (&optional interactivep)
    "Create org properties drawer at an interactively-selected heading."
    (interactive "p")
    (that1guycolin/org-check)
    (if interactivep
        (goto-char (that1guycolin/org-get-heading-location))
      (goto-char (point-min)))
    (let ((id (org-id-get-create)))
      (unless (org-entry-get nil "CREATED")
        (org-entry-put nil "CREATED"
                       (format-time-string "[%Y-%m-%d %a %H:%M:%S]")))
      id))

  (defun that1guycolin/org-insert-header-block (title author)
    "Insert a header block at the top of the current document.
If there is a properties drawer at the top, the header block will go
underneath it.  The header block will contain the following fields:
\='TITLE:, AUTHOR: CREATED_DATE:, LAST_EDITED:, ID:, FILETAGS:'."
    (interactive
     (list (read-string "Title: " (file-name-base (buffer-name)))
           (let ((default "Colin Loeffler (that1guycolin)"))
             (read-string (format "Author [DEFAULT: \"%s\"]: " default)
                          nil nil default))))
    (that1guycolin/org-check)
    (if (that1guycolin/org-top-drawer-p)
        (let ((existing-id (that1guycolin/org-top-property-drawer-id)))
          (that1guycolin/org-top-drawer-end)
          (that1guycolin/org-gen-header title author existing-id))
      (let ((new-id (that1guycolin/org-insert-properties-drawer)))
        (that1guycolin/org-top-drawer-end)
        (that1guycolin/org-gen-header title author new-id))))

  (defun that1guycolin/org-insert-src-block (lang)
    "Insert a block structure of the type #+begin_src LANG/#+end_src."
    (interactive
     (list
      (completing-read "Language: "
                       (mapcar #'car org-src-lang-modes) nil t)))
    (org-insert-structure-template "src")
    (insert lang "\n"))

  (defvar-keymap that1guycolin/org-insert-block-map
    :doc "Keymap of functions for inserting/editing headers, drawers, srcblocks"
    "h" #'that1guycolin/org-insert-header-block
    "d" #'that1guycolin/org-insert-properties-drawer
    "s" #'that1guycolin/org-insert-src-block)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements that1guycolin/org-insert-block-map
      "h" "Header Block"
      "d" "Properties Drawer"
      "s" "Source Block"))

;;;; Org custom templates
  (defconst that1guycolin/org-templates--task
    '("t" "Task" entry
      (file "TODOs/tasks.org")
      "* TODO %?\n"))
  
  (defconst that1guycolin/org-templates--idea
    '("i" "Idea" entry
      (file "TODOs/ideas.org")
      "* THOUGHT %?\n"))

  (defconst that1guycolin/org-templates--someday
    '("s" "Someday" entry
      (file "TODOs/someday.org")
      "* SOMEDAY %?\n"))


;;;; Org task sequences
  (defconst that1guycolin/org-keywords--tasks
    '(sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")
    "Keyword sequence with names based on the getting-things-done method.
Their implementation in this config is far less strict than traditional GTD.")

  (defconst that1guycolin/org-keywords--ideas
    '(sequence "THOUGHT(o)" "PLANNING(p)" "IMPLEMENTATION(i)" "|"
               "COMPLETE(e)" "ABANDONED(a)")
    "Keyword sequence for turning dreams into reality.")

  (defconst that1guycolin/org-keywords--reading-list
    '(sequence "TO READ(r)" "READING(R)" "|" "FINISHED(f)")
    "Keyword sequence to track what you're reading.")

  (defconst that1guycolin/org-keywords--media-download
    '(sequence "TAGGED(g)" "|" "DOWNLOADED(w)" "IGNORED(I)")
    "Keyword sequence to track media downloads.")

  (defconst that1guycolin/org-keywords--someday
    '(sequence "SOMEDAY(s)" "RESEARCH(h)" "|" "ACTIVE(v)" "DISCARD(D)")
    "Keyword sequence to track things you might do \"someday\".")

;;;; misc.
  (defun that1guycolin/org-convert-md-links ()
    "Convert all md-style links in the current buffer to org-style."
    (interactive)
    (that1guycolin/org-check)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "\\[\\([^]]+\\)\\](\\([^)]+\\))" nil t)
        (replace-match "[[\\2][\\1]]" nil nil))))

;;;; finish use-package sexp
  :bind (("C-c o o" . org-mode)
         ("C-c o a" . org-agenda)
         ("C-c c"   . org-capture)
         ("C-c o c" . org-capture)
         ("C-c o l" . org-store-link)
         (:map org-mode-map
               ("C-c l"   . org-toggle-link-display)
               ("C-c C-q" . org-set-tags-command)))
  :hook (org-mode . (lambda () (inhibit-mouse-mode -1)))
  :mode (("\\.org\\'"   . org-mode)
         ("\\.notes\\'" . org-mode))
  :functions (org-before-first-heading-p
              org-get-heading org-map-entries org-back-to-heading
              org-outline-level org-up-heading-safe org-get-outline-path
              org-id-get-create org-entry-get org-entry-put org-id-new
              org-insert-structure-template)
  :defines (org-babel-default-header-args:zsh org-babel-lisp-eval-fn)
  :init (that1guycolin/desktop-mobile
          (setq org-directory (expand-file-name "~/org"))
          (setq org-directory "/storage/emulated/0/Documents/org"))
  :custom
  (org-agenda-files
   (directory-files (expand-file-name "TODOs/" org-directory) t
                    directory-files-no-dot-files-regexp))
  (org-agenda-diary-file (expand-file-name "diary" org-directory))
  (org-archive-location
   (expand-file-name "archive/2026.org::datetree/* %s" org-directory))
  (org-capture-templates
   (list that1guycolin/org-templates--task
         that1guycolin/org-templates--idea
         that1guycolin/org-templates--someday))
  (org-confirm-babel-evaluate nil)
  (org-default-notes-file (expand-file-name "tasks/tasks.org" org-directory))
  (org-edit-src-content-indentation 0)
  (org-id-locations-file (expand-file-name ".id-locations" org-directory))
  (org-id-method 'org)
  (org-id-prefix "default")
  (org-insert-mode-line-in-empty-file t)
  (org-startup-folded 'show2levels)
  (org-todo-keywords
   (list that1guycolin/org-keywords--tasks that1guycolin/org-keywords--ideas
         that1guycolin/org-keywords--reading-list
         that1guycolin/org-keywords--media-download
         that1guycolin/org-keywords--someday))
  (org-use-sub-superscripts '{})
  :config
  (require 'org-id)
  (require 'ox-texinfo)
  (keymap-set org-mode-map "C-c b" that1guycolin/org-insert-block-map)
  (dolist (lang-mode-cons '(("bash"  . bash-ts) ("bash2" . bash-ts)
                            ("cmake" . cmake-ts) ("json" . json-ts)
                            ("lua"   . lua-ts) ("python" . python-ts)
                            ("toml"  . toml-ts) ("yaml"  . yaml-ts)))
    (assoc-delete-all (car lang-mode-cons) org-src-lang-modes)
    (add-to-list 'org-src-lang-modes lang-mode-cons))

  (with-eval-after-load 'ob
    (setq org-babel-default-header-args
          (cons '(:results . "value verbatim replace")
                (assq-delete-all :results org-babel-default-header-args)))
    (setq org-babel-default-header-args:zsh '((:results . "output")))
    (dolist (lang '(lisp lua makefile org python shell))
      (add-to-list 'org-babel-load-languages `(,lang . t)))
    (org-babel-do-load-languages
     'org-babel-load-languages
     org-babel-load-languages))
  (with-eval-after-load 'ob-lisp
    (setq org-babel-lisp-eval-fn 'sly)))


;;; Tasks:
;; Conditional task completion
(use-package org-edna
  :after (org)
  :demand t
  :functions (org-edna-mode)
  :config (org-edna-mode 1))

;; Project management via Org
(use-package org-project-capture
  :demand t
  :preface
  (defun that1guycolin/remove-org-todo ()
    "If a TODO.org file exists in the org directory, delete it.
Because the org-directory is a git repo, there is a possibility of
accidentally creating a TODO file.  A TODO file in the org-directory is
by definition redundant, since any TODO items should go in the tasks
folder."
    (interactive)
    (let ((org-dir-todo (expand-file-name "TODO.org" org-directory)))
      (if (file-exists-p org-dir-todo)
          (progn
            (delete-file org-dir-todo)
            (message "Removed org-directory TODO file."))
        (when (called-interactively-p 'any)
          (message "There is no TODO file in the org directory.")))))

  (defun that1guycolin/open-project-todo ()
    "Open the \"TODO.org\" file for the current project.
The file is created if it doesn't exist."
    (interactive)
    (unless (project-current)
      (error "No current project"))
    (let* ((pr (project-root (project-current)))
           (todo (expand-file-name "TODO.org" pr)))
      (find-file todo)))

  :functions (org-project-capture-capture-for-current-project
              org-project-capture-project-todo-completing-read
              org-project-capture-agenda-for-current-project)
  :custom
  (org-project-capture-default-backend
   (make-instance 'org-project-capture-project-backend))
  (org-project-capture-strategy
   (make-instance 'org-project-capture-per-project-strategy))
  (org-project-capture-per-project-filepath "TODO.org")
  :config
  (defvar-keymap that1guycolin/org-capture-options
    :doc "Keymap containing available org-capture options."
    "p" #'org-project-capture-capture-for-current-project
    "n" #'org-project-capture-project-todo-completing-read
    "g" #'org-capture)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      that1guycolin/org-capture-options
      "p" "Current Project"
      "n" "Non-Active Project"
      "g" "General Capture"))
  (keymap-global-set "C-c c" that1guycolin/org-capture-options)

  (defvar-keymap that1guycolin/org-agenda-options
    :doc "Keymap containing availble org-agenda views."
    "p" #'org-project-capture-agenda-for-current-project
    "g" #'org-agenda)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      that1guycolin/org-agenda-options
      "p" "Current Project"
      "g" "General Agenda"))
  (keymap-global-set "C-c a" that1guycolin/org-agenda-options)
  
  (dolist (project (project-known-project-roots))
    (let ((project-todo (expand-file-name "TODO.org" project)))
      (when (file-exists-p project-todo)
        (add-to-list 'org-agenda-files project-todo))))

  (unless org-refile-targets
    (setq org-refile-targets '((nil :maxlevel . 9)
                               (org-agenda-files :maxlevel . 9))))

  (with-eval-after-load 'disproject
    (transient-append-suffix 'disproject-dispatch "C o"
      '("t" "Project TODO" that1guycolin/open-project-todo)))
  (add-hook 'org-mode-hook #'that1guycolin/remove-org-todo))

(use-package org-category-capture
  :ensure nil
  :after (org-project-capture)
  :demand t
  :custom (occ-auto-insert-category-heading t))

(use-package org-recur
  :defer t
  :bind ((:map org-recur-mode-map
               ("C-c d"   . org-recur-finish))
         (:map org-recur-agenda-mode-map
               ("d"       . org-recur-finish)
               ("C-c d"   . org-recur-finish)))
  :hook ((org-mode        . org-recur-mode)
         (org-agenda-mode . org-recur-agenda-mode))
  :custom
  (org-recur-finish-done t)
  (org-recur-finish-archive t))

(use-package org-super-agenda
  :after (org)
  :demand t
  :functions (org-super-agenda-mode)
  :init (org-super-agenda-mode)
  :config
  (setq
   org-super-agenda-groups
   '((:name "Overdue"         :deadline past                 :order 0)
     (:name "Today"           :time-grid t                 :date today
            :deadline today   :scheduled today               :order 1)
     (:name "High Priority"   :priority "A"                  :order 2)
     (:name "Project Next Actions"                                :and
            (:todo "NEXT"     :tag "project")                :order 3)
     (:name "Projects"        :todo "PROJECT"                :order 4)
     (:name "Emacs"           :tag ("Emacs" "elisp")         :order 5)
     (:name "org Mode"         :tag "Org"                    :order 6)
     (:name "Waiting"         :todo "WAITING"                :order 9)
     (:name "To Read"         :todo "TO-READ" :tag "read"    :order 10)
     (:name "Someday"         :todo "SOMEDAY"                :order 11)
     (:name "Remaining Tasks" :anything t                    :order 99))))


;;; Knowledge
;; Org metadata index
(use-package org-mem
  :after (org)
  :demand t
  :functions (org-mem-updater-mode
              org-mem-reset org-mem-await org-mem-tip-if-empty)
  :custom
  (org-mem-watch-dirs (list (expand-file-name org-directory)))
  (org-mem-do-look-everywhere nil)
  :config
  (add-to-list 'org-mem-exclude "/elpaca/")
  (add-to-list 'org-mem-exclude "/archive/")
  (org-mem-updater-mode 1))

;; Fast & simple note management
(use-package org-node
  :defer t
  :preface
  (declare-function org-id-new "org-id")
  (declare-function that1guycolin/org-insert-header-block "01-bootstrap-core")
  
  (defun that1guycolin/org-node-new-file (&optional title cust-id)
    "Create a new file for a new node.
Optionally, provide the TITLE and CUST-ID for the new node. This is the
original `org-node-new-fn' with a custom \=':PROPERTIES:' block.  Set
this function as `org-node-creation-fn'."

    (let ((title (or title (or org-node-proposed-title
                               (error "Proposed title was nil")))))
      (org-node-pop-to-fresh-file-buffer title)
      (goto-char (point-min))
      (if cust-id
          (insert
           ":PROPERTIES:"
           "\n:ID:       " cust-id
           "\n:END:"
           "\n#+TITLE: " title
           "\n#+AUTHOR: "
           "\n#+CREATED_DATE: "
           (format-time-string "[%Y-%m-%d %a %H:%M:%S]")
           "\n#+LAST_EDIT: "
           "\n#+ID:      " cust-id
           "\n#+FILETAGS:"
           "\n")
        (progn
          (org-id-get-create)
          (that1guycolin/org-insert-header-block
           title "Colin Loeffler (that1guycolin)"))))

    (push (current-buffer) org-node--new-unsaved-buffers)
    (run-hooks 'org-node-creation-hook))

  :bind-keymap ("M-o" . org-node-global-prefix-map)
  :commands (org-node-org-prefix-map)
  :functions (org-node-pop-to-fresh-file-buffer
              org-node-cache-mode org-node-complete-at-point-mode
              org-node-backlink-mode)
  :defines (org-node-backlink-do-drawers)
  :init (with-eval-after-load 'org
          (keymap-set org-mode-map "M-o" org-node-org-prefix-map))
  :custom
  (org-node-creation-fn #'that1guycolin/org-node-new-file)
  (org-node-file-directory-ask t)
  (org-node-prefer-with-heading nil)
  :config
  (org-node-cache-mode 1)
  (org-mem-updater-mode 1)
  (org-mem-reset nil "Org-node waiting for org-mem...")
  (org-mem-await "Org-node waiting for org-mem..." 60)
  (org-mem-tip-if-empty)
  (org-node-complete-at-point-mode 1))

(use-package org-node-backlink
  :ensure nil
  :after (org-node)
  :demand t
  :custom (org-node-backlink-do-drawers nil)
  :config (org-node-backlink-mode 1))

;; View PDFs in Emacs
(use-package pdf-tools
  :ensure (pdf-tools
           :source nil :package "pdf-tools" :id pdf-tools :fetcher github
           :repo "that1guycolin/pdf-tools"
           :files (:defaults "README" ("build" "Makefile") ("build" "server"))
           :type git :protocol https :inherit t :depth treeless)
  :defer t
  :hook (pdf-view-mode . (lambda () (inhibit-mouse-mode -1)))
  :magic ("%PDF" . pdf-view-mode)
  :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
  :functions (pdf-tools-install)
  :custom
  (pdf-view-display-size 'fit-page)
  (pdf-info-asynchronous t)
  :config (pdf-tools-install))

;; Annotate
(use-package org-noter
  :defer t
  :bind (("C-c o n". org-noter)
         :map dired-mode-map
         ("N"      . org-noter-start-from-dired))

  :init (let ((note-dir (expand-file-name "notes" org-directory)))
          (unless (file-directory-p note-dir)
            (make-directory note-dir t)))
  :custom
  (org-noter-auto-save-last-location t)
  (org-noter-notes-search-path (expand-file-name "notes" org-directory))
  (org-noter-default-notes-file-names '("notes.org")))

;; PDF Tools ext
(use-package nov :after (org-noter) :demand t)
(use-package djvu :after (org-noter) :demand t)

;; Annotate PDFs
(use-package org-pdftools
  :ensure (org-pdftools
           :source nil :package "org-pdftools" :id org-pdftools
           :fetcher github :repo "that1guycolin/org-pdftools"
           :files ("org-pdftools.el") :old-names (org-preview)
           :type git :protocol https :inherit t :depth treeless)
  :after (org pdf-view-mode)
  :demand t
  :config (org-pdftools-setup-link))

(use-package org-noter-pdftools
  :ensure (org-noter-pdftools
           :source nil :package "org-noter-pdftools" :id org-noter-pdftools
           :repo "that1guycolin/org-pdftools" :fetcher github
           :files ("org-noter-pdftools.el")
           :type git :protocol https :inherit t :depth treeless)
  :after (org-noter org-pdftools)
  :demand t
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
  :functions (org-noter-insert-note
              org-noter--get-precise-info org-noter--parse-root
              org-noter--doc-approx-location org-entry-delete org-entry-put
              org-noter--pretty-print-location org-noter-pdftools-jump-to-note)
  :config (with-eval-after-load 'pdf-annot
            (add-hook 'pdf-annot-activate-handler-functions
                      #'org-noter-pdftools-jump-to-note)))

;; Recipe Management
(use-package org-chef
  :after (org)
  :demand t
  :preface
  (defvar that1guycolin/org-recipe-templates
    '(("c" "Cookbook" entry (file "~/org/cookbook.org")
       "%(org-chef-get-recipe-from-url)"
       :empty-lines 1)
      ("z" "Protocol Cookbook" entry (file "~/org/cookbook.org")
       "%(org-chef-get-recipe-string-from-url \"%:link\")"
       :empty-lines 1)
      ("m" "Manual Cookbook" entry (file "~/org/cookbook.org")
       "* %^{Recipe title: }\n  :PROPERTIES:\n  :source-url:\n  :servings:\n
:prep-time:\n  :cook-time:\n  :ready-in:\n  :END\n** Ingredients\n
%?\n** Directions\n\n"))))


;;; Babel
(use-package ob-rust
  :after (org)
  :demand t
  :custom (org-babel-rust-command "rust-script")
  :config (add-to-list 'org-babel-load-languages '(rust . t)))


;;; Appearance:
;; Improve Org appearance
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
  :after (org org-modern)
  :defer t
  :hook (org-modern-mode . org-modern-indent-mode))

;; Invisible drawers
(use-package org-tidy
  :after (org)
  :defer t
  :preface
  (defun that1guycolin/org-tidy-get-styles-cons ()
    "Return a cons list of values for `org-tidy-properties-style'.
Values are mapped to informative strings."
    (cond
     ((eq 'invisible org-tidy-properties-style)
      '(("Invisible (current)" . invisible)
        ("Fringe" . fringe) ("Inline" . inline)))
     ((eq 'fringe org-tidy-properties-style)
      '(("Fringe (current)" . fringe)
        ("Inline" . inline) ("Invisible" . invisible)))
     ((eq 'inline org-tidy-properties-style)
      '(("Inline (current)" . inline)
        ("Invisible" . invisible) ("Fringe" . fringe)))))
  
  (defun that1guycolin/org-tidy-switch-style ()
    "Interactively change the value of `org-tidy-properties-style'."
    (interactive)
    (that1guycolin/org-check)
    (let* ((cons-list (that1guycolin/org-tidy-get-styles-cons))
           (new-style-cons-string
            (completing-read "Select new `org-tidy-properties-style': "
                             (mapcar #'car cons-list) nil t))
           (new-style (cdr (assoc new-style-cons-string cons-list))))
      (unless (eq org-tidy-properties-style new-style)
        (setq org-tidy-properties-style new-style))))
  
  :bind ("C-:" . org-tidy-toggle)
  :hook (org-mode . org-tidy-mode)
  :custom
  (org-tidy-top-property-style 'invisible)
  (org-tidy-properties-style 'invisible))

(use-package org-appear
  :defer t
  :hook (org-mode . org-appear-mode))


;;; Misc:
;; .org from .el
(use-package el2org
  :after (org)
  :defer t
  :bind (("C-c 2 f" . el2org-generate-file)
         ("C-c 2 r" . el2org-generate-readme)
         ("C-c 2 h" . el2org-generate-html)
         ("C-c 2 o" . el2org-generate-org)))

;; Table-of-contents
(use-package org-make-toc
  :after (org)
  :defer t
  :bind (:map org-mode-map
              ("C-^" . org-make-toc-insert)
              ("C-&" . org-make-toc-set))
  :hook (org-mode . org-make-toc-mode)
  :custom (org-make-toc-insert-custom-ids t))

;; Manage time
(use-package org-pomodoro
  :after (org)
  :defer t
  :bind (:map org-mode-map ("M-P" . org-pomodoro))
  :custom (org-pomodoro-manual-break t))


(provide '06-org-config)
;;; 06-org-config.el ends here

                                        ; LocalWords:  bolp dt alnum GTD
