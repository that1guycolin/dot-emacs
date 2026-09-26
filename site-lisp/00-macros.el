;;; 00-macros.el --- Custom Macros -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains all custom cl and elisp macro definitions used in this
;; init.

;;; Code:
(eval-when-compile (require 'cl-lib))

(defcustom that1guycolin/emacs-type nil
  "The type of Emacs currently running.
Acceptable values are \\='desktop, \\='termux, or \\='android-gui."
  :type '(symbol)
  :options '(desktop termux android-gui)
  :group '(that1guycolin))

(cond
 ((and (eq system-type 'android) (null (getenv "TERMUX_VERSION")))
  (setq that1guycolin/emacs-type 'android-gui))
 ((eq system-type 'android)
  (setq that1guycolin/emacs-type 'termux))
 (t
  (setq that1guycolin/emacs-type 'desktop)))

(cl-defmacro that1guycolin/desktop-mobile (&key desk termux gui)
  "Set different options depending on where Emacs is active.
DESK    - Settings for Emacs on PC/laptop.
TERMUX  - Settings for Emacs in the Android `termux' application.
GUI     - Settings for the Emacs Android GUI application (only required when
          the GUI and termux need different settings)."
  (declare (indent defun))
  `(cond
    ((eq that1guycolin/emacs-type 'android-gui)
     ,(or gui termux))
    ((eq that1guycolin/emacs-type 'termux)
     ,(or termux desk))
    ((eq that1guycolin/emacs-type 'desktop)
     ,desk)
    (t
     (if that1guycolin/emacs-type
         (error "\"that1guycolin/emacs-type\" set to %s"
                that1guycolin/emacs-type)
       (error "\"that1guycolin/emacs-type\ not set\"")))))



(provide '00-macros)
;;; 00-macros.el ends here
