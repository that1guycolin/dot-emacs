;;; roswell-lisp-setup.el --- Configure Emacs & Roswell -*- lexical-binding: t; -*-

;;; Commentary:
;; Script provided by Roswell to configure integration with Emacs Slime.

;;; Code:
(defun roswell-configdir ()
  "Return the configuration directory used by Roswell."
  (substring (shell-command-to-string
	      "ros roswell-internal-use version confdir") 0 -1))

(defun roswell-load (system)
  "Load the Roswell configuration for a specified SBCL-based ROS system.
This function retrieves and prints the location of the sbcl-bin directory
for the given SYSTEM, then attempts to load an init file located at that path.

Parameters:
- SYSTEM: A string representing either '/usr/local/sbcl/bin' or another valid
          roswell installation prefix."
  
  (let ((result (substring (shell-command-to-string
                            (concat
			     "ros -L sbcl-bin -e \"(format t \\\"~A~%\\\"
(uiop:native-namestring (ql:where-is-system \\\""
                             system
                             "\\\")))\"")) 0 -1)))
    (unless (equal "NIL" result)
      (load (concat result "roswell/elisp/init.el")))))

(defun roswell-opt (var)
  "Retrieve the value of an option specified by VAR from Roswell configuration.
This function reads a temporary buffer containing ROS's config file content,
searches for lines starting with VAR, and returns its corresponding
tab-separated values."
  
  (with-temp-buffer
    (insert-file-contents (concat (roswell-configdir) "config"))
    (goto-char (point-min))
    (when (re-search-forward (concat "^" var "\t[^\t]+\t\\(.*\\)$") nil t)
      (match-string 1))))

(defun roswell-directory (type)
  "Construct a full path to the specified Roswell LISP file based on its TYPE.
This function combines several components: ROS configuration directory,
subdirectories for different Lisp versions, and additional metadata retrieved by
calling roswell-opt."

  (concat
   (roswell-configdir)
   "lisp/"
   type
   "/"
   (roswell-opt (concat type ".version"))
   "/"))

(defvar roswell-slime-contribs '(slime-fancy))
(defvar slime-backend)
(defvar slime-path)
(defvar inferior-lisp-program)
(declare-function slime-setup "slime")

(let ((type (or (ignore-errors (roswell-opt "emacs.type")) "slime")))
  (cond ((equal type "slime")
         (let ((slime-directory (roswell-directory type)))
           (add-to-list 'load-path slime-directory)
           (require 'slime-autoloads)
           (setq slime-backend (expand-file-name "swank-loader.lisp"
                                                 slime-directory))
           (setq slime-path slime-directory)
           (slime-setup roswell-slime-contribs)))
        ((equal type "sly")
         (add-to-list 'load-path (roswell-directory type))
         (require 'sly-autoloads))))
(setq inferior-lisp-program "ros run")

(provide 'roswell-lisp-setup)
;;; roswell-lisp-setup.el ends here
