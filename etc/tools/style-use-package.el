;;; style-use-package.el --- Enforce init-dir style guide -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Loeffler, Colin

;; Author: Colin Loeffler (that1guycolin)
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: internal maint tools
;; URL: https://github.com/that1guycolin

;;; Commentary:
;; Tools with which to ensure all use-package blocks in a user's init
;; directory follow the included style guide.

;; INSTALLATION:
;; This package will almost universally be called via `use-package'.
;; The below object binds a directory check to "M-*" in
;; `emacs-lisp-mode' and adds the recommended after-save-hook.
;;
;;    (use-package style-use-package
;;      :ensure {t OR straight.el OR elpaca-recipe}
;;      :defer t
;;      :bind (:map emacs-lisp-mode-map
;;                  ("M-*" . style-use-package-check-directory))
;;      :hook (after-save . style-use-package-maybe-check-buffer-objects))

;;; Code:

(require 'use-package)

(defgroup style-use-package nil
  "Maintain consistency and readability across all `use-package' objects."
  :group 'use-package
  :prefix "style-use-package-")

(defconst style-use-package-key-order
  '(:ensure :load-path :after :defer :demand :preface :if :unless :bind :hook
	    :interpreter :magic :mode :commands :functions :defines :init
	    :custom :config)
  "Style guide key order for `use-package' blocks.")

(defconst style-use-package-required-load-keys
  '(:defer :demand)
  "Exactly one of these keys must exist in each `use-package' block.")

(defun style-use-package-get-keys (form)
  "Extract the keyword keys from a `use-package' FORM (a list)."
  (cl-loop for elt in (cddr form)
	   when (keywordp elt)
	   collect elt))

(defun style-use-package-valid-load-key-count-p (keys)
  "Ensure each `use-package' object contains one of the required KEYS."
  (= 1 (length
	(cl-remove-if-not
	 (lambda (k) (memq k style-use-package-required-load-keys)) keys))))

(defun style-use-package-keys-in-order-p (keys)
  "Return nil if KEYS violate the canonical order or t if they do not.
Checks the relative-order of keys against `style-use-package-key-order'."
  (let* ((positions
	  (cl-loop for k in keys
		   for pos = (cl-position k style-use-package-key-order)
		   when pos collect pos))
	 (sorted (sort (copy-sequence positions) #'<)))
    (and (style-use-package-valid-load-key-count-p keys)
	 (equal positions sorted))))

(defun style-use-package-report-violations (violations &optional file rel)
  "Display VIOLATIONS in a dedicated buffer.
If optional FILE is provided, it will be included in the final report.
If REL is non-nil, print filepath relative to `user-emacs-directory'."
    (let ((report-buf (get-buffer-create "*style-use-package-violations*"))
	  (default-file (or file (buffer-file-name))))
      (with-current-buffer report-buf
	(read-only-mode -1)
	(erase-buffer)
	(insert "use-package key order violations\n")
	(insert (make-string 40 ?=) "\n\n")
	(pcase-dolist (`(,violation-file ,pos ,name ,keys) violations)
	  (let* ((filename (or violation-file default-file))
		 (rel-file
		  (if (and rel filename)
		      (file-relative-name filename user-emacs-directory)
		    filename)))
	    (insert (format "File: %s\n" rel-file))
	    (insert (format "  Package: %s (buffer position %d)\n" name pos))
	    (insert (format "  Keys found:    %s\n" keys))
	    (insert (format "  Expected order from: %s\n\n"
  			(cl-remove-if-not
  			 (lambda (k) (memq k keys))
  			 style-use-package-key-order)))))
	(read-only-mode 1)
	(goto-char (point-min)))
      (display-buffer report-buf)))

(defun style-use-package-get-buffer-violations (buf &optional file)
  "Return a list of all style guide violations in BUF.
Provide optional FILE if you want to include specific filename in report."
  (let ((violations '()))
    (save-excursion
      (goto-char (point-min))
      (condition-case nil
	  (while t
	    (let* ((start (point))
		   (form (read buf)))
	      (when (and (listp form)
			 (eq (car form) 'use-package))
		(let* ((name (cadr form))
		       (keys (style-use-package-get-keys form)))
		  (unless (style-use-package-keys-in-order-p keys)
		    (push (list (when file file) start name keys)
			  violations))))))
	(end-of-file nil))) violations))

(defun style-use-package-check-buffer ()
  "Check key order of all `use-package' forms in the current buffer.
The order in which keys appear in each form should match
`style-use-package-key-order'.  Violations are reported in a
*style-use-package-violations* buffer."
  (interactive)
  (let* ((buf (current-buffer))
	 (violations (style-use-package-get-buffer-violations buf)))
    (if (null violations)
	(message "All `use-package' blocks are in order.")
      (style-use-package-report-violations violations))))

(defun style-use-package-check-directory (dir)
  "Check all .el files in DIR for `use-package' key order violations."
  (interactive "DCheck Directory: ")
  (let ((files (directory-files-recursively dir "\\.el$"))
	(all-violations '()))
    (dolist (file files)
      (with-temp-buffer
	(insert-file-contents file)
	(setq all-violations
	      (append (style-use-package-get-buffer-violations
		       (current-buffer) file)
		      all-violations))))
    (if (null all-violations)
	(message
	 "All `use-package' blocks across %d files are in order."
	 (length files))
      (style-use-package-report-violations (nreverse all-violations) nil t))))

(defun style-use-package-maybe-check-buffer-objects (&optional dir)
  "Check the key order of each `use-package' object in `user-emacs-directory'.
Optionally, specify an alternate DIR (including subdirs of
`user-emacs-directory').  This function is designed to be an
`after-save-hook'.  Add with:
  (add-to-list \='after-save-hook
    #\='style-use-package-maybe-check-buffer-objects)
OR
  (add-to-list \='after-save-hook
               (lambda ()
                 (style-use-package-maybe-check-buffer-objects
                   (expand-file-name \"lisp\" user-emacs-directory))))"
  (let ((check-dir (if dir
		       (expand-file-name dir)
		     (expand-file-name user-emacs-directory))))
    (when (and buffer-file-name
	       (string-prefix-p check-dir
				(expand-file-name buffer-file-name))
	       (string-suffix-p ".el" buffer-file-name))
      (style-use-package-check-buffer))))

(provide 'style-use-package)
;;; style-use-package.el ends here
