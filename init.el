;;; init.el --- that1guycolin's Emacs Config -*- lexical-binding: t; -*-
;; Copyright (C) 2026  Loeffler, Colin (that1guycolin)

;; Author: Loeffler, Colin <that1guycolin@gmail.com>
;; URL: https://github.com/that1guycolin/dot-Emacs

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; All packages included:
;; activities, adaptive-wrap, adjust-parens, apheleia, auto-rename-tag, avy,
;; bash-ts-mode, cape, casual, casual-avy, checkdoc, cmake-ts-mode,
;; comment-dwim-2, consult, consult-eglot, consult-eglot-embark,
;; consult-flycheck, consult-project-extra, corfu, csv-mode, dashboard,
;; deadgrep, diff-hl, dirvish, disproject, djvu, docker, docker-compose-mode,
;; dockerfile-ts-mode, docstr, dumb-jump, dwim-shell-command, eask-mode, eat,
;; editorconfig, ef-themes, eglot, eglot-tempel, el2org, eldoc-cmake,
;; elisp-def, elisp-dev-mcp, ellama, elpaca, emacs-everywhere, emacs-lisp-mode,
;; embark, embark-consult, emms, emms-info-mediainfo, envrc, eros,
;; eros-inspector, exec-path-from-shell, fish-mode, flycheck,
;; flycheck-color-mode-line, flycheck-eask, flycheck-eglot, flycheck-guile,
;; flycheck-package, flyover, flyspell, flyspell-correct,
;; flyspell-correct-avy-menu, forge, free-keys, gcmh, geiser, geiser-guile,
;; ghostel, git-commit-ts-mode, git-link, git-modes, glsl-mode, gptel,
;; gptel-forge-prs, grip-mode, guix, helpful, hideshow, htmlize, ielm,
;; inhibit-mouse, ini-mode, inspector, json-ts-mode, just-ts-mode, kdl-mode,
;; kirigami, lisp-mode, lisp-semantic-hl, live-py-mode, llm, llm-ollama,
;; lsp-snippet, lua-ts-mode, macrostep, macrostep-geiser, magit, magit-todos,
;; marginalia, markdown-mode, markdown-ts-mode, mcp-server-lib, minions,
;; mistty, modus-themes, morlock, native-complete, nerd-icons,
;; nerd-icons-corfu, no-littering, notmuch, notmuch-addr, notmuch-indicator,
;; notmuch-transient, nov, nxml-mode, ob-rust, orderless, org, org-appear,
;; org-category-capture, org-chef, org-edna, org-make-toc, org-mcp, org-mem,
;; org-modern, org-modern-indent, org-node, org-node-backlink, org-noter,
;; org-noter-pdftools, org-pdftools, org-pomodoro, org-project-capture,
;; org-recur, org-super-agenda, org-tidy, outline, outline-indent, pdf-tools,
;; pkgbuild-mode, popper, project, project-treemacs, python-pytest,
;; python-ts-mode, python-x, rainbow-delimiters, ready-player, recentf, rg,
;; rustic, rust-ts-mode, savehist, scheme-mode, shfmt, sh-mode, show-font, sly,
;; smartparens, suggest, systemd, tab-line-nerd-icons, telega, tempel,
;; tempel-collection, toml-ts-mode, transient, tree-inspector, treemacs,
;; treemacs-magit, treemacs-nerd-icons, treesit, treesit-fold, vertico,
;; visual-fill-column, visual-regexp, visual-regexp-steroids, vterm,
;; with-editor, yaml-pro, yaml-ts-mode

;;; Packages included (file-local):
;; elpaca, elpaca-use-package, no-littering

;;; Commentary:
;; that1guycolin's personal Emacs configuration.  Reduces startup time by
;; optimizing load-order and using `Elpaca' as package manager.  Organization
;; clutter-free environment thanks to `no-littering'.

