;;; init.el --- that1guycolin's dot-Emacs  -*- lexical-binding: t; -*-
;; Copyright (C) 2026  Loeffler, Colin (that1guycolin)
;; Created date: 2026-03-09

;; Author: Loeffler, Colin <that1guycolin@gmail.com>
;; URL: https://github.com/that1guycolin/dot-emacs
;; Version: 0.3.0
;; Package-Requires: (emacs 30.2)
;; Keywords: emacs config elisp emacs-lisp

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
;; Updated organization of that1guycolin's personal Emacs configuration.
;; Uses Elpaca as the package manager with optimized load order.
;; In the interest of clarity, files in init.el.d/* now have numeric prefixes.

;;; Languages configured:
;; Bash, Cmake, Emacs-Lisp, Fish, JSON, Lisp, Markdown, Python, TOML, XML, YAML

;;; Packages included:
;; adaptive-wrap, adjust-parens, apheleia, auto-rename-tag, bash-ts-mode, cape,
;; checkdoc, cmake-ts-mode, corfu, dap-mode, dashboard, deadgrep, diredfl,
;; dirvish, disproject, eask-mode, editorconfig, elisp-def, elisp-dev-mcp,
;; elpaca, elpaca-use-package, emacs, emacs-everywhere, emacs-lisp-mode, emms,
;; envrc, eros, exec-path-from-shell, fish-mode, flycheck,
;; flycheck-color-mode-line, flycheck-eask, flyover, forge, gcmh, git-modes,
;; gptel, gptel-commit, gptel-forge-prs, gptel-magit, grip-mode, helpful, ielm,
;; json-ts-mode, kdl-mode, lisp-mode, lisp-semantic-hl, live-py-mode, lsp-mode,
;; lsp-treemacs, lsp-ui, macrostep, magit, magit-git-toolbelt, magit-pre-commit,
;; marginalia, markdown-mode, markdown-toc, minions, mistty, modern-sh,
;; nerd-icons, nerd-icons-corfu, nxml-mode, orderless, org, org-gtd, popper,
;; projectile, python-ts-mode, python-x, savehist, sly, smartparens, suggest,
;; tab-line-nerd-icons, toml-ts-mode, transient, treemacs, treemacs-magit,
;; treemacs-nerd-icons, treemacs-projectile, treesit, treesit-auto, uv-mode,
;; vertico, vterm, which-key, with-editor, yaml-pro, yaml-ts-mode, yasnippet,
;; yasnippet-capf, yasnippet-snippets

;;; Code:
;; =======  LOAD PATHS  =======
(defvar user-init-directory (expand-file-name "init.el.d" user-emacs-directory)
  "Directory from which init files are loaded.")

(defvar user-projects-directory (expand-file-name "~/projects")
  "Directory in which the user stores custom projects.")

(add-to-list 'load-path user-init-directory)


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

;; Linting, formatting, & LSPs
(require '06-code-assist)

;; Git(hub) integration & tooling
(require '07-git-tools)

;; Packages & settings for select languages
(require '08-language-configs)

;; File explorer functions
(require '09-file-management)

;; Extensions for Org-mode
(require '10-org-mode-extensions)

;; Configure Emacs to work with llms
(require '12-media-player)

;; Misc & Dashboard
(require '13-misc-packages)

;; Custom variables & functions
(require '14-user-functions)


(provide 'init)
;;; init.el ends here
