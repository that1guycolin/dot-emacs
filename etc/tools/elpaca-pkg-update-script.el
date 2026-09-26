;;; elpaca-pkg-update-script.el --- Updater script -*- lexical-binding: t -*-

;;; Commentary:
;; This file contains a script for automatically updating Emacs packages
;; installed via the Elpaca package manager (see
;; https://github.com/progfolio/elpaca.git).  Run the script with
;; src_shell{emacs -x update-packages.el}.

;;; Code:
;; Requirements
(require 'cl-lib)

(defvar potential-init-files '("~/.config/emacs/init.el"
                               "~/.emacs.d/init.el"
                               "~/.emacs")
  "List of possible locations for a user's init file.")

(when (car command-line-args-left)
  (setf potential-init-files
        (append (xar command-line-args-left) potential-init-files)))

;; Load config
(when-let* ((initf (seq-find #'file-exists-p potential-init-files)))
  (unless initf
    (user-error "Unable to locate init file"))
  (let* ((init-dir (file-name-parent-directory initf))
         (ear-init (concat init-dir "early-init.el")))
    (when (file-exists-p ear-init)
      (load-file ear-init)))
  (add-to-list 'load-path user-lisp-directory)
  (load-file initf))

;; Update Menus
(unless (boundp 'elpaca-menu-functions)
  (user-error "Elpaca is not your package manager"))
(run-hook-with-args 'elpaca-menu-functions 'update)

;; Fetch & merge packages
(declare-function pdf-tools-install    "pdf-tools")
(declare-function ghostel-module-compile "ghostel")
(declare-function elpaca--queued          "elpaca")
(declare-function elpaca-fetch            "elpaca")
(declare-function elpaca-merge            "elpaca")
(declare-function elpaca-rebuild          "elpaca")
(defvar elpaca-menu-org-make-manual)

(defun elpaca-pkg-update--update-pkg (pkg)
  "Fetch, merge, and rebuild elpaca package PKG.
If PKG is \\='ghostel', run `ghostel-module-compile'.  If package is
\\='pdf-tools', run `pdf-tools-install'."
  (elpaca-fetch pkg)
  (elpaca-merge pkg)
  (elpaca-rebuild pkg)
  ;; Handle packages with additional build steps
  (cond
   ((eq pkg 'pdf-tools)
    (add-to-list 'load-path
                 (expand-file-name "pdf-tools" elpaca-builds-directory))
    (require 'pdf-tools)
    (pdf-tools-install)
    (message "Updated pdf-tools & installed epdfinfo program"))
   ((eq pkg 'ghostel)
    (progn
      (add-to-list 'load-path
                   (expand-file-name "ghostel" elpaca-builds-directory))
      (require 'ghostel)
      (with-eval-after-load 'ghostel
        (ghostel-module-compile)
        (message "Updated ghostel & compiled ghostel-module"))))
   (t
    (message "Updated %s" pkg))))

(setq elpaca-menu-org-make-manual nil)
(let ((packages (sort (cl-delete-duplicates
                       (mapcar #'car (elpaca--queued))) #'string<)))
  (dolist (package packages)
    (elpaca-pkg-update--update-pkg package)))


(provide 'elpaca-pkg-update-script)
;;; elpaca-pkg-update-script.el ends here
