;;; generate-readme.el --- Create the README for this repo -*- lexical-binding: t; -*-

;;; Commentary:
;; Functions to assist with creating the README for the git repo of this Emacs'
;; configuration.  Load this document into Emacs:
;; #+begin_src emacs-lisp
;;   (require 'generate-readme)
;; #+end_src
;; This method assumes the tools folder is on your loadpath.
;; Alternatively:
;; #+begin_src emacs-lisp
;;   (load "~/.emacs.d/tools/generate-readme.el")
;; #+end_src

;;; Code:
(require 'cl-lib)
(require 'elpaca)

(defun get-elpaca-package-list (file)
  "Return a list of packages with a `use-package' object in FILE.
These pacakges were installed via `elpaca-use-package'."
  (let ((package-list '()))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (condition-case nil
	  (while t
	    (let ((form (read (current-buffer))))
	      (when (and (listp form)
			 (eq (car form) 'use-package))
		(let* ((plist (cddr form))
		       (has-ensure (plist-member plist :ensure))
		       (ensure-val (plist-get plist :ensure)))
		  (unless (and has-ensure (null ensure-val))
		    (push (cadr form) package-list))))))
	(end-of-file)))
    (nreverse package-list)))

(defun get-package-entry (pkg)
  "Return an `org-mode' style link for a PKG's name and its url."
  (let* ((recipe (elpaca-recipe pkg))
	 (repo (plist-get recipe :repo))
	 (host (let ((check-host (plist-get recipe :host)))
		 (if check-host
		     check-host
		   (plist-get recipe :fetcher))))
	 (url (let ((check-url (plist-get recipe :url)))
		(if check-url
		    check-url
		  (cond
		   ((eq host 'github)
		    (concat "https://github.com/" repo))
		   ((eq host 'gitlab)
		    (concat "https://gitlab.com/" repo))
		   ((eq host 'codeberg)
		    (concat "https://codeberg.org/" repo))
		   ((eq host 'gnu)
		    (car repo))
		   (t (format "Look this up manually: %s :" host)))))))
    (insert (format "- [[%s][%s]]" url pkg))
    (insert "\n")))

(defun get-file-specific-info (file)
  "Print the section of the README for FILE.
First, print a heading.  The heading links FILE's pretty name to the
actual file.  Next, print a list containing all the elpaca-installed
packages whose `use-package' block appears in file.  The entry for each
package links to its online repo."
  (let*  ((filename-ext
	   (string-replace "/home/colin-l/.emacs.d/init.el.d/"
			   nil file))
	  (filename (string-replace ".el" nil filename-ext))
	  (pretty-name (string-replace "-" " " filename)))
    (insert (format "*** [[file:init.el.d/%s][%s]]" filename-ext pretty-name))
    (insert "\n")
    (insert "\n"))
  
  (dolist (pkg (get-elpaca-package-list file))
    (get-package-entry pkg))

  (insert "\n"))

(defun full-generate-readme ()
  "Generate the README in a new buffer."
  (interactive)
  (switch-to-buffer "new-README.org")
  (insert "#+TITLE: Personal Emacs Configuration for that1guycolin")
  (insert "\n#+FILETAGS: :Emacs:emacsd:elisp:")
  (insert "\n")
  (insert "\n* dot-Emacs     :toc_3_gh:")
  (insert "\n")
  
  (insert "\n** Packages Included")
  (insert "\n")
  (insert "\n")
  
  (dolist (file
	   (directory-files "~/.emacs.d/init.el.d" t
			    directory-files-no-dot-files-regexp))
    (get-file-specific-info file))

  (insert "Custom functions to manipulate fonts, elpaca, and more.")
  (insert "\n")
  (insert "\n** Todo")
  (insert "\n")
  (insert "\n- See [[file:TODO][TODO]].")
  (insert "\n")
  (insert "\n** License")
  (insert "\n")
  (insert "\n[[file:LICENSE][GPL-3.0]]")
  (insert "\n"))


(provide 'generate-readme)
;;; generate-readme.el ends here.
