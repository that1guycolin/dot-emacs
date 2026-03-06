;;; init.el --- that1guycolin's dot-Emacs -*- lexical-binding: t; -*-
;; Copyright (C) 2026  Loeffler, Colin (that1guycolin)
;; Created date: 2026-02-28

;; Author: Loeffler, Colin <that1guycolin@gmail.com>
;; URL: https://github.com/that1guycolin/dot-emacs
;; Version: 0.1.0
;; Branch: main
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
;; Main branch of that1guycolin's personal Emacs configuration.
;; Uses Elpaca as the package manager.  This file is a wrapper that loads
;; modular configuration files from {user-emacs-directory}/init.el.d/.

;; The main and development branches prefer packages from MELPA,
;; while the lite and lite-dev branches explicitly prefer native Emacs packages
;; or packages from ELPA.

;;; Languages configured:
;; Bash, Cmake,  Emacs-Lisp, Fish, JSON, Lisp, Markdown, Python, TOML, XML, YAML

;;; Packages included:
;; See init.el.d/*.el for package declarations. Core packages include:
;;
;; adjust-parens, apheleia, cape, corfu, dap-mode, dashboard, deadgrep, dired-*,
;; dirvish, eask-mode, editorconfig, elisp-def, elpaca, emms, envrc, fish-mode,
;; flycheck, forge, gcmh, lsp-mode, mason, magit, marginalia, markdown-mode,
;; mistty, nerd-icons, orderless, org, projectile, python savehist, slime,
;; suggest, treemacs, treesit, uv-mode, vertico, which-key, yasnippet

;;; Code:
;; Load Paths
(defvar user-init-directory (expand-file-name "init.el.d" user-emacs-directory)
  "Directory from which init files are loaded.")

(add-to-list 'load-path user-init-directory)

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))

;; Load 'elpaca' and 'auto-compile' first
(require 'initial-packages)

;; Completions, buffers, etc...
(require 'user-interface-config)

;; 'projectile', 'treemacs' etc...
(require 'project-support-configs)

;; Define & configure languages
(require 'language-specific-configs)

;; Emacs as file explorer
(require 'directory-explorer-config)

;; Not easily definable
(require 'other-packages)

;; Emacs OS ;-)
(require 'external-connections)

;; User functions
(require 'user-functions)

(provide 'init)
;;; init.el ends here
