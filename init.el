;;; init.el --- that1guycolin's dot-Emacs  -*- lexical-binding: t; -*-
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
;; consult-flycheck, consult-project-extra, consult-yasnippet, corfu, csv-mode,
;; dashboard, deadgrep, diff-hl, dirvish, disproject, djvu, docker,
;; dockerfile-ts-mode, dumb-jump, dwim-shell-command, eask-mode, eat,
;; editorconfig, ef-themes, eglot, el2org, eldoc-cmake, elisp-def,
;; elisp-dev-mcp, ellama, elpaca, elpaca-use-package, emacs, emacs-lisp-mode,
;; embark, embark-consult, emms, emms-info-mediainfo, envrc, eros,
;; eros-inspector, exec-path-from-shell, fish-mode, flycheck,
;; flycheck-color-mode-line, flycheck-eask, flycheck-eglot, flycheck-package,
;; flyover, flyspell, flyspell-correct, flyspell-correct-avy-menu, forge,
;; free-keys, gcmh, ghostel, git-commit-ts-mode, git-modes, glsl-mode, gptel,
;; gptel-forge-prs, grip-mode, helpful, hideshow, ielm, ini-mode, inspector,
;; json-ts-mode, just-ts-mode, kdl-mode, kirigami, lisp-mode, lisp-semantic-hl,
;; live-py-mode, llm, lsp-snippet, lua-ts-mode, macrostep, magit,
;; magit-org-todos, marginalia, markdown-ts-mode, mcp-server-lib, minions,
;; mistty, modus-themes, morlock, native-complete, nerd-icons,
;; nerd-icons-corfu, nov, nxml-mode, ob-rust, orderless, org, org-edna,
;; org-make-toc, org-mcp, org-mem, org-modern, org-modern-indent, org-node,
;; org-noter, org-noter-pdftools, org-pdftools, org-pomodoro,
;; org-project-capture, org-tidy, outline, outline-indent, pdf-tools, popper,
;; project, python-pytest, python-ts-mode, python-x, rainbow-delimiters,
;; ready-player, rg, rustic, savehist, shfmt, sh-mode, sly, smartparens,
;; suggest, systemd, tab-line-nerd-icons, tempel, tempel-collection,
;; toml-ts-mode, transient, tree-inspector, treemacs, treemacs-magit,
;; treemacs-nerd-icons, treesit, treesit-fold, vertico, visual-fill-column,
;; visual-regexp, visual-regexp-steroids, vterm, which-key, with-editor,
;; yaml-pro, yaml-ts-mode, yasnippet, yasnippet-capf, yasnippet-snippets

;;; Commentary:
;; that1guycolin's personal Emacs configuration.  Reduces startup time by
;; optimizing load-order and using `Elpaca' as package manager.

;;; Code:
;;;; =======  LOAD PATHS  =======
(defvar user/init-directory
  (expand-file-name "init.el.d" user-emacs-directory)
  "Directory from which init files are loaded.")

(defvar user/tools-directory
  (expand-file-name "tools" user-emacs-directory)
  "Directory containing scripts, etc for editing this configuration.")

(defvar user/projects-directory nil
  "Directory containing active projects.")

(defvar user/scripts-directory nil
  "Directory containing custom \='one off' scripts.")

(if (equal system-type 'android)
    (progn
      (defvar android-home "/data/data/com.termux/files/home"
        "Termux home directory on Android.")
      (setq
       user/projects-directory (expand-file-name "projects" android-home)
       user/scripts-directory (expand-file-name "scripts" android-home)))
  (setq
   user/projects-directory (expand-file-name "~/projects")
   user/scripts-directory (expand-file-name "~/scripts")))

(add-to-list 'load-path user/init-directory)


;;;; =======  LOAD PACKAGES  =======
;; Load startup and core packages
(require '01-bootstrap-core)

;; Initialize global frameworks
(require '02-init-frameworks)

;; Core UI configuration
(require '03-visual-settings)

;; Enable tree-sitter support
(require '04-tree-sitter-lang-config)

;; Project management and file navigation
(require '05-project-management)

;; Support for terminal and Emacs' shells
(require '06-terminal-modes)

;; Packages & settings for select languages
(require '07-language-configs)

;; Linting, formatting, & LSPs
(require '08-code-assist)

;; Git(hub) integration & tooling
(require '09-git-tools)

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
(require '15-user-functions)


(provide 'init)
;;; init.el ends here.
