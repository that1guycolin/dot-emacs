;;; 01-bootstrap-core.el --- Load startup and core packages -*- lexical-binding: t; -*-

;;; Packages included:
;; elpaca, elpaca-use-package, envrc, exec-path-from-shell, gcmh, org, transient

;;; Commentary:
;; Elpaca package manager bootstrap and packages that must load first because
;; they have a major inpact on startup.

;;; Code:
;;;; =======  ELPACA  =======
;; `elpaca'              (asyncronous package manager)
;; `elpaca-use-package'  (integration with existing macro)
;;   ========================
(declare-function elpaca                  "elpaca")
(declare-function elpaca-manager          "elpaca")
(declare-function elpaca-use-package-mode "elpaca-use-package")
(declare-function elpaca-wait             "elpaca")
(defvar           elpaca-queue-limit)
(defvar           elpaca-use-package)
(defvar           use-package-always-ensure)

(if (eq system-type 'android)
    (setq elpaca-queue-limit 4)
  (setq elpaca-queue-limit 8))

(let ((elpaca-bootstrap
       (expand-file-name "elpaca/sources/elpaca/doc/installer.el"
                         user-emacs-directory)))
  (if (file-exists-p elpaca-bootstrap)
      (load-file elpaca-bootstrap)
    (let ((online-bootstrap
           (expand-file-name "bootstrap.el" user-emacs-directory)))
      (shell-command
       (format "wget -O %s \
https://raw.githubusercontent.com/progfolio/elpaca/refs/heads/master/doc/installer.el"
               online-bootstrap))
      (load-file online-bootstrap)
      (delete-file online-bootstrap))))

(elpaca elpaca-use-package
  (elpaca-use-package-mode 1))
(setq use-package-always-ensure t)
(elpaca-wait)


;;;; =======  GLOBAL SETTINGS  =======
(use-package emacs
  :ensure nil
  :demand t
  :preface
  (defun user/check-parens-with-message ()
    "Run `check-parens'.  Print a message when all parentheses match."
    (interactive)
    (when (not (check-parens))
      (message "All parentheses match!")))

  (defun user/ibuffer-hook-functions ()
    "Group of functions to include in `ibuffer-mode-hook'."
    (hl-line-mode 1)
    (ibuffer-auto-mode 1))

  (defvar user/emacs-load-libs '(bs cl-lib hl-line mouse seq subr-x)
    "List of optional Emacs libraries to load at Emacs start.")

  :bind
  (("C-c x"   . toggle-frame-maximized)
   ("C-c ("   . user/check-parens-with-message)
   ("C-c #"   . display-line-numbers-mode)
   ("C-c C-#" . global-display-line-numbers-mode)
   ("C-c C-$" . restart-emacs))
  :functions ibuffer-auto-mode
  :custom
  (auto-save-visited-interval 60)
  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (read-extended-command-predicate #'command-completion-default-include-p)
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  :config
  (dolist (lib user/emacs-load-libs)
    (require lib))

  (abbrev-mode 1)
  (auto-save-visited-mode 1)
  (context-menu-mode 1)
  (global-display-fill-column-indicator-mode 1)
  (which-key-mode 1)
  
  (add-hook 'ibuffer-mode-hook #'user/ibuffer-hook-functions))


;;;; =======  OTHER BOOTSTRAPS  =======
;; `gcmh'                                (smart garbage collection)
;; `exec-path-from-shell' `envrc'        (environment)
;; `transient' `org'                     (override built-in ver w/ latest ver)
;;   ==================================
(use-package gcmh
  :demand t
  :functions gcmh-mode
  :init (gcmh-mode 1))

(use-package exec-path-from-shell
  :demand t
  :preface
  (defvar user/exec-path-from-shell-vars
    '("CC"
      "CXX" "LSP_USE_PLISTS" "PKG_CONFIG_PATH" "SSH_AGENT_PID" "SSH_AUTH_SOCK"
      "WAYLAND_DISPLAY")
    "List of environment variables to load at Emacs start.")
  :functions exec-path-from-shell-initialize
  :custom
  (exec-path-from-shell-shell-name "zsh")
  :config
  (dolist (var user/exec-path-from-shell-vars)
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(use-package envrc
  :demand t
  :functions envrc-global-mode
  :config
  (envrc-global-mode 1))

(use-package transient
  :ensure (:wait t)
  :demand t)

(use-package org
  :demand t
  :preface
  (declare-function sly-eval "sly")
  
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

  (defun user/org-insert-properties-drawer ()
    "Create org properties drawer at an interactively-selected heading."
    (interactive)
    (user/org-check)
    (goto-char (user/org-get-heading-location))
    (org-id-get-create)
    (unless (org-entry-get nil "CREATED")
      (org-entry-put nil "CREATED"
                     (format-time-string "[%Y-%m-%d %a %H:%M:%S]"))))

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

  :bind
  (("C-c o o" . org-mode)
   ("C-c o l" . org-store-link)
   :map org-mode-map
   ("C-c l"   . org-toggle-link-display)
   ("C-c C-q" . org-set-tags-command))
  :mode
  (("\\.org\\'"   . org-mode)
   ("\\.notes\\'" . org-mode))
  :functions
  org-before-first-heading-p org-get-heading org-map-entries org-back-to-heading
  org-outline-level org-up-heading-safe org-get-outline-path org-id-get-create
  org-entry-get org-entry-put org-id-new org-insert-structure-template
  :defines
  org-babel-default-header-args:zsh org-babel-lisp-eval-fn

  :init
  (if (eq system-type 'android)
      (setq org-directory "/storage/emulated/0/Documents/org")
    (setq org-directory (expand-file-name "~/org")))
  :custom
  (org-confirm-babel-evaluate nil)
  (org-default-notes-file (expand-file-name ".notes" org-directory))
  (org-edit-src-content-indentation 0)
  (org-id-extra-files (if (file-directory-p org-directory)
                          (directory-files-recursively org-directory "\\.org$")))
  (org-id-locations-file (expand-file-name ".id-locations" org-directory))
  (org-id-method 'org)
  (org-id-prefix "unk")
  (org-insert-mode-line-in-empty-file t)
  (org-startup-folded 'fold)
  (org-use-sub-superscripts '{})
  :config
  (require 'ox-texinfo)

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
    (with-eval-after-load 'sly
      (if org-babel-lisp-eval-fn
          (setq org-babel-lisp-eval-fn #'sly-eval)
        (defvar org-babel-lisp-eval-fun #'sly-eval)))
    (dolist (lang '(lisp lua makefile org python shell))
      (add-to-list 'org-babel-load-languages `(,lang . t)))
    (org-babel-do-load-languages
     'org-babel-load-languages
     org-babel-load-languages)))


(provide '01-bootstrap-core)
;;; 01-bootstrap-core.el ends here
