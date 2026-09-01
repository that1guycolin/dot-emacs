;;; 00-macros.el --- Custom Macros -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains all custom cl and elisp macro definitions used in this
;; init.

;;; Code:
(cl-defmacro that1guycolin/desktop-mobile (&key desk termux gui)
  "Set different options depending on where Emacs is active.
DESK    - Settings for Emacs on PC/laptop.
TERMUX  - Settings for Emacs in the Android `termux' application.
GUI     - Settings for the Emacs Android GUI application (only required when
          the GUI and termux need different settings)."
  (declare (indent defun))
  `(cond
    ((and (eq system-type 'android) (null (getenv "TERMUX_VERSION")))
     ,(or gui termux))
    ((eq system-type 'android)
     ,(or termux desk))
    (t
     ,desk)))


(provide '00-macros)
;;; 00-macros.el ends here
