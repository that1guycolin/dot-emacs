;;; generate-readme.el --- Create the README for this repo -*- lexical-binding: t; -*-

;;; Commentary:
;; Functions to assist with creating the README for the git repo of this Emacs'
;; configuration.  Load this document into Emacs:
;; #+begin_src emacs-lisp
;;   (require 'generate-readme)
;; #+end_src
;; This method assumes the tools folder is in load-path.  Otherwise:
;; #+begin_src emacs-lisp
;;   (load "~/.emacs.d/tools/generate-readme.el")
;; #+end_src

;;; Code:
(require 'cl-lib)
(require 'elpaca)

(defun gen-readme-packages-in-file (file)
  "Return a list of packages with a `use-package' object in FILE.
Exclude packages whose block contains \":ensure nil\" so the function
only returns pacakges installed via `elpaca-use-package'."
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

(defun gen-readme-package-url (plist suffix platform)
  "From an elpaca recipe PLIST, return the url of a package.
Provide the PLATFORM on which the repo is hosted and the url's
SUFFIX (the username/repo-name, e.g., progfolio/elpaca) to avoid looking
up the information multiple times."
  (let ((check (plist-get plist :url)))
    (if check
	check
      (cond
       ((eq platform 'github)
	(concat "https://github.com/" suffix))
       ((eq platform 'gitlab)
	(concat "https://gitlab.com/" suffix))
       ((eq platform 'codeberg)
	(concat "https://codeberg.org/" suffix))
       ((eq platform 'gnu)
	(car suffix))
       (t (format "Look this up manually: %s :" platform))))))

(defun gen-readme-get-package-entry (pkg)
  "Return an `org-mode' style link for a PKG's name and its url."
  (let* ((recipe (elpaca-recipe pkg))
	 (repo (plist-get recipe :repo))
	 (host (let ((check-host (plist-get recipe :host)))
		 (if check-host
		     check-host
		   (plist-get recipe :fetcher))))
	 (url (gen-readme-package-url recipe repo host)))
    (insert (format "- [[%s][%s]]" url pkg))
    (insert "\n")))

(defun gen-readme-print-file-info (file)
  "Print the section of the README for FILE.
First, print a heading.  The heading links FILE's pretty name to the
actual file.  Next, print a list containing all the elpaca-installed
packages whose `use-package' block appears in file.  The entry for each
package links to its online repo."
  (let* ((filename-ext
	  (string-replace "/home/colin-l/.emacs.d/init.el.d/"
			  nil file))
	 (filename (string-replace ".el" nil filename-ext))
	 (pretty-name (string-replace "-" " " filename)))
    (insert (format "*** [[file:init.el.d/%s][%s]]" filename-ext pretty-name))
    (insert "\n")
    (insert "\n"))
  
  (dolist (pkg (gen-readme-packages-in-file file))
    (gen-readme-get-package-entry pkg))
  (insert "\n"))

(defun gen-readme-title-block ()
  "Create the README's title block."
  (insert "#+TITLE: Personal Emacs Configuration for that1guycolin")
  (insert "\n#+FILETAGS: :Emacs:emacsd:elisp:")
  (insert "\n")
  (insert "\n* dot-Emacs     :toc_3_gh:")
  (insert "\n")
  
  (insert "\n** Packages Included")
  (insert "\n")
  (insert "\n"))

(defun gen-readme-packages-by-file ()
  "Create the block of the README that lists all installed pacakges.
Packages are sorted by the file contianing their `use-package' object."
  (dolist
      (file
       (directory-files "~/.emacs.d/init.el.d" t
			directory-files-no-dot-files-regexp))

    (gen-readme-print-file-info file))
  (insert "Custom functions to manipulate fonts, elpaca, and more.")
  (insert "\n"))

(defun gen-readme-end ()
  "Generate the TODO and LICENSE sections of the readme."
  (insert "\n** Todo")
  (insert "\n")
  (insert "\n- See [[file:TODO][TODO]].")
  (insert "\n")
  (insert "\n** License")
  (insert "\n")
  (insert "\n[[file:LICENSE][GPL-3.0]]")
  (insert "\n"))

(defun gen-readme-full ()
  "Generate the README in a new buffer."
  (interactive)
  (switch-to-buffer "new-README.org")
  (gen-readme-title-block)
  (gen-readme-packages-by-file)
  (gen-readme-end))

(provide 'generate-readme)
;;; generate-readme.el ends here.
