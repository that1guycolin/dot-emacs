;;; elpaca-pkg-update-script.el --- Updater script -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains a script for automatically updating Emacs packages
;; installed via the Elpaca package manager (see
;; https://github.com/progfolio/elpaca.git). Run the script with
;; src_shell{emacs -x update-packages.el}.

;;; Code:

(require 'cl-lib)

(declare-function elpaca--queued "elpaca")
(declare-function elpaca-fetch   "elpaca")
(declare-function elpaca-merge   "elpaca")
(declare-function elpaca-rebuild "elpaca")
(declare-function ghostel-module-compile "ghostel")
(declare-function pdf-tools-install "pdf-tools")

(defvar elpaca-menu-org-make-manual)
(defvar elpaca-builds-directory)

;;; Variable definitions

(defvar potential-init-files '("~/.config/emacs/init.el"
                               "~/.emacs.d/init.el"
                               "~/.emacs")
  "List of possible locations for a user's init file.")

(defvar elpaca-pkg-update--after-ghostel nil
  "Function to run when ghostel finishes compiling.")


;;; Function Definitions

(defun elpaca-pkg-update-script-message (format-string &rest args)
  "Print a message (FORMAT-STRING) to the terminal.

The message can be formatted as if you were using the standard elisp
function `message'; for example, to insert the value of a variable, include
\"%s\" in the FORMAT-STRING and include the variable in ARGS."
  (princ (apply #'format format-string args))
  (terpri))

(defun elpaca-pkg-update--update-pkg (pkg)
  "Fetch, merge, and rebuild elpaca package PKG."
  (elpaca-fetch pkg)
  (elpaca-merge pkg)
  (elpaca-rebuild pkg)
  (elpaca-pkg-update-script-message "Updated %s" pkg))

(defun elpaca-pkg-update--compilation-finished (buffer _status)
  "Continue after Ghostel's compilation in BUFFER finishes."
  (when (and (buffer-live-p buffer)
             (with-current-buffer buffer
               (derived-mode-p 'ghostel-module-compilation-mode)))
    (remove-hook 'compilation-finish-functions
                 #'elpaca-pkg-update--compilation-finished)
    (when elpaca-pkg-update--after-ghostel
      (run-at-time 0 nil elpaca-pkg-update--after-ghostel))))

(defun elpaca-pkg-update--rebuild-ghostel (&optional continuation)
  "Rebuild the ghostel module, then run CONTINUATION if provided."
  (add-to-list 'load-path
               (expand-file-name "ghostel" elpaca-builds-directory))
  (require 'ghostel)
  (with-eval-after-load 'ghostel
    (when continuation
      (setq elpaca-pkg-update--after-ghostel continuation)
      (add-hook 'compilation-finish-functions
                #'elpaca-pkg-update--compilation-finished))
    (ghostel-module-compile)
    (elpaca-pkg-update-script-message "Started ghostel-module compilation")))

(defun elpaca-pkg-update--rebuild-epdfinfo ()
  "Rebuild the epdfinfo program."
  (add-to-list 'load-path
               (expand-file-name "pdf-tools" elpaca-builds-directory))
  (require 'pdf-tools)
  (pdf-tools-install)
  (elpaca-pkg-update-script-message "Rebuilt epdfinfo program"))

;;; Load config

(when (car command-line-args-left)
  (setf potential-init-files
        (append (car command-line-args-left) potential-init-files)))

(when-let* ((initf (seq-find #'file-exists-p potential-init-files)))
  (if initf
      (elpaca-pkg-update-script-message "Found init file at %s" initf)
    (user-error "Unable to locate init file"))
  (let* ((init-dir (file-name-parent-directory initf))
         (ear-init (concat init-dir "early-init.el")))
    (when (file-exists-p ear-init)
      (load-file ear-init)))
  (add-to-list 'load-path user-lisp-directory)
  (load-file initf))


;;; Update Menus
(unless (boundp 'elpaca-menu-functions)
  (user-error "Elpaca is not your package manager"))
(elpaca-pkg-update-script-message "Updating elpaca menus...")
(run-hook-with-args 'elpaca-menu-functions 'update)
(elpaca-pkg-update-script-message "Menus updated")

;;; Update packages

(setq elpaca-menu-org-make-manual nil)
(let ((packages (sort (cl-delete-duplicates
                       (mapcar #'car (elpaca--queued))) #'string<)))
  (mapc #'elpaca-pkg-update--update-pkg packages)
  (cond
   ((and (memq 'pdf-tools packages)
         (memq 'ghostel packages))
    (elpaca-pkg-update--rebuild-ghostel
     #'elpaca-pkg-update--rebuild-epdfinfo))
   ((memq 'ghostel packages)
    (elpaca-pkg-update--rebuild-ghostel))
   ((memq 'pdf-tools packages)
    (elpaca-pkg-update--rebuild-epdfinfo))))


(provide 'elpaca-pkg-update-script)
;;; elpaca-pkg-update-script.el ends here
