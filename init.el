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
;; it under the terms of the GNU General Public License as published byt
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

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))

;; Load 'elpaca' and 'auto-compile' first
(load (expand-file-name "initial-packages.el" user-init-directory))

;; Completions, buffers, etc...
(load (expand-file-name "user-interface-config.el" user-init-directory))

;; 'projectile', 'treemacs' etc...
(load (expand-file-name "project-support-configs.el" user-init-directory))

;; Define & configure languages
(load (expand-file-name "language-specific-configs.el" user-init-directory))

;; Emacs as file explorer
(load (expand-file-name "directory-explorer-config.el" user-init-directory))

;; Emacs OS ;-)
(load (expand-file-name "external-connections.el" user-init-directory))

;; Load last
(load (expand-file-name "other-packages.el" user-init-directory))

;; User functions
(load (expand-file-name "user-functions.el" user-init-directory))

(declare-function profiler-stop "profiler.el")
(declare-function profiler-report "profiler.el")

(provide 'init)
;;; init.el ends here