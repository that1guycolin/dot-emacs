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
;; `transient' `org' (load latest early, override built-in)
;; ==================================
(use-package gcmh
  :demand t
  :functions
  gcmh-mode user/restore-sane-gcmh-values
  :config
  (gcmh-mode 1)
  (setopt gcmh-high-cons-threshold most-positive-fixnum
          gcmh-low-cons-threshold (* 8 1024 1024)
          gcmh-idle-delay 'auto
          gc-cons-percentage 0.8)

  (defun user/restore-sane-gcmh-values ()
    "Set gcmh values back to something reasonable.  Useful after startup."
    (interactive)
    (setopt
     gcmh-high-cons-threshold (* 100 1024 1024)
     gc-cons-percentage 0.1))
  
  (add-hook 'emacs-startup-hook #'user/restore-sane-gcmh-values))

(use-package exec-path-from-shell
  :demand t
  :functions exec-path-from-shell-initialize
  :defines exec-path-from-shell-shell-name
  :init
  (setq exec-path-from-shell-shell-name "/usr/bin/zsh")
  :config
  (dolist (var '("CC" "CXX" "PKG_CONFIG_PATH" "SSH_AGENT_PID" "SSH_AUTH_SOCK"
		 "LSP_USE_PLISTS"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(use-package envrc
  :demand t
  :functions envrc-global-mode
  :config
  (envrc-global-mode 1))

(use-package transient
  :demand t)

(use-package org
  :ensure (org
	   :package "org" :source "Org" :protocol https :inherit t :depth 1
	   :pre-build (progn
			(require 'elpaca-menu-org)
			(setq elpaca-menu-org-make-manual nil)
			(elpaca-menu-org--build))
	   :host github :repo "emacsmirror/org" :autoloads "org-loaddefs.el"
	   :build (:not elpaca--generate-autoloads-async)
	   :files (:defaults ("etc/styles/" "etc/styles/*" "doc/*.texi"))
	   :wait t)
  :demand t
  :mode
  (("\\.org\\'"   . org-mode)
   ("TODO\\'"     . org-mode)
   ("\\.notes\\'" . org-mode))
  :defines org-mode-map
  
  :init
  (setq org-directory (expand-file-name "~/org"))

  :custom
  (org-default-notes-file
   (expand-file-name ".notes" org-directory))
  (org-id-locations-file (expand-file-name ".id-locations" org-directory))
  (org-insert-mode-line-in-empty-file t)
  (org-use-sub-superscripts '{})

  :config
  (with-eval-after-load 'org-babel
    (org-babel-do-load-languages 'org-babel-load-languages
				 '((emacs-lisp . t)
				   (lisp       . t)
				   (lua        . t)
				   (makefile   . t)
				   (org        . t)
				   (python     . t)
				   (shell      . t)))
    (setq org-babel-lisp-eval-fn #'sly-eval)
    (setq-default org-confirm-babel-evaluate nil))

  (setq
   org-id-method 'org
   org-id-prefix "unk")

  (setq org-id-extra-files
	(directory-files-recursively
	 (expand-file-name org-directory "knowledge-base")
	 "\\.org$"))
  (org-id-update-id-locations org-id-extra-files)
  
  (defun user/get-parent-directory ()
    "Return parent directory name for current buffer."
    (when buffer-file-name
      (file-name-nondirectory
       (directory-file-name
	(file-name-directory buffer-file-name)))))

  (defun user/org-id-dynamic-prefix (orig-fn &rest args)
    "Dynamically compute `org-id-prefix' each time an ID is created."
    (let ((org-id-prefix (or (user/get-parent-directory) org-id-prefix)))
      (apply orig-fn args)))
  (advice-add 'org-id-new :around #'user/org-id-dynamic-prefix)

  (bind-keys
   ("C-c o o" . org-mode)
   ("C-c o l" . org-store-link)
   ("C-c o a" . org-agenda)
   ("C-c c"   . org-capture)
   :map org-mode-map
   ("C-c l"   . org-toggle-link-display)
   ("C-c C-q" . org-set-tags-command))

  (with-eval-after-load 'org-agenda
    (bind-keys
     ("C-c o k" . org-agenda-kill-all-agenda-buffers))))


(provide '01-bootstrap-core)
;;; 01-bootstrap-core.el ends here
