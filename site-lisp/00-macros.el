;;; 00-macros.el --- Custom Macros -*- lexical-binding: t -*-

;;; Commentary:

;; This file contains all custom cl and elisp macro definitions used in this
;; init.

;;; Code:

(defmacro that1guycolin/emacs-set-for-type (var desk tmux gui)
  "Set the value of VAR based on the current system.
Use key DESK for \"desktop\" sessions, TMUX, for sessions running in
\"termux\" on Android, and GUI for sessions running in the Android
\"GUI\" app."
  (declare (indent defun))
  `(cond
    ((and (eq system-type 'android) (null (getenv "TERMUX_VERSION")))
     (setq ,var ,gui))
    ((eq system-type 'android)
     (setq ,var ,tmux))
    (t
     (setq ,var ,desk))))

(defmacro that1guycolin/desktop-mobile (desk tmux gui)
  "Set different options depending on where Emacs is active.

DESK  - Settings for Emacs on PC/laptop.
TMUX  - Settings for Emacs in the Android \"termux\" application.
GUI   - Settings for the Emacs Android GUI application."
  (declare (indent defun))
  `(cond
    ((and (eq system-type 'android) (null (getenv "TERMUX_VERSION")))
     ,gui)
    ((eq system-type 'android)
     ,tmux)
    (t
     ,desk)))


(provide '00-macros)
;;; 00-macros.el ends here
