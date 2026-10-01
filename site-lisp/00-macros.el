;;; 00-macros.el --- Custom Macros -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains all custom cl and elisp macro definitions used in this
;; init.

;;; Code:
(eval-when-compile (require 'cl-lib))

(defcustom that1guycolin/emacs-type
  (cond
   ((and (eq system-type 'android) (null (getenv "TERMUX_VERSION")))
    (setq that1guycolin/emacs-type 'android-gui))
   ((eq system-type 'android)
    (setq that1guycolin/emacs-type 'termux))
   (t
    (setq that1guycolin/emacs-type 'desktop)))
  "The type of Emacs currently running.
Acceptable values are \\='desktop, \\='termux, or \\='android-gui."
  :type '(symbol)
  :options '(desktop termux android-gui)
  :group 'that1guycolin)

(cl-defmacro that1guycolin/emacs-set-for-type (var &key desk tmux gui)
  "Set the value of VAR based on the value of `that1guycolin/emacs-type'.
Use key DESK for \"desktop\" sessions, TMUX, for sessions running in
\"termux\" on Android, and GUI for sessions running in the Android
\"GUI\" app."
  (declare (indent defun))
  `(cond
    ((and ,gui
          (eq that1guycolin/emacs-type 'android-gui))
     (setq ,var ,gui))
    ((and ,tmux
          (or (eq that1guycolin/emacs-type 'termux)
              (eq that1guycolin/emacs-type 'android-gui)))
     (setq ,var ,tmux))
    ((and ,desk
          (or (eq that1guycolin/emacs-type 'termux)
              (eq that1guycolin/emacs-type 'desktop)))
     (setq ,var ,desk))
    (t
     (error "Unsure how to set %s\nthat1guycolin/emacs-type: %s"
            ',var that1guycolin/emacs-type))))

(cl-defmacro that1guycolin/desktop-mobile (&key desk tmux gui)
  "Set different options depending on where Emacs is active.
DESK  - Settings for Emacs on PC/laptop.
TMUX  - Settings for Emacs in the Android \"termux\" application.
GUI   - Settings for the Emacs Android GUI application (only required when
          the GUI and termux need different settings)."
  (declare (indent defun))
  (unless (boundp 'that1guycolin/emacs-type)
    (error "Variable that1guycolin/emacs-type is not set"))
  `(cond
    ((eq that1guycolin/emacs-type 'android-gui)
     (or ,gui ,tmux))
    ((eq that1guycolin/emacs-type 'termux)
     (or ,tmux ,desk))
    ((eq that1guycolin/emacs-type 'desktop)
     ,desk)
    (t (error "\"that1guycolin/emacs-type\" set to %s"
              ,that1guycolin/emacs-type))))


(provide '00-macros)
;;; 00-macros.el ends here
