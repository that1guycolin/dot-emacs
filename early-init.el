;;; early-init.el --- Emacs early init  -*- lexical-binding: t; no-byte-compile: t; -*-

;;; Commentary:
;; Set initial values for variables that affect startup performance and UI.
;; Configures backup directories, disables package.el, sets load paths,
;; and applies early UI optimizations before the main config loads.

;;; Code:
;;Prefer loading newest file
(setq load-prefer-newer t)

;; Disable package.el
(setq package-enable-at-startup nil)

;; Debug on error
(setq debug-on-error t)

;; Environment variables
(setenv "CC" "gcc")
(setenv "CXX" "g++")
(setenv "LSP_USE_PLISTS" "true")

;; Configure autosaves and backups.
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms
      '((".*" "~/.emacs.d/auto-saves/" t)))
(setq auth-sources '("~/.authinfo.gpg"))
(make-directory "~/.emacs.d/backups/" t)
(make-directory "~/.emacs.d/auto-saves/" t)

(setq version-control t)
(setq kept-new-versions 4)
(setq kept-old-versions 4)
(setq delete-old-versions t)

;; Load Paths
(add-to-list 'load-path "~/.emacs.d/init.el.d")
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))

;; Early UI optimizations
(setq-default cursor-type 'bar)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)
(flymake-mode -1)

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
