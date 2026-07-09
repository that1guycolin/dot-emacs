;;; 15-user-functions.el --- Custom variables & functions -*- lexical-binding: t; -*-

;;; Commentary:
;; Variables, functions, and transient dispatches defined by the user.

;;; Code:
;;;; =======  HOOKS  =======
(defun user/untabify-buffer ()
  "Run `untabify' over current buffer."
  (interactive)
  (untabify (point-min) (point-max)))

(defvar user/no-tab-modes
  '(bash-ts-mode
    emacs-lisp-mode lisp-mode python-mode python-ts-mode sh-mode)
  "Major modes indented by spaces and not by tabs.")

(defun user/untabify-when-no-tab-mode ()
  "Run `user/untabify-buffer' if `major-mode' member `user/no-tab-modes'."
  (when (member major-mode user/no-tab-modes)
    (user/untabify-buffer)))

(add-hook 'after-save-hook #'user/untabify-when-no-tab-mode)


;;;; =======  SIDE-WINDOW  =======
(defun user/toggle-side-window ()
  "Switch focus between a side window and the main window area.
If in a side window, return to the last used window.
If not in a side window, jump to the first found side window."
  (interactive)
  (let* ((side-window
          (cl-find-if
           (lambda (w)
             (window-parameter w 'window-side))
           (window-list))))
    (cond
     ((not side-window)
      (message "No side window found in this frame."))
     ((eq (selected-window) side-window)
      (select-window (get-mru-window nil nil t)))
     (t
      (select-window side-window)))))
(bind-keys ("M-0" . user/toggle-side-window))


;;;; =======  ELPACA  =======
(declare-function elpaca-update-menus "elpaca")
(defun user/elpaca-update-menus ()
  "Non-interactively run `elpaca-update-menus'."
  (interactive)
  (funcall #'elpaca-update-menus))

(declare-function elpaca--queued "elpaca")
(defun user/elpaca-rebuild-all ()
  "Rebuild all external packages installed via `elpaca'."
  (interactive)
  (let* ((pkg-list (mapcar #'car (elpaca--queued)))
         (pkgs (nreverse pkg-list)))
    (dolist (pkg pkgs)
      (elpaca-rebuild pkg)
      (message "Rebuilt %s" pkg))
    (message "All packages rebuilt!")))

(defvar user/init-directory)
(defvar user/custom-packages)
(defun user/get-external-packages ()
  "Return a list of all external packages installed via `elpaca'."
  (interactive)
  (let* ((packages '(elpaca elpaca-use-package))
         (init-files
          (directory-files user/init-directory t
                           directory-files-no-dot-files-regexp))
         (files (nreverse init-files)))
    (with-temp-buffer
      (dolist (file files)
        (insert-file-contents file))
      (goto-char (point-min))
      (condition-case nil
          (while t
            (let ((form (read (current-buffer))))
              (when (and (listp form)
                         (eq (car form) 'use-package))
                (let ((args (cddr form)))
                  (unless (or (and (plist-member args :ensure)
                                   (null (plist-get args :ensure)))
                              (member (cadr form) user/custom-packages))
                    (push (cadr form) packages))))))
        (end-of-file)))
    (nreverse packages)))

(defun user/elpaca-complete-update ()
  "Fetch, merge, and rebuild every package installed via `elpaca'."
  (interactive)
  (user/elpaca-update-menus)
  (dolist (pkg (user/get-external-packages))
    (elpaca-fetch pkg)
    (elpaca-merge pkg)
    (when (member pkg (mapcar #'car (elpaca--queued)))
      (elpaca-rebuild pkg))))

(declare-function elpaca-manager                        "elpaca")
(declare-function elpaca-fetch                          "elpaca")
(declare-function elpaca-fetch-all                      "elpaca")
(declare-function elpaca-merge                          "elpaca")
(declare-function elpaca-merge-all                      "elpaca")
(declare-function elpaca-rebuild                        "elpaca")
(declare-function elpaca-update                         "elpaca")
(declare-function elpaca-update-all                     "elpaca")
(declare-function elpaca-build-autoloads                "elpaca")
(declare-function elpaca-build-docs                     "elpaca")
(declare-function elpaca-build-docs-process-sentinel    "elpaca")
(declare-function elpaca-build-compile                  "elpaca")
(defvar-keymap user/elpaca-options-map
  :doc "Functions for Elpaca package manager."
  "m"    #'elpaca-manager
  "a"    #'user/elpaca-complete-update
  "n"    #'user/elpaca-update-menus
  "f"    #'elpaca-fetch
  "F"    #'elpaca-fetch-all
  "e"    #'elpaca-merge
  "E"    #'elpaca-merge-all
  "r"    #'elpaca-rebuild
  "R"    #'user/elpaca-rebuild-all
  "u"    #'elpaca-update
  "U"    #'elpaca-update-all
  "b a"  #'elpaca-build-autoloads
  "b d"  #'elpaca-build-docs
  "b D"  #'elpaca-build-docs-process-sentinel
  "b c"  #'elpaca-build-compile)

(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
    user/elpaca-options-map
    "m"   "Elpaca Manager"
    "a"   "Complete Update"
    "n"   "Update Menus"
    "f"   "Fetch"
    "F"   "Fetch All"
    "e"   "Merge"
    "E"   "Merge All"
    "r"   "Rebuild"
    "R"   "Rebuild All"
    "u"   "Update"
    "U"   "Update All"
    "b a" "Build Autoloads"
    "b d" "Build Docs"
    "b D" "Build Docs (Process Sentinel)"
    "b c" "Build Compile"))
(keymap-global-set "C-c e" user/elpaca-options-map)

;;;; =======  EXERCISM  =======
(declare-function ert-delete-all-tests "ert.el.gz")
(defun user/eval-and-run-all-tests-in-buffer ()
  "Run tests for the `exercism' learning tool.
Delete all loaded tests from the runtime, evaluate the current buffer,
and run all loaded tests with ert."
  (interactive)
  (ert-delete-all-tests)
  (eval-buffer)
  (ert 't))


(provide '15-user-functions)
;;; 15-user-functions.el ends here
