;;; init.el --- that1guycolin's dot-Emacs  -*- lexical-binding: t; -*-
;; Copyright (C) 2026  Loeffler, Colin (that1guycolin)
;; Created date: 2026-03-09

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
;; that1guycolin's personal Emacs configuration.  Uses Elpaca as the package
;; manager with optimized load order.

;;; Languages configured:
;; Bash, CMake, Emacs-Lisp, Fish, JSON, Markdown, Python, Steel-Bank-Common-Lisp,
;; TOML, XML, YAML

;;; Packages included:
;; adaptive-wrap, adjust-parens, apheleia, async, auto-rename-tag,
;; auto-virtualenv, bash-ts-mode, cape, checkdoc, cmake-ts-mode, corfu, dap-mode,
;; dashboard, deadgrep, diff-hl, diredfl, dirvish, disproject, djvu, docstr,
;; dwim-shell-command, eask-mode, editorconfig, el2org, elisp-def, elisp-dev-mcp,
;; ellama, elpaca, elpaca-use-package, emacs, emacs-everywhere, emacs-lisp-mode,
;; emms, emms-info-mediainfo, envrc, eros, eros-inspector, esh-autosuggest,
;; eshell-git-prompt, eshell-syntax-highlighting, esh-help, exec-path-from-shell,
;; fish-mode, flycheck, flycheck-color-mode-line, flycheck-eask,
;; flycheck-package, flycheck-pos-tip, forge, free-keys, gcmh, ghostel,
;; git-commit-ts-mode, git-modes, glsl-mode, gptel, gptel-commit,
;; gptel-forge-prs, gptel-magit, grip-mode, helpful, ielm, ini-mode, inspector,
;; json-ts-mode, kdl-mode, lisp-mode, lisp-semantic-hl, live-py-mode, lsp-mode,
;; lsp-treemacs, lsp-ui, lua-ts-mode, macrostep, magit, magit-git-toolbelt,
;; magit-org-todos, marginalia, markdown-mode, mason, minions, mistty, modern-sh,
;; morlock, native-complete, nerd-icons, nerd-icons-corfu, nov, nxml-mode,
;; orderless, org, org-autolist, org-caldav, org-edna, org-gtd, org-mcp, org-mem,
;; org-modern, org-modern-indent, org-node, org-noter, org-noter-pdftools,
;; org-pdftools, org-pomodoro, org-project-capture, pdf-tools, perspective,
;; perspective-project-bridge, project, project-treemacs, python-ts-mode,
;; python-x, rg, savehist, sh-mode, sly, smartparens, suggest,
;; tab-line-nerd-icons, telega, toc-org, toml-ts-mode, transient, tree-inspector,
;; treemacs, treemacs-magit, treemacs-nerd-icons, treemacs-perspective, treesit,
;; treesit-auto, vertico, vterm, which-key, with-editor, yaml-pro, yaml-ts-mode,
;; yasnippet, yasnippet-capf, yasnippet-snippets

;;; Code:
;; =======  LOAD PATHS  =======
(defvar user/init-directory (expand-file-name "init.el.d" user-emacs-directory)
  "Directory from which init files are loaded.")

(defvar user/projects-directory (expand-file-name "~/projects")
  "Directory in which the user stores custom projects.")

(defvar user/scripts-directory (expand-file-name "~/scripts")
  "Directory in which the user stores custom scripts by shell-type.")

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

;; Listen to music & watch videos
(require '12-media-player)

;; Misc & Dashboard
(require '13-misc-packages)

;; Install themes
(require '14-install-themes)

;; Custom variables & functions
(require '15-user-functions)


(provide 'init)
;;; init.el ends here.
