;;; init.el --- that1guycolin's dot-Emacs -*- lexical-binding: t; -*-
;; Copyright (C) 2026  Loeffler, Colin
;; Created date 2026-02-28

;; Author: Loeffler, Colin <that1guycolin@gmail.com>
;; URL: https://github.com/that1guycolin/dot-emacs.git
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
;;
;; The main and development branches prefer packages from MELPA,
;; while the lite and lite-dev branches explicitly prefer native Emacs packages
;; or packages from ELPA.
;;
;; Supported languages: bash, cmake, common-lisp, emacs-lisp, fish, json,
;; markdown, python, toml, xml, yaml

;;; Packages included:
;; See init.el.d/*.el for package declarations. Core packages include:
;; adjust-parens, apheleia, auto-compile, auto-complete, cape, corfu, dap-mode,
;; dashboard, deadgrep, dired-*, eask-mode, editorconfig, elisp-def, elpaca,
;; emms, envrc, fish-mode, flycheck, forge, gcmh, lsp-mode, magit, marginalia,
;; markdown-ts-mode, mistty, nerd-icons, orderless, org, projectile, python,
;; ranger, savehist, sly, suggest, treemacs, treesit, uv-mode, vertico,
;; which-key, yasnippet

;;; Code:
;; Load Paths
(add-to-list 'load-path (expand-file-name "init.el.d" user-emacs-directory))
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))

;; Load 'elpaca' and 'auto-compile' first
(require 'initial-packages)

;; 'projectile', 'treemacs' etc...
(require 'project-support-configs)

;; Define & configure languages
(require 'language-specific-configs)

;; Completions, buffers, etc...
(require 'user-interface-config)

;; Emacs OS ;-)
(require 'external-connections)

;; Define & configure custom functions
(require 'user-functions)

(provide 'init)
;;; init.el ends here
