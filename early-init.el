;;; early-init.el --- Load first  -*- lexical-binding: t; -*-

;;; Commentary:
;; Set initial values for variables that affect startup performance and UI.
;; Configures backup directories, disables package.el, sets load paths,
;; and applies early UI optimizations before the main config loads.

;;; Code:
;;; Set PATH so Emacs Android GUI can access Termux files
(when (eq system-type 'android)
  (setenv "PATH" (format "%s:%s" "/data/data/com.termux/files/usr/bin"
                         (getenv "PATH")))
  (push "/data/data/com.termux/files/usr/bin" exec-path)
  (setenv "PKG_CONFIG_PATH"
          "/data/data/com.termux/files/usr/lib/pkgconfig/"))

;;; Optionally Profile Startup
(defvar user/profile-startup nil
  "When non-nil, enable CPU profiling during startup.")

(when user/profile-startup
  (declare-function profiler-stop "profiler")
  (declare-function profiler-report "profiler")
  (setq debug-on-error t)
  (profiler-start 'cpu)
  (defvar user/profiler-report-active-p nil
    "Non-nil if if user/profiler-startup-report has been triggered.")
  (defun user/profiler-startup-report ()
    "Stop the cpu profiler and generate its report."
    (unless user/profiler-report-active-p
      (require 'profiler)
      (profiler-stop)
      (with-eval-after-load 'profiler
        (profiler-report))))
  (declare-function user/profiler-startup-report "early-init.el")
  (add-hook 'emacs-startup-hook
            #'(lambda ()
                (run-with-idle-timer 10 nil #'user/profiler-startup-report)))
  (run-with-idle-timer 30 nil #'user/profiler-startup-report))

;;; Modify variables for startup, then reset
(defvar user/file-name-handler-alist-backup file-name-handler-alist)
(setq
 ;; Ignore `tramp' & `compressed'/`archive'
 file-name-handler-alist nil
 ;; Do not display messages
 inhibit-message t)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq
             file-name-handler-alist user/file-name-handler-alist-backup
             inhibit-message nil)))

;;; Other Variable Mods
(defvar package-quickstart)
(defvar auth-sources)
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
 kept-new-versions 2
 kept-old-versions 0
 delete-old-versions t

 ;; Display scratch as initial buffer (changed when dashboard is loaded)
 initial-buffer-choice t
 ;; Don't display anything in the initial scratch buffer
 initial-scratch-message nil
 ;; Don't display the Emacs' startup-screen
 inhibit-startup-screen t
 ;; Disable GNU startup message (to disable, value must be your username)
 inhibit-startup-echo-area-message "colin-l"
 ;; Disable the second non-case-match pass that typically occurs if Emacs cannot
 ;; find a major-mode when opening a file
 auto-mode-case-fold nil
 ;; Let tiling window manager handle frame size.
 ;; NOTE: This has little/no effect in fullscreen-mode or on Android GUI
 frame-inhibit-implied-resize 'force
 ;; Don't compact font caches during GC
 inhibit-compacting-font-caches t
 ;; Max # of bytes to read from subprocess in single chunk
 ;; (= /proc/sys/fs/pipe-max-size)
 read-process-output-max (* 1024 1024)
 ;; Can make scrolling smoother by avoiding unncessary fontifiation
 redisplay-skip-fontification-on-input t
 ;; Alist of x windows options (see help)
 command-line-x-option-alist nil
 ;; Explicitly set active region w/ mouse or shift-select
 select-active-regions 'only
 ;; Don't create lockfiles
 create-lockfiles nil
 ;; Follow symlinks and visit the real file (which avoids vc collisions)
 vc-follow-symlinks t
 ;; Use y/n instead of yes/no
 use-short-answers t
 ;; Save modifications made in Emacs UI to alternate file
 custom-file (expand-file-name "etc/auto-custom.el"
                               user-emacs-directory))

;;; Variables depending on package load
(defvar ffap-machine-p-known)
(defvar which-func-update-delay)
(with-eval-after-load 'ffap
  (setq ffap-machine-p-known 'reject))
(with-eval-after-load 'which-function-mode
  (setq which-func-update-delay 0.5))

;;; Configure autosaves and backups.
(let ((backup-dir (expand-file-name "~/.backups/"))
      (autosave-dir (expand-file-name "~/.auto-saves/")))
  (unless (file-exists-p backup-dir)
    (make-directory backup-dir t))
  (unless (file-exists-p autosave-dir)
    (make-directory autosave-dir t))
  (setq
   backup-directory-alist `(("." . ,backup-dir))
   auto-save-file-name-transforms `((".*" ,autosave-dir t))))

;;; Early UI optimizations
(setq-default
 cursor-type 'bar
 fill-column 80
 search-invisible nil)
(when (fboundp 'tool-bar-mode)
  (if (equal system-type 'android)
      (tool-bar-mode 1)
    (tool-bar-mode -1)))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'tooltip-mode)
  (tooltip-mode -1))

;;; no-littering
(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name "var/eln-cache/" user-emacs-directory))))


(provide 'early-init)
;;; early-init.el ends here
