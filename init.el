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

;;; Packages included:
;; activities, adaptive-wrap, adjust-parens, apheleia, auto-rename-tag, avy,
;; bash-ts-mode, cape, casual, casual-avy, checkdoc, cmake-ts-mode,
;; comment-dwim-2, consult, consult-eglot, consult-eglot-embark,
;; consult-flycheck, consult-project-extra, corfu, csv-mode, dashboard,
;; deadgrep, diff-hl, dirvish, disproject, djvu, docker, docker-compose-mode,
;; dockerfile-ts-mode, dumb-jump, dwim-shell-command, eask-mode, eat,
;; editorconfig, ef-themes, eglot, eglot-tempel, el2org, eldoc-cmake,
;; elisp-def, elisp-dev-mcp, ellama, elpaca, elpaca-use-package, emacs,
;; emacs-lisp-mode, embark, embark-consult, emms, emms-info-mediainfo, envrc,
;; eros, eros-inspector, exec-path-from-shell, fish-mode, flycheck,
;; flycheck-color-mode-line, flycheck-eask, flycheck-eglot, flycheck-package,
;; flyover, flyspell, flyspell-correct, flyspell-correct-avy-menu, forge,
;; free-keys, gcmh, ghostel, git-commit-ts-mode, git-link, git-modes,
;; glsl-mode, gptel, gptel-forge-prs, grip-mode, helpful, hideshow, htmlize,
;; ielm, inhibit-mouse, ini-mode, inspector, json-ts-mode, just-ts-mode,
;; kdl-mode, kirigami, lisp-mode, lisp-semantic-hl, live-py-mode, llm,
;; llm-ollama, lsp-snippet, lua-ts-mode, macrostep, magit, marginalia,
;; markdown-ts-mode, mcp-server-lib, minions, mistty, modus-themes, morlock,
;; native-complete, nerd-icons, nerd-icons-corfu, no-littering, nov, nxml-mode,
;; ob-rust, orderless, org, org-edna, org-make-toc, org-mcp, org-mem,
;; org-modern, org-modern-indent, org-node, org-noter, org-noter-pdftools,
;; org-pdftools, org-pomodoro, org-snitch, org-tidy, outline, outline-indent,
;; pdf-tools, popper, project, project-treemacs, python-pytest, python-ts-mode,
;; python-x, rainbow-delimiters, ready-player, recentf, rg, rustic,
;; rustic-ts-mode, savehist, shfmt, sh-mode, show-font, sly, smartparens,
;; suggest, systemd, tab-line-nerd-icons, tempel, tempel-collection,
;; toml-ts-mode, transient, tree-inspector, treemacs, treemacs-magit,
;; treemacs-nerd-icons, treesit, treesit-fold, vertico, visual-fill-column,
;; visual-regexp, visual-regexp-steroids, vterm, with-editor, yaml-pro,
;; yaml-ts-mode

;;; Commentary:
;; that1guycolin's personal Emacs configuration.  Reduces startup time by
;; optimizing load-order and using `Elpaca' as package manager.  Organization
;; clutter-free environment thanks to `no-littering'.

;;; Code:
;;; Elpaca:
;; Define redirected package paths to prevent directory clutter
(defvar elpaca-directory (expand-file-name "var/elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))

;; Avoid flycheck warnings
(declare-function   elpaca-generate-autoloads    "elpaca")
(declare-function   elpaca-process-queues        "elpaca")
(declare-function   elpaca                       "elpaca")
(declare-function   elpaca-wait                  "elpaca")
(declare-function   elpaca-use-package           "elpaca-use-package")
(declare-function   elpaca-use-package-mode      "elpaca-use-package")

(defvar             elpaca-queue-limit)
(defvar             no-littering)
(defvar             elpaca-use-package)
(defvar             use-package-always-ensure)

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

;; Automatically load customization variables if they exist
(when (file-exists-p custom-file)
  (add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror))))

;; Enable use-package integration with Elpaca
(elpaca (elpaca-use-package :wait t))
(elpaca-use-package-mode 1)
(setq use-package-always-ensure t)

;; Neat & tidy `user-emacs-directory'
(use-package no-littering
  :ensure (:wait t)
  :demand t)


;;; Load Paths:
(defvar user/lisp-directory
  (expand-file-name "site-lisp" user-emacs-directory)
  "Directory from which init files are loaded.")

(defvar user/tools-directory
  (expand-file-name "etc/tools" user-emacs-directory)
  "Directory containing scripts, etc for editing this configuration.")

(defvar user/projects-directory nil
  "Directory containing active projects.")

(defvar user/scripts-directory nil
  "Directory containing custom \='one off' scripts.")

(if (eq system-type 'android)
    (progn
      (defvar android-home "/data/data/com.termux/files/home"
        "Termux home directory on Android.")
      (setq
       user/projects-directory (expand-file-name "projects" android-home)
       user/scripts-directory (expand-file-name "scripts" android-home)))
  (setq
   user/projects-directory (expand-file-name "~/projects")
   user/scripts-directory (expand-file-name "~/scripts")))

(add-to-list 'load-path user/lisp-directory)


;;; Modular Init:
(with-eval-after-load 'no-littering
  ;; Startup & Core Packages
  (require '01-env-cap)

  ;; Projects & Workspaces
  (require '02-project-VC)

  ;; Core UI configuration
  (require '03-visual-settings)

  ;; Enable tree-sitter support
  (require '04-tree-sitter-lang-config)

  ;; Support for terminal and Emacs' shells
  (require '06-terminal-modes)

  ;; Packages & settings for select languages
  (require '07-language-configs)

  ;; Linting, formatting, & LSPs
  (require '08-code-assist)

  ;; File explorer functions
  (require '10-file-management)

  ;; Extensions for Org-mode
  (require '11-org-mode-extensions)

  (unless (eq system-type 'android)
    ;; Configure Emacs to work with LLMs
    (require '12-llm-integration)
    ;; Listen to music & watch videos
    (require '13-media-player))

  ;; Misc & Dashboard
  (require '14-misc-packages)

  ;; Custom variables & functions
  (require '15-user-functions))


(provide 'init)
;;; init.el ends here.

                                        ; LocalWords:  nomessage
