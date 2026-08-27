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

;;; Commentary:
;; that1guycolin's personal Emacs configuration.  Reduces startup time by
;; optimizing load-order and using `Elpaca' as package manager.  Organization
;; clutter-free environment thanks to `no-littering'.

;;; Code:
;;; Global settings:
(require 'a-elpaca)
(require 'b-emacs)
(require 'c-org)

;;; Modular Init:
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
(require '07-support)


(provide 'init)
;;; init.el ends here.

                                        ; LocalWords:  nomessage
