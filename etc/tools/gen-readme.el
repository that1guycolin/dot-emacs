;;; gen-readme.el --- Create the README for this repo -*- lexical-binding: t; -*-

;; Author: Colin Loeffler (that1guycolin)
;; Version: 0.1.0
;; Package-Requires: ((emacs "30.1"))
;; Homepage: https://github.com/that1guycolin/dot-emacs
;; Keywords: comm convenience docs internal local

;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; Functions to assist with creating the README for the git repo of this Emacs'
;; configuration.  Load this document into Emacs:
;; #+begin_src emacs-lisp
;;   (require 'gen-readme "~/.config/emacs/etc/tools")
;; #+end_src
;; This method assumes the tools folder is in load-path.  Otherwise:
;; #+begin_src emacs-lisp
;;   (load "~/.config/emacs/etc/tools/gen-readme.el")
;; #+end_src

;;; Code:
(require 'cl-lib)
(require 'elpaca)
(require 'org)

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
  (let* ((filename-ext (file-name-nondirectory file))
         (file-url (concat "file: site-lisp/" filename-ext))
         (filename (string-replace ".el" nil filename-ext))
         (pretty-name (string-replace "-" " " filename)))
    (insert (format "*** [[%s][%s]]" file-url pretty-name))
    (insert "\n")
    (insert "\n"))
  
  (dolist (pkg (gen-readme-packages-in-file file))
    (gen-readme-get-package-entry pkg))
  (insert "\n"))

(defun gen-readme-title-block ()
  "Create the README's title block."
  (save-excursion
    (goto-char (point-min))
    (let ((id "emacs:zms5tnb090l0"))
      (insert ":PROPERTIES:\n"
              ":ID:       " id "\n"
              ":END:\n"
              "#+TITLE: dot-Emacs README"
              "\n#+AUTHOR: Colin Loeffler (that1guycolin)"
              "\n#+CREATED_DATE: [2026-07-14 Tue 04:29:56]"
              "\n#+LAST_EDIT: " (format-time-string "[%Y-%m-%d %a %H:%M:%S]")
              "\n#+ID: " id
              "\n#+FILETAGS: \n"
              "\n* Packages Included \n\n"))))

(defun gen-readme-packages-by-file ()
  "Create the block of the README that lists all installed pacakges.
Packages are sorted by the file contianing their `use-package' object."
  (goto-char (point-max))
  (dolist
      (file (directory-files "~/.config/emacs/site-lisp" t
                             ".*\\.el"))
    (gen-readme-print-file-info file))
  (insert "\n"))

(defun gen-readme-end ()
  "Generate the TODO and LICENSE sections of the readme."
  (goto-char (point-max))
  (insert "\n* Todo")
  (insert "\n")
  (insert "\n- See [[file:TODO][TODO]].")
  (insert "\n")
  (insert "\n* License")
  (insert "\n")
  (insert "\n[[file:LICENSE][GPL-3.0]]")
  (insert "\n"))

;;;###autoload
(defun gen-readme-full ()
  "Generate the README in a new buffer."
  (interactive)
  (switch-to-buffer "new-README.org")
  (gen-readme-title-block)
  (gen-readme-packages-by-file)
  (gen-readme-end))


(provide 'gen-readme)
;;; gen-readme.el ends here.
