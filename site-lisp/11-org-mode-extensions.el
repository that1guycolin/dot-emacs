;;; 11-org-mode-extensions.el --- Extensions for Org-mode -*- lexical-binding: t; -*-

;;; Packages included:
;; djvu, el2org, nov, ob-rust, org-edna, org-make-toc, org-mem, org-modern,
;; org-modern-indent, org-node, org-noter, org-noter-pdftools, org-pdftools,
;; org-pomodoro, org-snitch, org-tidy, pdf-tools

;;; Commentary:
;; Provide extensions for Emacs' Org-mode.

;;; Code:
(use-package org
  :defer t
  :preface
  (declare-function sly-eval "sly")

  ;; Helper functions
  (defun user/org-check ()
    "User-error if buffer is not in `org-mode'."
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode")))

  (defun user/org-id-prefix-slug (s)
    "Turn S into a safe(-ish) `org-id-prefix'."
    (when s
      (replace-regexp-in-string
       "-+" "-"
       (replace-regexp-in-string
        "[^[:alnum:]_]+" "-"
        (downcase s)))))

  (defun user/get-parent-directory ()
    "Return parent directory name for current buffer."
    (when buffer-file-name
      (file-name-nondirectory
       (directory-file-name
        (file-name-directory buffer-file-name)))))

  (defun user/org-id-context-prefix ()
    "Return `org-id-prefix' based on node level."
    (user/org-check)
    (cond
     ((org-before-first-heading-p)
      (user/get-parent-directory))
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

  (defun user/org-id-dynamic-prefix (orig-fn &rest args)
    "Dynamically compute org-id-prefix' each time an ID is created.
Designed to wrap around ORIG-FN `org-id-new' (accepting the same ARGS) when
creating org nodes."
    (defvar org-id-prefix)
    (let ((org-id-prefix
           (if (derived-mode-p 'org-mode)
               (or (user/org-id-prefix-slug (user/org-id-context-prefix))
                   org-id-prefix)
             (user/get-parent-directory))))
      (apply orig-fn args)))
  (advice-add 'org-id-new :around #'user/org-id-dynamic-prefix)

  (defun user/org-get-heading-location ()
    "In an org-mode buffer, prompt user to pick a scope.
The scope could be the entire buffer or a heading within that buffer.
For entire buffer, return the top of the buffer."
    (user/org-check)
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

  (defun user/org-top-property-drawer-id ()
    "Return ID from a top-of-file-property-drawer, or nil."
    (user/org-check)
    (save-excursion
      (goto-char (point-min))
      (when (looking-at org-property-drawer-re)
        (save-restriction
          (narrow-to-region (match-beginning 0) (match-end 0))
          (goto-char (point-min))
          (when (re-search-forward "^:ID:[ \t]+\\(.+\\)$" nil t)
            (string-trim (match-string 1)))))))

  ;; Insert blocks
  (defun user/org-insert-properties-drawer ()
    "Create org properties drawer at an interactively-selected heading."
    (interactive)
    (user/org-check)
    (goto-char (user/org-get-heading-location))
    (org-id-get-create)
    (unless (org-entry-get nil "CREATED")
      (org-entry-put nil "CREATED"
                     (format-time-string "[%Y-%m-%d %a %H:%M:%S]"))))
  
  (defun user/org-insert-header-block (title author)
    "Insert a header block at the top of the current document.
If there is a properties drawer at the top, the header block will go
underneath it.  The header block will contain the following fields:
\='TITLE:, AUTHOR: CREATED_DATE:, LAST_EDITED:, ID:, FILETAGS:'."
    (interactive
     (list (read-string "Title: " (file-name-base (buffer-name)))
           (let ((default "Colin Loeffler (that1guycolin)"))
             (read-string (format "Author [DEFAULT: \"%s\"]: " default)
                          nil nil default))))
    (user/org-check)
    (save-excursion
      (goto-char (point-min))
      (let ((id (or (user/org-top-property-drawer-id)
                    (org-id-new))))
        (if (looking-at org-property-drawer-re)
            (progn
              (goto-char (match-end 0))
              (unless (bolp)
                (insert "\n")))
          (insert ":PROPERTIES:\n"
                  ":ID:       " id "\n"
                  ":END:\n"))
        (insert "#+TITLE: " title
                "\n#+AUTHOR: " author
                "\n#+CREATED_DATE: "
                (format-time-string "[%Y-%m-%d %a %H:%M:%S]")
                "\n#+LAST_EDIT: "
                "\n#+ID: " id
                "\n#+FILETAGS: \n"))))

  (defun user/org-insert-src-block (lang)
    "Insert a block structure of the type #+begin_src LANG/#+end_src."
    (interactive
     (list
      (completing-read "Language: "
                       (mapcar #'car org-src-lang-modes) nil t)))
    (org-insert-structure-template "src")
    (insert lang "\n"))

  (defvar-keymap user/org-insert-block-map
    :doc "Keymap of functions for inserting/editing headers, drawers, srcblocks"
    "h" #'user/org-insert-header-block
    "d" #'user/org-insert-properties-drawer
    "s" #'user/org-insert-src-block)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements user/org-insert-block-map
      "h" "Header Block"
      "d" "Properties Drawer"
      "s" "Source Block"))

  (defun user/org-update-last-edit-dt ()
    "Update value of `LAST_EDIT' header in the active Org buffer.
The new value is the current date & time in this format:
YYYY-MM-DD DAY HH:MM:ss (e.g., 2026-03-15 SUN 14:24:06)"
    (when (derived-mode-p 'org-mode)
      (save-excursion
        (goto-char (point-min))
        (when (re-search-forward
               "^#\\+LAST_EDIT:[ \t]*.*$"
               nil t)
          (replace-match
           (format-time-string
            "#+LAST_EDIT: [%Y-%m-%d %a %H:%M:%S]"))))))
  (add-hook 'before-save-hook #'user/org-update-last-edit-dt)

  (defun user/org-convert-md-links ()
    "Convert all md-style links in the current buffer to org-style."
    (interactive)
    (user/org-check)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "\\[\\([^]]+\\)\\](\\([^)]+\\))" nil t)
        (replace-match "[[\\2][\\1]]" nil nil))))

  (defun user/org-search-folded ()
    "Set value of `search-invisible' to t in `org-mode' buffers.
Add this function to `org-mode-hook'."
    (if (derived-mode-p 'org-mode)
        (setq search-invisible t)
      (setq search-invisible nil)))

  :bind (("C-c o o" . org-mode)
         ("C-c c"   . org-capture)
         ("C-c o l" . org-store-link)
         :map org-mode-map
         ("C-c l"   . org-toggle-link-display)
         ("C-c C-q" . org-set-tags-command))
  :mode (("\\.org\\'"   . org-mode)
         ("\\.notes\\'" . org-mode))
  :functions (org-before-first-heading-p
              org-get-heading org-map-entries org-back-to-heading
              org-outline-level org-up-heading-safe org-get-outline-path
              org-id-get-create org-entry-get org-entry-put org-id-new
              org-insert-structure-template)
  :defines (org-babel-default-header-args:zsh org-babel-lisp-eval-fn)
  :init (if (eq system-type 'android)
            (setq org-directory "/storage/emulated/0/Documents/org")
          (setq org-directory (expand-file-name "~/org")))
  :custom
  (org-confirm-babel-evaluate nil)
  (org-default-notes-file (expand-file-name ".notes" org-directory))
  (org-edit-src-content-indentation 0)
  (org-id-locations-file (expand-file-name ".id-locations" org-directory))
  (org-id-method 'org)
  (org-id-prefix "unk")
  (org-insert-mode-line-in-empty-file t)
  (org-startup-folded 'fold)
  (org-use-sub-superscripts '{})
  :config
  (require 'org-id)
  (require 'ox-texinfo)
  (keymap-set org-mode-map "C-c b" user/org-insert-block-map)
  (add-hook 'org-mode-hook #'user/org-search-folded)

  (setq org-src-lang-modes (assoc-delete-all "bash" org-src-lang-modes))
  (dolist (lang-mode-cons '(("bash"   . bash-ts) ("cmake" . cmake-ts)
                            ("json"   . json-ts) ("lua"   . lua-ts)
                            ("python" . python-ts) ("sh"  . sh)
                            ("toml"   . toml-ts) ("yaml"  . yaml-ts)
                            ("zsh"    . shell)))
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
(use-package org-snitch
  :defer t
  :preface
  (declare-function user/current-project-root "05-project-management.el")
  (defvar git-commit-mode-map)

  (defun user/smart-project-file ()
    "Return the name of the project file depending on the current project."
    (if (string= "~/.config/emacs/" (user/current-project-root))
        "site-lisp/TODO.ORG" "TODO.org"))
  
  :bind (("C-c o s" . org-snitch-dispatch)
         :map org-snitch-link-mode-map
         ("C-c C-o" . org-open-at-point-global)
         ("C-c C-d" . org-snitch-mark-done))
  :functions (org-snitch-setup org-snitch-mode org-snitch-magit-insert-task)
  :config
  (with-eval-after-load 'org
    (setq
     org-snitch-target-file "TODO.org"
     org-snitch-capture-key "p"
     org-snitch-independent-submodules t
     org-snitch-capture-templates
     '(("t" . "Tasks")
       ("b" . "Bugs")
       ("f" . "Features")
       ("d" . "Docs")))
    (org-snitch-setup)
    (org-snitch-mode 1)
    (with-eval-after-load 'git-commit
      (keymap-set git-commit-mode-map
                  "C-c C-t" #'org-snitch-magit-insert-task))))


;;; Knowledge
;; Org metadata index
(use-package org-mem
  :after (org)
  :demand t
  :preface (declare-function org-id-update-id-locations "org-id")
  :functions (org-mem-roamy-db-mode
              org-mem-updater-mode org-mem-reset org-mem-await
              org-mem-tip-if-empty)
  :defines (org-mem-roamy-do-overwrite-real-db)
  :custom (org-mem-watch-dirs (list (expand-file-name org-directory))))

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
  :commands (org-node-org-prefix-map)
  :functions (org-node-pop-to-fresh-file-buffer
              org-node-cache-mode org-node-complete-at-point-mode
              org-node-backlink-mode)
  :defines (org-node-backlink-do-drawers)
  :init (keymap-set org-mode-map "M-o" org-node-org-prefix-map)
  :config
  (with-eval-after-load 'org
    (setq
     org-node-creation-fn #'user/org-node-new-file
     org-node-file-directory-ask t
     org-node-prefer-with-heading nil)
    (org-node-cache-mode 1)
    (org-mem-updater-mode 1)
    (org-mem-reset nil "Org-node waiting for org-mem...")
    (org-mem-await "Org-node waiting for org-mem..." 60)
    (org-mem-tip-if-empty)
    (org-node-complete-at-point-mode 1)

    (require 'org-node-backlink)
    (setq org-node-backlink-do-drawers nil)
    (org-node-backlink-mode 1)))

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
  :config (pdf-tools-install))

;; Annotate
(use-package org-noter
  :defer t
  :bind (("C-c n n". org-noter)
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
  :after (org)
  :defer t
  :hook (org-mode . org-pdftools-setup-link))

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


;;; Babel
(use-package ob-rust
  :after (org)
  :demand t
  :custom (org-babel-rust-command "rust-script")
  :config (add-to-list 'org-babel-load-languages '(rust . t)))


;;; Miscellaneous
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

;; Improve Org appearance
(use-package org-modern
  :after (org)
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

;; Manage time
(use-package org-pomodoro
  :after (org)
  :defer t
  :bind (:map org-mode-map ("M-P" . org-pomodoro))
  :custom (org-pomodoro-manual-break t))

;; Invisible drawers
(use-package org-tidy
  :after (org)
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
