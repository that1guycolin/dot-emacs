;;; 00-user-macros.el --- User-Defined Macros -*- lexical-binding: t -*-

;;; Commentary:
;; Define custom macros that can be loaded first so they can be used in my
;; configuration/ during the init process.

;;; Code:
(require 'cl-lib)
(cl-defmacro user/keymap-with-comments (name doc pairs bind &optional map)
  "Define a keymap NAME with bindings and which-key descriptions from PAIRS.
Element DOC is the docstring for the new keymap.  Each element of PAIRS
should be a list of the form: (KEY DEF DESCRIPTION).  BIND is the
key-chord to which the new keymap will be bound.  MAP is a symbol for
the keymap in which the new keymap will be bound.  If MAP is
not-provided or nil, the keymap will be bound in the global keymap."
  (declare (indent defun))
  (let* ((real-pairs
          (if (and (consp pairs)
                   (eq (car pairs) 'quote))
              (cadr pairs)
            pairs))
         (keymap-args
          (cl-loop for (key def _desc) in real-pairs
                   append (list key def)))
         (which-key-args
          (cl-loop for (key _def desc) in real-pairs
                   append (list key desc))))
    `(progn
       (defvar-keymap ,name
         :doc ,doc
         ,@keymap-args)
       (with-eval-after-load 'which-key
         (which-key-add-keymap-based-replacements ,name
           ,@which-key-args))
       ,(if map
            `(keymap-set ,map ,bind ,name)
          `(keymap-global-set ,bind ,name)))))


(provide '00-user-macros)
;;; 00-user-macros.el ends here.
