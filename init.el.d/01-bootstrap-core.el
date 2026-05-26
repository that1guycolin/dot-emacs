;;; 01-bootstrap-core.el --- Load startup and core packages -*- lexical-binding: t; -*-

;;; Packages included:
;; envrc, exec-path-from-shell, gcmh, org, transient

;;; Commentary:
;; Elpaca package manager bootstrap and packages that must load first because
;; they have a major inpact on startup.

;;; Code:
;; =======  ELPACA  =======
;; (from github:progfolio/elpaca)
;; ========================
(declare-function elpaca-generate-autoloads "elpaca")
(declare-function elpaca-process-queues "elpaca")
(declare-function elpaca "elpaca")
(declare-function elpaca-manager "elpaca")
(declare-function elpaca-use-package-mode "elpaca-use-package")
(defvar elpaca-use-package)
(defvar use-package-always-ensure)

(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(keymap-global-set "C-c M-c" #'elpaca-manager)

(elpaca elpaca-use-package
  (elpaca-use-package-mode 1))
(setq use-package-always-ensure t)

(declare-function elpaca-wait "elpaca")


;; =======  OTHER BOOTSTRAPS  =======
;; `gcmh' (smart garbage collection)
;; `exec-path-from-shell' `envrc' (environment)
;; `transient' `org' (load latest version early to override built-in pkg)
;; ==================================
(use-package gcmh
  :demand t
  :preface
  (defun user/restore-sane-gcmh-values ()
    "Set gcmh values back to something reasonable.  Useful after startup."
    (setopt
     gcmh-high-cons-threshold (* 100 1024 1024)
     gc-cons-percentage 0.1))
  :hook (emacs-startup . user/restore-sane-gcmh-values)
  :functions gcmh-mode
  :init (gcmh-mode 1))

(use-package exec-path-from-shell
  :demand t
  :functions exec-path-from-shell-initialize
  :custom
  (exec-path-from-shell-shell-name "zsh")
  :config
  (dolist (var '("CC" "CXX" "PKG_CONFIG_PATH" "SSH_AGENT_PID" "SSH_AUTH_SOCK"
		 "LSP_USE_PLISTS"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(use-package envrc
  :defer t
  :hook (emacs-startup . envrc-global-mode)
  :functions envrc-global-mode)

(use-package transient
  :demand t)

(use-package org
  :ensure (:wait t)
  :demand t
  :preface
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
    "Return `org-id-prefix' based on the node's level."
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
    (let ((org-id-prefix
	   (or (user/org-id-prefix-slug (user/org-id-context-prefix))
	       org-id-prefix)))
      (apply orig-fn args)))
  (advice-add 'org-id-new :around #'user/org-id-dynamic-prefix)

  (defun user/convert-md-links-to-org ()
    "Convert all md-style links in the current buffer to org-style."
    (interactive)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "\\[\\([^]]+\\)\\](\\([^)]+\\))" nil t)
	(replace-match "[[\\2][\\1]]" nil nil))))
  
  :bind
  (("C-c o o" . org-mode)
   ("C-c o l" . org-store-link)
   ("C-c o a" . org-agenda)
   ("C-c c"   . org-capture)
   :map org-mode-map
   ("C-c l"   . org-toggle-link-display)
   ("C-c C-q" . org-set-tags-command))
  :mode
  (("\\.org\\'"   . org-mode)
   ("TODO\\'"     . org-mode)
   ("\\.notes\\'" . org-mode))
  :defines org-mode-map
  
  :init
  (setq org-directory (expand-file-name "~/org"))
  :custom
  (org-babel-lisp-eval-fn #'sly-eval)
  (org-confirm-babel-evaluate nil)
  (org-default-notes-file (expand-file-name ".notes" org-directory))
  (org-id-extra-files (directory-files-recursively org-directory "\\.org$"))
  (org-id-locations-file (expand-file-name ".id-locations" org-directory))
  (org-id-method 'org)
  (org-id-prefix "unk")
  (org-insert-mode-line-in-empty-file t)
  (org-startup-folded 'content)
  (org-use-sub-superscripts '{})
  
  :config
  (require 'ox-texinfo)
  (setq org-babel-default-header-args
	(cons '(:results . "value verbatim replace")
	      (assq-delete-all :results org-babel-default-header-args)))
  (org-babel-do-load-languages
   'org-babel-load-languages '((emacs-lisp . t) (lisp . t) (lua . t)
			       (makefile . t) (org . t) (python . t)
			       (shell . t)))
  
  (setq org-src-lang-modes (assoc-delete-all "bash" org-src-lang-modes))
  (dolist (lang-mode-cons '(("bash" . bash-ts) ("cmake" . cmake-ts)
  			    ("json" . json-ts) ("lua" . lua-ts)
  			    ("python" . python-ts) ("sh" . sh)
			    ("toml" . toml-ts) ("yaml" . yaml-ts)
			    ("zsh" . shell)))
    (add-to-list 'org-src-lang-modes lang-mode-cons)))


;; =======  EMACSCLIENT FRAME FUNCTION  =======
(defun user/function-after-emacsclient-frame (func &optional args)
  "Run FUNC and any ARGS only after a real emacsclient frame is created."
  (let ((frame (selected-frame)))
    (when (and (display-graphic-p frame)
	       (frame-parameter frame 'client)
	       (string-prefix-p "*scratch*" (buffer-name)))
      (funcall func args))))


(provide '01-bootstrap-core)
;;; 01-bootstrap-core.el ends here
