;;; a-elpaca.el --- Elpaca package manager -*- lexical-binding: t -*-

;;; Commentary:

;; Load Elpaca: An Elisp package manager. Also loads `elpaca-use-package' and
;; `no-littering'.

;;; Code:

(require '00-macros)

(declare-function elpaca                              "elpaca")
(declare-function elpaca--read-queued                 "elpaca")
(declare-function elpaca-build-autoloads              "elpaca")
(declare-function elpaca-build-compile                "elpaca")
(declare-function elpaca-build-docs                   "elpaca")
(declare-function elpaca-build-docs-process-sentinel  "elpaca")
(declare-function elpaca-delete                       "elpaca")
(declare-function elpaca-fetch                        "elpaca")
(declare-function elpaca-fetch-all                    "elpaca")
(declare-function elpaca-generate-autoloads           "elpaca")
(declare-function elpaca-manager                      "elpaca")
(declare-function elpaca-merge                        "elpaca")
(declare-function elpaca-merge-all                    "elpaca")
(declare-function elpaca-process-queues               "elpaca")
(declare-function elpaca-rebuild                      "elpaca")
(declare-function elpaca-update                       "elpaca")
(declare-function elpaca-update-all                   "elpaca")
(declare-function elpaca-wait                         "elpaca")
(declare-function elpaca-use-package      "elpaca-use-package")
(declare-function elpaca-use-package-mode "elpaca-use-package")

(defvar elpaca-directory (expand-file-name "var/elpaca" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources" elpaca-directory))

(defvar elpaca-installer-version 0.12)
(defvar elpaca-menu-org-make-manual nil)
(defvar elpaca-queue-limit)
(defvar elpaca-use-package)
(defvar use-package-always-ensure)


;;; Elpaca:

(that1guycolin/emacs-set-for-type elpaca-queue-limit 8 4 4)

;; Modified from https://github/progfolio/elpaca/doc/installer.el
(defvar elpaca-order
  '(elpaca :repo "https://github.com/progfolio/elpaca.git"
           :ref nil :depth 1 :inherit ignore
           :files (:defaults "elpaca-test.el" (:exclude "extensions"))
           :build (:not elpaca-activate)))
(let* ((repo (expand-file-name "elpaca" elpaca-sources-directory))
       (build (expand-file-name "elpaca" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
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
  (run-hook-with-args 'elpaca-menu-functions 'update))

(defun that1guycolin/elpaca-build-docs (pkg)
  "Build the documentation for PKG."
  (interactive (list (elpaca--read-queued "Build documentation for: ") t))
  (elpaca-build-docs pkg))

(defvar-keymap that1guycolin/elpaca-options-map
  :doc "Functions for Elpaca package manager."
  "m"    #'elpaca-manager       "n"    #'that1guycolin/elpaca-update-menus
  "f"    #'elpaca-fetch         "F"    #'elpaca-fetch-all
  "e"    #'elpaca-merge         "E"    #'elpaca-merge-all
  "u"    #'elpaca-update        "U"    #'elpaca-update-all
  "r"    #'elpaca-rebuild       "d"    #'elpaca-delete
  "b a"  #'elpaca-build-autoloads
  "b d"  #'(lambda () (call-interactively #'that1guycolin/elpaca-build-docs))
  "b c"  #'elpaca-build-compile)
(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
    that1guycolin/elpaca-options-map
    "m"   "Elpaca Manager"     "n"   "Update Menus"
    "f"   "Fetch"              "F"   "Fetch All"
    "e"   "Merge"              "E"   "Merge All"
    "u"   "Update"             "U"   "Update All"
    "r"   "Rebuild"            "d"   "Delete"
    "b a" "Build Autoloads"    "b d" "Build Docs"     "b c" "Build Compile"))
(keymap-global-set "C-c e" that1guycolin/elpaca-options-map)

;;; elpaca-use-package

(elpaca (elpaca-use-package :wait t)
  (elpaca-use-package-mode 1)
  (setq use-package-always-ensure t))

(use-package no-littering
  :ensure (:wait t)
  :after (elpaca-use-package)
  :demand t)


(provide 'a-elpaca)
;;; a-elpaca.el ends here
