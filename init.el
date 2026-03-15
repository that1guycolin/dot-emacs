;;; init.el --- that1guycolin's dot-Emacs (new-org)
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
;; New organizational branch of that1guycolin's personal Emacs configuration.
;; Uses Elpaca as the package manager with optimized load order.
;; Files are named with numeric prefixes to enforce load order.

;;; Languages configured:
;; Bash, Cmake,  Emacs-Lisp, Fish, JSON, Lisp, Markdown, Python, TOML, XML, YAML

;;; Packages included:
;; See 01-elpaca.el through 09-themes.el for package declarations.

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

;; Configure Emacs to work with external programs
(require '10-external-connections)

;; Misc & Dashboard
(require '11-misc-packages)

;; Custom variables & functions
(add-hook 'emacs-startup-hook (lambda ()
				(require '12-user-functions)))


(provide 'init)
;;; init.el ends here
