;;; a-elpaca.el --- Elpaca package manager -*- lexical-binding: t -*-

;;; Commentary:
;; Load the Emacs' package manager Elpaca.

;;; Code:
;;; Elpaca:
;; Define variables (paths for `no-littering')
(defvar elpaca-directory (expand-file-name "var/elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-queue-limit (num-processors))

;; Avoid flycheck warnings
(declare-function   elpaca                                "elpaca")
(declare-function   elpaca--read-queued                   "elpaca")
(declare-function   elpaca-build-autoloads                "elpaca")
(declare-function   elpaca-build-compile                  "elpaca")
(declare-function   elpaca-build-docs                     "elpaca")
(declare-function   elpaca-build-docs-process-sentinel    "elpaca")
(declare-function   elpaca-fetch                          "elpaca")
(declare-function   elpaca-fetch-all                      "elpaca")
(declare-function   elpaca-generate-autoloads             "elpaca")
(declare-function   elpaca-manager                        "elpaca")
(declare-function   elpaca-merge                          "elpaca")
(declare-function   elpaca-merge-all                      "elpaca")
(declare-function   elpaca-process-queues                 "elpaca")
(declare-function   elpaca-rebuild                        "elpaca")
(declare-function   elpaca-update                         "elpaca")
(declare-function   elpaca-update-all                     "elpaca")
(declare-function   elpaca-update-menus                   "elpaca")
(declare-function   elpaca-wait                           "elpaca")

;; Slightly modified version of {gh}/progfolio/elpaca/doc/installer.el
(defvar elpaca-installer-version 0.12)

(defvar elpaca-order
  '(elpaca :repo "https://github.com/progfolio/elpaca.git"
           :ref nil :depth 1 :inherit ignore
           :files (:defaults "elpaca-test.el" (:exclude "extensions"))
           :build (:not elpaca-activate)))
(let* ((repo (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop
                    (apply #'call-process
                           `("git" nil ,buffer t "clone"
                             ,@(when-let* ((depth (plist-get order :depth)))
                                 (list (format "--depth=%d" depth)
                                       "--no-single-branch"))
                             ,(plist-get order :repo)
                             ,repo))))
                  ((zerop
                    (call-process "git" nil buffer t "checkout"
                                  (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop
                    (call-process emacs nil buffer nil
                                  "-Q" "-L" "." "--batch" "--eval"
                                  "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;;; Custom Functions & Keymaps:
(defun that1guycolin/elpaca-update-menus ()
  "Non-interactively run `elpaca-update-menus'."
  (interactive)
  (funcall #'elpaca-update-menus))

(defun that1guycolin/elpaca-build-docs (e)
  "Build the documentation for package E."
  (interactive (list (elpaca--read-queued "Build documentation for: ") t))
  (elpaca-build-docs e))

(defvar-keymap that1guycolin/elpaca-options-map
  :doc "Functions for Elpaca package manager."
  "m"    #'elpaca-manager       "n"    #'that1guycolin/elpaca-update-menus
  "f"    #'elpaca-fetch         "F"    #'elpaca-fetch-all
  "e"    #'elpaca-merge         "E"    #'elpaca-merge-all
  "r"    #'elpaca-rebuild       "u"    #'elpaca-update
  "U"    #'elpaca-update-all    "b a"  #'elpaca-build-autoloads
  "b d"  #'(lambda () (call-interactively #'that1guycolin/elpaca-build-docs))
  "b c"  #'elpaca-build-compile)
(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
    that1guycolin/elpaca-options-map
    "m"   "Elpaca Manager"     "n"   "Update Menus"
    "f"   "Fetch"              "F"   "Fetch All"
    "e"   "Merge"              "E"   "Merge All"
    "r"   "Rebuild"            "u"   "Update"
    "U"   "Update All"         "b a" "Build Autoloads"
    "b d" "Build Docs"         "b c" "Build Compile"))


;;; elpaca-use-package/no-littering:
(declare-function elpaca-use-package      "elpaca-use-package")
(declare-function elpaca-use-package-mode "elpaca-use-package")
(defvar elpaca-use-package)
(defvar use-package-always-ensure)

;; elpaca-use-package
(elpaca (elpaca-use-package :wait t)
  (elpaca-use-package-mode 1))
(elpaca-use-package-mode 1)
(setq use-package-always-ensure t)

;; no-littering
(use-package no-littering
  :ensure (:wait t)
  :demand t)


(provide 'a-elpaca)
;;; a-elpaca.el ends here
