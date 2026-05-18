;;; early-init.el --- Load first  -*- lexical-binding: t; -*-

;;; Commentary:
;; Set initial values for variables that affect startup performance and UI.
;; Configures backup directories, disables package.el, sets load paths,
;; and applies early UI optimizations before the main config loads.

;;; Code:
;; Set the environment variable "EMACS_PROFILE_STARTUP" to yes (or to any
;; string) to create a cpu profile report on your startup.
(defvar user/profile-startup nil
  "When non-nil, enable CPU profiling during startup.")
(when user/profile-startup
  (setq debug-on-error t)
  (profiler-start 'cpu)
  (add-hook 'emacs-startup-hook
	    #'(lambda ()
		(profiler-cpu-stop)
		(require 'profiler)
		(profiler-report))))

;; Ignore `tramp' and `compressed'/`archive' files during start
(defvar user/file-name-handler-alist-backup file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq
	     file-name-handler-alist user/file-name-handler-alist-backup)))

(setq
 ;; No garbage collection during startup
 gc-cons-threshold most-positive-fixnum

 ;;Prefer loading newest file
 load-prefer-newer t

 ;; Disable package.el
 package-enable-at-startup nil
 package-quickstart nil

 ;; auth/vc
 auth-sources '("~/.authinfo.gpg")
 version-control t
 kept-new-versions 4
 kept-old-versions 4
 delete-old-versions t
 
 ;; Reduce startup "noise"
 inhibit-message t
 inhibit-startup-message t
 inhibit-startup-echo-area-message user-login-name
 inhibit-startup-screen t
 initial-scratch-message nil
 auto-mode-case-fold nil
 frame-inhibit-implied-resize t
 inhibit-compacting-font-caches t
 read-process-output-max (* 1024 1024)
 redisplay-skip-fontification-on-input t
 command-line-x-option-alist nil
 select-active-regions 'only
 create-lockfiles nil
 vc-follow-symlinks t
 use-short-answers t)

;; Variables depending on package load
(with-eval-after-load 'ffap
  (setq ffap-machine-p-known 'reject))
(with-eval-after-load 'which-function-mode
  (setq which-func-update-delay 1.0))
(with-eval-after-load 'dired
  (setq-default dired-kill-when-opening-new-dired-buffer t))

;; Configure autosaves and backups.
(let ((backup-dir (expand-file-name "~/backups/"))
      (autosave-dir (expand-file-name "~/auto-saves/")))
  (unless (file-exists-p backup-dir)
    (make-directory backup-dir t))
  (unless (file-exists-p autosave-dir)
    (make-directory autosave-dir t))
  (setq
   backup-directory-alist `(("." . ,backup-dir))
   auto-save-file-name-transforms `((".*" ,autosave-dir t))))

;; Early UI optimizations
(setq-default
 cursor-type 'bar
 fill-column 80)
(when (fboundp 'global-tab-line-mode)
  (global-tab-line-mode 1))

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'tooltip-mode)
  (tooltip-mode -1))


(provide 'early-init)

;;; early-init.el ends here