;;; Code:
;;; Elpaca:
;; Define variables (paths for `no-littering')
(defvar elpaca-directory (expand-file-name "var/elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))

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

;; Automatically load customization variables if they exist
(when (file-exists-p custom-file)
  (add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror))))

;;; elpaca-use-package/no-littering:
(declare-function elpaca-use-package      "elpaca-use-package")
(declare-function elpaca-use-package-mode "elpaca-use-package")

(defvar elpaca-use-package)
(defvar use-package-always-ensure)

(elpaca (elpaca-use-package :wait t)
  (elpaca-use-package-mode 1))
(elpaca-use-package-mode 1)
(setq use-package-always-ensure t)

(use-package no-littering
  :ensure (:wait t)
  :demand t
  :config
  (defvar that1guycolin/tools-directory
    (no-littering-expand-etc-file-name "tools")
    "Directory containing scripts, etc for editing this configuration."))


;;; Global settings:
(use-package emacs
  :ensure nil
  :demand t
  :preface
  (defmacro that1guycolin/desktop-mobile (desk termux &optional gui)
    "Set different options depending on where Emacs is active.
DESK    - Settings for Emacs on PC/laptop.
TERMUX  - Settings for Emacs in the Android `termux' application.
GUI     - Settings for the Emacs Android GUI application (only required when
          the GUI and termux need different settings)."
    (declare (indent defun))
    `(cond
      ((and (eq system-type 'android) (null (getenv "TERMUX_VERSION")))
       ,(or gui termux))
      ((eq system-type 'android) ,termux)
      (t ,desk)))

;;;; Load paths:
  (defvar that1guycolin/projects-directory nil
    "Directory containing active projects.")

  (defvar that1guycolin/scripts-directory nil
    "Directory containing custom \='one off' scripts.")

  (defvar that1guycolin/android-home
    "/data/data/com.termux/files/home"
    "Termux home directory on Android.")

  (that1guycolin/desktop-mobile
    (setq
     that1guycolin/projects-directory (expand-file-name "~/projects/")
     that1guycolin/scripts-directory (expand-file-name "~/scripts/"))
    (setq
     that1guycolin/projects-directory
     (expand-file-name "projects" that1guycolin/android-home)
     that1guycolin/scripts-directory
     (expand-file-name "scripts" that1guycolin/android-home)))

;;;; tabs-to-spaces
  (defun that1guycolin/untabify-buffer ()
    "Run `untabify' over current buffer."
    (interactive)
    (untabify (point-min) (point-max)))

  (defvar that1guycolin/no-tab-modes
    '(bash-ts-mode
      emacs-lisp-mode lisp-mode lisp-data-mode python-mode python-ts-mode
      sh-mode)
    "Major modes indented by spaces and not by tabs.")

  (defun that1guycolin/untabify-when-no-tab-mode ()
    "Run `untabify-buffer' if `major-mode' in `no-tab-modes'."
    (when (member major-mode that1guycolin/no-tab-modes)
      (that1guycolin/untabify-buffer)))

;;;; side window
  (defun that1guycolin/toggle-side-window ()
    "Switch focus between a side window and the main window area.
If in a side window, return to the last used window.
If not in a side window, jump to the first found side window."
    (interactive)
    (let* ((side-window (cl-find-if
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

;;;; misc.
  (defun that1guycolin/check-parens-with-message ()
    "Run `check-parens'.  Print a message when all parentheses match."
    (interactive)
    (when (not (check-parens))
      (message "All parentheses match!")))

  (defun that1guycolin/ibuffer-hook-functions ()
    "Group of functions to include in `ibuffer-mode-hook'."
    (hl-line-mode 1)
    (ibuffer-auto-mode 1))

  (defvar that1guycolin/emacs-load-libs '(bs cl-lib hl-line mouse seq subr-x)
    "List of optional Emacs libraries to load at Emacs start.")

;;;; use-package
  :bind (("C-TAB"   . completion-at-point)
         ("C-c C-x" . toggle-frame-maximized)
         ("C-c ("   . that1guycolin/check-parens-with-message)
         ("C-c #"   . display-line-numbers-mode)
         ("C-c C-#" . global-display-line-numbers-mode)
         ("C-c C-$" . restart-emacs)
         ("M-0"     . that1guycolin/toggle-side-window))
  :bind-keymap ("C-c e"   . that1guycolin/elpaca-options-map)
  :hook (after-save . that1guycolin/untabify-when-no-tab-mode)
  :functions (ibuffer-auto-mode)
  :init
  (setq
   font-use-system-font t)
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (dolist (lib that1guycolin/emacs-load-libs)
    (require lib))
  :custom
  (auto-save-visited-interval 60)
  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (read-extended-command-predicate #'command-completion-default-include-p)
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (trusted-content
   (list (expand-file-name "early-init.el" user-emacs-directory)
         (expand-file-name "init.el" user-emacs-directory)))
  :config
  (abbrev-mode 1)
  (auto-save-visited-mode 1)
  (context-menu-mode 1)
  (global-display-fill-column-indicator-mode 1)
  (which-key-mode 1)
  (dolist (elfile (directory-files user-lisp-directory t "\\.el\\'"))
    (add-to-list 'trusted-content elfile))
  (add-hook 'ibuffer-mode-hook #'that1guycolin/ibuffer-hook-functions))


;;; Modular Init:
(with-eval-after-load 'no-littering
  ;; Startup & Core Packages
  (require '01-environment)

  ;; Projects & Workspaces
  (require '02-project-vc)

  ;; Core UI Configuration
  (require '03-visual)

  ;; Language Specific Settings
  (require '04-languages)

  ;; Code Smarter, Not Harder
  (require '05-coding)

  ;; Org Config & Support Packages
  (require '06-org-config)

  ;; Integrate or Emulate External Tools
  (require '07-support))


(provide 'init)
;;; init.el ends here.

                                        ; LocalWords:  nomessage
