;;; early-init.el --- Emacs early init  -*- lexical-binding: t; no-byte-compile: t; -*-

;;; Commentary:
;; Set initial values for variables that affect startup performance and UI.
;; Configures backup directories, disables package.el, sets load paths,
;; and applies early UI optimizations before the main config loads.

;;; Code:
;;(profiler-start 'cpu)
(defvar user/profile-startup nil
  "When non-nil, enable CPU profiling during startup.")
;; (setq debug-on-error t)

(setenv "PATH" (format "%s:%s" "/data/data/com.termux/files/usr/bin"
		       (getenv "PATH")))
(push "/data/data/com.termux/files/usr/bin" exec-path)

(setenv "PKG_CONFIG_PATH"
	"/data/data/com.termux/files/usr/lib/pkgconfig/")

(setq
 ;; No garbage collection during startup
 gc-cons-threshold most-positive-fixnum
 gc-cons-percentage 0.8

 ;;Prefer loading newest file
 load-prefer-newer t

 ;; Disable package.el
 package-enable-at-startup nil
 package-quickstart nil)

;; Ignore `tramp' and `compressed'/`archive' files during start
(defvar user/file-name-handler-alist-backup file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist
                  user/file-name-handler-alist-backup)))

;; Environment variables
(setenv "LSP_USE_PLISTS" "true")

;; Configure autosaves and backups.
(let ((backup-dir (expand-file-name "~/backups/"))
      (autosave-dir (expand-file-name "~/auto-saves/")))
  (unless (file-exists-p backup-dir)
    (make-directory backup-dir t))
  (unless (file-exists-p autosave-dir)
    (make-directory autosave-dir t))

  (setq backup-directory-alist `(("." . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,autosave-dir t))))

(setq
 auth-sources '("~/.authinfo.gpg")

 version-control t
 kept-new-versions 4
 kept-old-versions 4
 delete-old-versions t)

;; Early UI optimizations
(setq-default
 cursor-type 'bar
 fill-column 80)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'tooltip-mode)
  (tooltip-mode -1))

;; Other
(setq
 ;; Reduce startup "noise"
 inhibit-startup-message t
 inhibit-startup-echo-area-message user-login-name
 inhibit-startup-screen t
 initial-scratch-message nil
 native-comp-async-report-warnings-errors nil
 ;; Disable 2nd case-insensitive search for a major mode
 auto-mode-case-fold nil
 ffap-machine-p-known 'reject
 frame-inhibit-implied-resize t
 idle-update-delay 1.0
 inhibit-compacting-font-caches t
 read-process-output-max (* 1024 1024)
 redisplay-skip-fontification-on-input t
 command-line-x-option-alist nil
 select-active-regions 'only
 create-lockfiles nil
 vc-follow-symlinks t
 use-short-answers t
 dired-kill-when-opening-new-dired-buffer t)

(provide 'early-init)

;;; early-init.el ends here
