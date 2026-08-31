;;; c-org.el --- Latest Org -*- lexical-binding: t -*-

;;; Commentary:
;; Load the latest version of Org rather than the built-in version.

;;; Code:
(use-package org
  :ensure (:wait t)
  :demand t
  :preface
  (declare-function that1guycolin/desktop-mobile "init.el")
  (declare-function sly-eval "sly")

  (defun that1guycolin/org-check ()
    "User-error if buffer is not in `org-mode'."
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode")))

;;; `org-id-prefix' functions
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
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode"))
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

;;; Custom header settings
  (defun that1guycolin/org-get-heading-location ()
    "In an org-mode buffer, prompt user to pick a scope.
The scope could be the entire buffer or a heading within that buffer.
For entire buffer, return the top of the buffer."
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode"))
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
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode"))
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

;;; Insert objects
  (defun that1guycolin/org-insert-properties-drawer (&optional interactivep)
    "Create org properties drawer at an interactively-selected heading."
    (interactive "p")
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode"))
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
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode"))
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

;;; Org task sequences
  (defconst that1guycolin/org-keywords--tasks
    '(sequence "TODO(t!)" "NEXT(n!)" "WAIT(w@/!)" "|"
               "DONE(d!)" "CANCELLED(c@)")
    "Keyword sequence with names based on the getting-things-done method.
Their implementation in this config is far less strict than traditional GTD.")

  (defconst that1guycolin/org-keywords--ideas
    '(sequence "IDEA(i!)" "PLANNING(p!)" "IMPLEMENTATION(m!)" "|"
               "COMPLETE(e!)" "ABANDONED(a@)")
    "Keyword sequence for turning dreams into reality.")

  (defconst that1guycolin/org-keywords--daily
    '(sequence "TODAY(y!)" "|" "COMPLETE(e!)")
    "Keyword sequence for daily tasks.")

  (defconst that1guycolin/org-keywords--someday
    '(sequence "SOMEDAY(s)" "RESEARCH(h!)" "|" "NEVER(v@)")
    "Keyword sequence to track things you might do \"someday\".
Note the absence of a \='completed' keyword; objects from this pipeline
move to either the \"tasks\" or the \"ideas\" pipeline to then be
completed.")

  (defconst that1guycolin/org-keywords--reading-list
    '(sequence "TO READ(r)" "READING(R!)" "|" "FINISHED(f)" "UNREAD(u@)")
    "Keyword sequence to track books to read.")

  (defconst that1guycolin/org-keywords--media-download
    '(sequence "TAGGED(g)" "|" "DOWNLOADED(w)" "IGNORED(I@)")
    "Keyword sequence to track media downloads.")

;;; Daily task functions
  (defun that1guycolin/today-date ()
    "Return a string containing today's date in the form YYYY-mm-dd."
    (format-time-string "%Y-%m-%d"))

  (defun that1guycolin/org-rollover-daily-tasks ()
    "Archive completed tasks from yesterday, and roll over incomplete tasks.
Create a new heading for today's date, and place the rolled over tasks
underneath."
    (interactive)
    (let* ((yesterday (format-time-string "%Y-%m-%d"
                                          (time-subtract nil (days-to-time 1))))
           (today (format-time-string "%Y-%m-%d"))
           (daily-task-file (expand-file-name "TODOs/today.org" org-directory))
           (archive-file (expand-file-name
                          (format-time-string "archive/%Y.org")
                          org-directory))
           (heading-regexp (format "^\\* %s[ \t]*$" (regexp-quote yesterday))))
      (with-current-buffer
          (find-file-noselect daily-task-file)
        (goto-char (point-min))
        (unless (re-search-forward heading-regexp nil t)
          (user-error "Could not find yesterday's heading: %s" yesterday))
        (org-back-to-heading t)
        (let* ((heading-start (point))
               (section-end (save-excursion
                              (org-end-of-subtree t t)))
               (heading-line (concat "*" (buffer-substring-no-properties
                                          (line-beginning-position)
                                          (line-end-position))))
               completed
               incomplete)
          (save-excursion
            (forward-line 1)
            (while (< (point) section-end)
              (when (looking-at "^[ \t]*- \\[\\([ Xx]\\)\\]\\(.*\\)$")
                (let ((task (buffer-substring-no-properties
                             (line-beginning-position)
                             (line-end-position))))
                  (if (member (match-string 1) '("X" "x"))
                      (push task completed)
                    (push task incomplete))))
              (forward-line 1)))

          (when completed
            (with-temp-buffer
              (insert heading-line "\n")
              (dolist (task completed)
                (insert task "\n"))
              (insert "\n")
              (if (file-exists-p archive-file)
                  (progn
                    (append-to-file (point-min) (point-max) archive-file)
                    (unless (bolp)
                      (write-region "\n" nil archive-file 'append)))
                (write-file archive-file))))

          (delete-region heading-start section-end)
          (goto-char heading-start)
          (insert "* " today "\n")
          (dolist (task incomplete)
            (insert task "\n"))
          (save-buffer)))))

  
;;; Capture Templates
  (defconst that1guycolin/org-templates--task
    '("t" "Task" entry (file "TODOs/tasks.org")
      "* TODO %^{Title}\n:PROPERTIES:\n:CREATED: %U\n:END:\n- %?"
      :empty-lines 1
      :kill-buffer t))

  (defconst that1guycolin/org-templates--idea
    '("i" "Idea" entry (file "TODOs/ideas.org")
      "* IDEA %^{Title}\n:PROPERTIES:\n:CREATED: %U\n:END:\n** %?"
      :empty-lines 1
      :kill-buffer t))

  (defconst that1guycolin/org-templates--daily
    '("d" "Daily Task" checkitem
      (file+headline "TODOs/today.org" that1guycolin/today-date)
      "- [ ] %?"
      :kill-buffer t))

  (defconst that1guycolin/org-templates--someday
    '("s" "Someday" entry
      (file "TODOs/someday.org")
      "* SOMEDAY %^{Title}\n:PROPERTIES:\n:CREATED: %U\n:END:\n- %?"
      :empty-lines 1
      :kill-buffer t))

  (defconst that1guycolin/org-templates--reading-list
    '("b" "Book" entry (file "TODOs/reading-list.org")
      "* TO READ Title: %^{Title}\nAuthor: %?\nComments: "
      :empty-lines 1
      :kill-buffer t))

  (defconst that1guycolin/org-templates--media-download
    '("m" "Media" entry (file "TODOs/media-download.org")
      "* TAGGED Title: %^{Title}\n- URL: %^{URL}\n- Actors: %?\n- Studio: "
      :empty-lines 1
      :kill-buffer t))

;;; misc.
  (defun that1guycolin/org-convert-md-links ()
    "Convert all md-style links in the current buffer to org-style."
    (interactive)
    (unless (derived-mode-p 'org-mode)
      (user-error "This buffer is not in org mode"))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "\\[\\([^]]+\\)\\](\\([^)]+\\))" nil t)
        (replace-match "[[\\2][\\1]]" nil nil))))

;;; finish use-package sexp
  :bind (("C-c o o" . org-mode)
         ("C-c o a" . org-agenda)
         ("C-c o c" . org-capture)
         ("C-c o l" . org-store-link)
         (:map org-mode-map
               ("C-c l"   . org-toggle-link-display)
               ("C-c C-q" . org-set-tags-command)))
  :mode (("\\.org\\'"   . org-mode)
         ("\\.notes\\'" . org-mode))
  :functions (org-before-first-heading-p
              org-get-heading org-map-entries org-back-to-heading
              org-outline-level org-up-heading-safe org-get-outline-path
              org-id-get-create org-entry-get org-entry-put org-id-new
              org-insert-structure-template)
  :defines (org-agenda-files org-babel-default-header-args:zsh
                             org-babel-lisp-eval-fn org-directory
                             org-mode-map)
  :init (that1guycolin/desktop-mobile
          (setq org-directory (expand-file-name "~/org"))
          (setq org-directory "/storage/emulated/0/Documents/org"))
  :custom
  (org-agenda-files
   (directory-files (expand-file-name "TODOs/" org-directory) t
                    directory-files-no-dot-files-regexp))
  (org-agenda-diary-file (expand-file-name "diary.org" org-directory))
  (org-archive-location
   (expand-file-name
    (format-time-string "archive/%Y.org::datetree/* %%s") org-directory))
  (org-capture-templates
   (list that1guycolin/org-templates--task
         that1guycolin/org-templates--idea
         that1guycolin/org-templates--daily
         that1guycolin/org-templates--someday
         that1guycolin/org-templates--reading-list
         that1guycolin/org-templates--media-download))
  (org-clock-clocked-in-display 'mode-line)
  (org-clock-idle-time 15)
  (org-clock-into-drawer t)
  (org-confirm-babel-evaluate nil)
  (org-default-notes-file (expand-file-name "tasks/tasks.org" org-directory))
  (org-edit-src-content-indentation 0)
  (org-id-locations-file (expand-file-name ".id-locations" org-directory))
  (org-id-method 'org)
  (org-id-prefix "default")
  (org-insert-mode-line-in-empty-file t)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-startup-folded 'show2levels)
  (org-todo-keywords
   (list that1guycolin/org-keywords--tasks that1guycolin/org-keywords--ideas
         that1guycolin/org-keywords--daily that1guycolin/org-keywords--someday
         that1guycolin/org-keywords--reading-list
         that1guycolin/org-keywords--media-download))
  (org-todo-keyword-faces
   '(("IDEA"           . (:foreground "gold"            :weight bold))
     ("PLANNING"       . (:foreground "orange"          :weight bold))
     ("IMPLEMENTATION" . (:foreground "cornflower blue" :weight bold))
     ("TODO"           . (:foreground "purple"          :weight bold))
     ("NEXT"           . (:foreground "deep sky blue"   :weight bold))
     ("WAIT"           . (:foreground "plum"            :weight bold))
     ("TODAY"          . (:foreground "pale green"      :weight bold))
     ("DONE"           . (:foreground "dim gray"        :weight bold))
     ("CANCELLED"      . (:foreground "dark gray"       :weight bold))))
  (org-use-sub-superscripts '{})
  :config
  (require 'org-id)
  (require 'org-protocol)
  (require 'ox-texinfo)
  (keymap-set org-mode-map "C-c b" that1guycolin/org-insert-block-map)
  (let ((lang-mode-cells '(("bash"  . bash-ts) ("bash2" . bash-ts)
                           ("cmake" . cmake-ts) ("json" . json-ts)
                           ("lua"   . lua-ts) ("python" . python-ts)
                           ("toml"  . toml-ts) ("yaml"  . yaml-ts))))
    (setq org-src-lang-modes
          (assoc-delete-all (car lang-mode-cells) org-src-lang-modes))
    (dolist (lang-cons lang-mode-cells)
      (add-to-list 'org-src-lang-modes lang-cons)))

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


(provide 'c-org)
;;; c-org.el ends here
