;;; 06-org-config.el --- Org-Mode Setup -*- lexical-binding: t; -*-

;;; Packages included:
;; djvu, el2org, nov, ob-rust, org-appear, org-category-capture, org-chef,
;; org-edna, org-make-toc, org-mem, org-modern, org-modern-indent, org-node,
;; org-node-backlink, org-noter, org-noter-pdftools, org-pdftools,
;; org-pomodoro, org-project-capture, org-recur, org-super-agenda, org-tidy,
;; pdf-tools

;;; Commentary:
;; Set up Emacs' Org-mode.  Also, configure packages that extend Org's already
;; awesome power.

;;; Code:
;;; Tasks:
;; Conditional task completion
(use-package org-edna
  :after (org)
  :demand t
  :functions (org-edna-mode)
  :config (org-edna-mode 1))

;; Project management via Org
(use-package org-project-capture
  :after (org-edna)
  :demand t
  :preface
  (declare-function project-root "project.el")
  (defvar org-agenda-files)
  (defvar org-directory)
  (defvar org-refile-targets)
  (defun that1guycolin/remove-org-todo ()
    "If a \='TODO.org' file exists in the org directory, delete it.
Because the org-directory is a git repo, there is a possibility of
accidentally creating a TODO file.  A TODO file in the org-directory is
by definition redundant, since any TODO items should go in the tasks
folder."
    (interactive)
    (unless (boundp 'org-directory)
      (error "Org-directory is not defined"))
    (let ((org-dir-todo (concat org-directory "/TODO.org")))
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
  :defines (org-recur-mode-map org-recur-agenda-mode-map)
  :custom
  (org-recur-finish-done t)
  (org-recur-finish-archive t))

(use-package org-super-agenda
  :after (org)
  :demand t
  :functions (org-super-agenda-mode)
  :init (org-super-agenda-mode)
  :custom
  (org-super-agenda-groups
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
  (declare-function org-id-get-create "org-id")
  (declare-function org-id-new "org-id")
  (declare-function that1guycolin/org-insert-header-block "01-bootstrap-core")
  (defvar org-mode-map)

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
  :defer t
  :preface
  (declare-function that1guycolin/inhibit-inhibit-mouse "03-visual.el")
  :magic ("%PDF" . pdf-view-mode)
  :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
  :functions (pdf-tools-install)
  :custom
  (pdf-view-display-size 'fit-page)
  (pdf-info-asynchronous t)
  :config (pdf-tools-install)
  (add-hook 'pdf-view-mode-hook #'that1guycolin/inhibit-inhibit-mouse))

;; Annotate
(use-package org-noter
  :defer t
  :preface
  (defvar dired-mode-map)
  (defvar dirvish-mode-map)
  (defvar that1guycolin/notes-directory
    (expand-file-name "notes" org-directory)
    "Directory in which org-noter files are stored.")
  :bind (("C-c o n". org-noter)
         (:map dired-mode-map
               ("N" . org-noter-start-from-dired))
         (:map dirvish-mode-map
               ("N" . org-noter-start-from-dired)))
  :init (unless (file-directory-p that1guycolin/notes-directory)
          (mkdir that1guycolin/notes-directory t))
  :custom
  (org-noter-auto-save-last-location t)
  (org-noter-notes-search-path that1guycolin/notes-directory)
  (org-noter-default-notes-file-names '("notes.org")))

;; PDF Tools ext
(use-package nov :after (org-noter) :demand t)
(use-package djvu :after (org-noter) :demand t)

;; Annotate PDFs
(use-package org-pdftools
  :after (org pdf-tools)
  :demand t
  :functions (org-pdftools-setup-link)
  :config (org-pdftools-setup-link))

(use-package org-noter-pdftools
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
  (defvar org-capture-templates)
  
  (defvar that1guycolin/org-recipe-templates
    '(("c" "Cookbook" entry (file "~/org/cookbook.org")
       "%(org-chef-get-recipe-from-url)"
       :empty-lines 1)
      ("z" "Protocol Cookbook" entry (file "~/org/cookbook.org")
       "%(org-chef-get-recipe-string-from-url \"%:link\")"
       :empty-lines 1)
      ("m" "Manual Cookbook" entry (file "~/org/cookbook.org")
       "* %^{Recipe title: }\n  :PROPERTIES:\n  :source-url:\n  :servings:\n  \
:prep-time:\n  :cook-time:\n  :ready-in:\n  :END:\n** Ingredients\n \
%?\n** Directions\n\n")))
  :config (setq org-capture-templates
                (append org-capture-templates
                        that1guycolin/org-recipe-templates)))


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
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode"))
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
  :preface
  (defvar-keymap that1guycolin/el2org-gen-map
    :doc "Keymap containing `el2org-generate-' functions."
    "r" #'el2org-generate-readme
    "h" #'el2org-generate-html
    "o" #'el2org-generate-org)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements that1guycolin/el2org-gen-map
      "r" "Generate README"
      "h" "Generate html"
      "o" "Generate Orgfile"))
  :bind-keymap ("C-c 2" . that1guycolin/el2org-gen-map)
  :functions (el2org-generate-readme el2org-generate-html el2org-generate-org))

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

                                        ; LocalWords: annot fF
