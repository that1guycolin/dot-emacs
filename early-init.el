;;; early-init.el --- Emacs early init  -*- lexical-binding: t; no-byte-compile: t; -*-

;;; Commentary:
;; Set initial values for variables that affect startup performance and UI.
;; Configures backup directories, disables package.el, sets load paths,
;; and applies early UI optimizations before the main config loads.

;;; Code:
;; Debug on error (uncomment to activate)
;; (setq debug-on-error t)

;;Prefer loading newest file
(setq load-prefer-newer t)

;; Disable package.el
(setq package-enable-at-startup nil)

;; Environment variables
(setenv "CC" "gcc")
(setenv "CXX" "g++")
(setenv "LSP_USE_PLISTS" "true")

;; Configure autosaves and backups.
(setq backup-directory-alist '(("." . "~/.backups")))
(setq auto-save-file-name-transforms
      '((".*" "~/.auto-saves" t)))
(setq auth-sources '("~/.authinfo.gpg"))
(make-directory "~/.backups" t)
(make-directory "~/.auto-saves" t)

(setq version-control t)
(setq kept-new-versions 4)
(setq kept-old-versions 4)
(setq delete-old-versions t)

;; Early UI optimizations
(setq-default cursor-type 'bar)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'tooltip-mode)
  (tooltip-mode -1))
(when (fboundp 'flymake-mode)
  (flymake-mode -1))

;; Other
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message user-login-name)
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq auto-mode-case-fold nil)
(setq fast-but-imprecise-scrolling t)
(setq frame-inhibit-implied-resize t)
(setq inhibit-compacting-font-caches t)
(setq redisplay-skip-fontification-on-input t)
(setq command-line-x-option-alist nil)
(setq select-active-regions 'only)
(setq create-lockfiles nil)
(setq vc-follow-symlinks t)
(setq use-short-answers t)
(setq dired-kill-when-opening-new-dired-buffer t)

(provide 'early-init)
;;; early-init.el ends here
