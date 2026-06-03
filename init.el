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

;;; Commentary:
;; that1guycolin's personal Emacs configuration.  Uses Elpaca as package manager
;; with an optimized load order.

;;; Packages included:
;; activities, adaptive-wrap, adjust-parens, apheleia, auto-rename-tag,
;; bash-ts-mode, cape, casual, casual-avy, checkdoc, cmake-ts-mode,
;; comment-dwim-2, corfu, csv-mode, dap-mode, dashboard, deadgrep, diff-hl,
;; dirvish, disproject, djvu, docker, dockerfile-mode, docstr,
;; dwim-shell-command, eask-mode, eat, editorconfig, ef-themes, el2org,
;; eldoc-cmake, elisp-def, elisp-dev-mcp, ellama, emacs, emacs-everywhere,
;; emacs-lisp-mode, emms, emms-info-mediainfo, envrc, eros, eros-inspector,
;; esh-autosuggest, eshell, eshell-git-prompt, eshell-syntax-highlighting,
;; esh-help, exec-path-from-shell, fish-mode, flycheck,
;; flycheck-color-mode-line, flycheck-eask, flycheck-package, flyover,
;; folding-mode, forge, free-keys, gcmh, ghostel, git-commit-ts-mode,
;; git-modes, glsl-mode, gptel, gptel-forge-prs, grip-mode, helpful, ielm,
;; ini-mode, inspector, json-ts-mode, just-ts-mode, kdl-mode, lisp-mode,
;; lisp-semantic-hl, live-py-mode, llm, lsp-mode, lsp-snippet-tempel,
;; lua-ts-mode, macrostep, magit, magit-org-todos, marginalia,
;; markdown-ts-mode, mcp-server-lib, minions, mistty, modus-themes, morlock,
;; native-complete, nerd-icons, nerd-icons-corfu, nov, nxml-mode, ob-rust,
;; orderless, org, org-edna, org-make-toc, org-mcp, org-mem, org-modern,
;; org-modern-indent, org-node, org-noter, org-noter-pdftools, org-pdftools,
;; org-pomodoro, org-project-capture, org-tidy, pdf-tools, perspective,
;; perspective-project-bridge, popper, project, python-pytest, python-ts-mode,
;; python-x, ready-player, rg, rustic, savehist, sh-mode, sly, smartparens,
;; suggest, systemd, tab-line-nerd-icons, telega, tempel, tempel-collection,
;; toml-ts-mode, transient, tree-inspector, treemacs, treemacs-magit,
;; treemacs-nerd-icons, treemacs-perspective, treesit, vertico,
;; visual-fill-column, visual-regexp, visual-regexp-steroids, vterm, which-key,
;; with-editor, yaml-pro, yaml-ts-mode, yasnippet, yasnippet-capf,
;; yasnippet-snippets


;;; Code:
;; =======  LOAD PATHS  =======
(defvar user/init-directory
  (expand-file-name "init.el.d" user-emacs-directory)
  "Directory from which init files are loaded.")

(defvar user/tools-directory
  (expand-file-name "tools" user-emacs-directory)
  "Directory containing scripts, etc for editing this configuration.")

(defvar user/projects-directory
  (expand-file-name "~/projects")
  "Directory containing active projects.")

(defvar user/scripts-directory
  (expand-file-name "~/scripts")
  "Directory containing custom \='one off' scripts.")

(add-to-list 'load-path user/init-directory)


;; =======  LOAD PACKAGES  =======
;; Load startup and core packages
(require '01-bootstrap-core)

;; Completion stack
(require '02-completion-setup)

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
