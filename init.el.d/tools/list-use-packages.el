;;; list-use-packages.el --- Get package list -*- lexical-binding: t; -*-

;;; Commentary:
;; Usage: "emacs --script list-use-packages.el FILE.el"

;;; Code:
(require 'cl-lib)

(let ((file (car command-line-args-left))
      (packages '()))
  (unless file
    (error "Please provide an .el file"))

  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (condition-case nil
        (while t
          (let ((form (read (current-buffer))))
            (when (and (listp form)
                       (eq (car form) 'use-package))
              (push (symbol-name (cadr form)) packages))))
      (end-of-file)))

  (dolist (pkg (nreverse packages))
    (princ pkg)
    (princ "\n")))

(provide 'list-use-packages)
;;; list-use-packages.el ends here.
