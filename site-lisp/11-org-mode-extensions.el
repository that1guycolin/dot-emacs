;;; 11-org-mode-extensions.el --- Extensions for Org-mode -*- lexical-binding: t; -*-

;;; Packages included:
;; djvu, el2org, nov, ob-rust, org-edna, org-make-toc, org-mem, org-modern,
;; org-modern-indent, org-node, org-noter, org-noter-pdftools, org-pdftools,
;; org-pomodoro, org-snitch, org-tidy, pdf-tools

;;; Commentary:
;; Provide extensions for Emacs' Org-mode.

;;; Code:
;;; Tasks:
;; Conditional task completion
(use-package org-edna
  :defer t
  :hook (org-mode . org-edna-mode))

;; Project management via Org
(use-package org-snitch
  :demand t
  :preface
  (declare-function user/current-project-root "05-project-management.el")
  (defvar git-commit-mode-map)

  (defun user/smart-project-file ()
    "Return the name of the project file depending on the current project."
    (if (string= "~/.config/emacs/" (user/current-project-root))
        "site-lisp/TODO.ORG" "TODO.org"))
  
  :bind
  (("C-c o s" . org-snitch-dispatch)
   :map org-snitch-link-mode-map
   ("C-c C-o" . org-open-at-point-global)
   ("C-c C-d" . org-snitch-mark-done))
  :functions (org-snitch-setup org-snitch-mode org-snitch-magit-insert-task)
  :custom
  (org-snitch-target-file (user/smart-project-file))
  (org-snitch-capture-key "p")
  (org-snitch-independent-submodules t)
  (org-snitch-capture-templates
   '(("t" . "Tasks")
     ("b" . "Bugs")
     ("f" . "Features")
     ("d" . "Docs")))

  :config
  (org-snitch-setup)
  (org-snitch-mode 1)
  (with-eval-after-load 'git-commit
    (keymap-set git-commit-mode-map
                "C-c C-t" #'org-snitch-magit-insert-task)))


;;; Knowledge
;; Org metadata index
(use-package org-mem
  :demand t
  :preface
  (declare-function org-id-update-id-locations "org")
  (declare-function org-id-get-create "org-id")
  (defvar org-directory)

  (defvar user/org-mem-setup-p nil
    "Non-nil if `user/org-mem-setup' has completed.")
  
  (defun user/org-mem-setup ()
    "Initialize the org-mem id database."
    (org-id-update-id-locations)
    (org-mem-roamy-db-mode 1)
    (org-mem-updater-mode 1)
    (setq
     org-mem-roamy-do-overwrite-real-db nil
     user/org-mem-setup-p t))

  (cl-defun user/org-mem-setup-wait (&optional (sec 3))
    "Wait SEC seconds before `org-mem-setup' (default: 3)."
    (unless (integerp sec)
      (error "Value of sec must be an INT, current value: %s" sec))
    (run-at-time sec nil #'user/org-mem-setup))

  :hook (emacs-startup . user/org-mem-setup-wait)
  :functions
  (org-mem-roamy-db-mode
   org-mem-updater-mode org-mem-reset org-mem-await org-mem-tip-if-empty)
  :defines (org-mem-roamy-do-overwrite-real-db)
  :custom
  (org-mem-watch-dirs
   (list (expand-file-name org-directory))))

;; Fast & simple note management
(use-package org-node
  :defer t
  :preface
  (declare-function org-id-new "org-id")
  (declare-function user/org-insert-header-block "01-bootstrap-core")
  
  (defun user/org-node-new-file (&optional title cust-id)
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
          (user/org-insert-header-block
           title "Colin Loeffler (that1guycolin)"))))

    (push (current-buffer) org-node--new-unsaved-buffers)
    (run-hooks 'org-node-creation-hook))

  :bind-keymap ("M-o" . org-node-global-prefix-map)
  :commands org-node-org-prefix-map
  :functions
  (org-node-pop-to-fresh-file-buffer
   org-node-cache-mode org-node-complete-at-point-mode org-node-backlink-mode)
  :defines (org-node-backlink-do-drawers)
  
  :init
  (keymap-set org-mode-map "M-o" org-node-org-prefix-map)
  :custom
  (org-node-creation-fn #'user/org-node-new-file)
  (org-node-file-directory-ask t)
  (org-node-prefer-with-heading nil)

  :config
  (org-node-cache-mode 1)
  (org-mem-updater-mode 1)
  (org-mem-reset nil "Org-node waiting for org-mem...")
  (org-mem-await "Org-node waiting for org-mem..." 60)
  (org-mem-tip-if-empty)
  (org-node-complete-at-point-mode 1)

  (require 'org-node-backlink)
  (setq org-node-backlink-do-drawers nil)
  (org-node-backlink-mode 1))

;; View PDFs in Emacs
(use-package pdf-tools
  :ensure (pdf-tools
           :source nil :package "pdf-tools" :id pdf-tools :fetcher github
           :repo "that1guycolin/pdf-tools"
           :files (:defaults "README" ("build" "Makefile") ("build" "server"))
           :type git :protocol https :inherit t :depth treeless)
  
  :defer t
  :magic ("%PDF" . pdf-view-mode)
  :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
  :functions (pdf-tools-install)
  :custom
  (pdf-view-display-size 'fit-page)
  (pdf-info-asynchronous t)
  :config
  (pdf-tools-install))

;; PDF Tools ext
(use-package nov
  :after (org-noter))

(use-package djvu
  :after (org-noter))

;; Annotate
(use-package org-noter
  :defer t
  :bind
  (("C-c n n". org-noter)
   :map dired-mode-map
   ("N"      . org-noter-start-from-dired))

  :init
  (let ((note-dir (expand-file-name "notes" org-directory)))
    (unless (file-directory-p note-dir)
      (make-directory note-dir t)))
  :custom
  (org-noter-auto-save-last-location t)
  (org-noter-notes-search-path (expand-file-name "notes" org-directory))
  (org-noter-default-notes-file-names '("notes.org")))

;; Annotate PDFs
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
  (org-noter-insert-note
   org-noter--get-precise-info org-noter--parse-root
   org-noter--doc-approx-location org-entry-delete org-entry-put
   org-noter--pretty-print-location org-noter-pdftools-jump-to-note)
  
  :config
  (with-eval-after-load 'pdf-annot
    (add-hook 'pdf-annot-activate-handler-functions
              #'org-noter-pdftools-jump-to-note)))


;;; Babel
(use-package ob-rust
  :after (org)
  :custom
  (org-babel-rust-command "rust-script")
  :config
  (add-to-list 'org-babel-load-languages '(rust . t)))


;;; Miscellaneous
;; .org from .el
(use-package el2org
  :defer t
  :bind
  (("C-c 2 f" . el2org-generate-file)
   ("C-c 2 r" . el2org-generate-readme)
   ("C-c 2 h" . el2org-generate-html)
   ("C-c 2 o" . el2org-generate-org)))

;; Table-of-contents
(use-package org-make-toc
  :defer t
  :bind (:map org-mode-map
              ("C-^" . org-make-toc-insert)
              ("C-&" . org-make-toc-set))
  :hook (org-mode . org-make-toc-mode)
  :custom
  (org-make-toc-insert-custom-ids t))

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
  :defer t
  :hook (org-modern-mode . org-modern-indent-mode))

;; Manage time
(use-package org-pomodoro
  :defer t
  :bind (:map org-mode-map
              ("M-P" . org-pomodoro))
  :custom
  (org-pomodoro-manual-break t))

;; Invisible drawers
(use-package org-tidy
  :defer t
  :preface
  (declare-function user/org-check "01-bootstrap-core")
  
  (defun user/org-tidy-get-styles-cons ()
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
  
  (defun user/org-tidy-switch-style ()
    "Interactively change the value of `org-tidy-properties-style'."
    (interactive)
    (user/org-check)
    (let* ((cons-list (user/org-tidy-get-styles-cons))
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


(provide '11-org-mode-extensions)
;;; 11-org-mode-extensions.el ends here
