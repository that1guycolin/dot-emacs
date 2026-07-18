;;; 07-language-configs.el --- Packages & settings for select languages -*- lexical-binding: t; -*-

;;; Packages included:
;; adjust-parens, auto-rename-tag, checkdoc, csv-mode, docker-compose-mode,
;; eask-mode, eldoc-cmake, elisp-def, eros, eros-inspector, fish-mode,
;; glsl-mode, grip-mode, ielm, ini-mode, inspector, just-ts-mode, kdl-mode,
;; lisp-semantic-hl, live-py-mode, macrostep, morlock, python-pytest, python-x,
;; rustic, sly, suggest, systemd, tree-inspector, yaml-pro

;;; Commentary:
;; Provide packages and settings that enhance Emacs support for specific markup,
;; scripting, & coding languages.

;;; Code:
;;; (E)Lisp:
;; Smart '()' (all)
(use-package adjust-parens
  :defer t
  :hook ((emacs-lisp-mode lisp-mode) . adjust-parens-mode))

;; Syntax highlighting (all)
(use-package lisp-semantic-hl
  :defer t
  :hook ((emacs-lisp-mode lisp-mode) . lisp-semantic-hl-mode))

;; Style checker (elisp)
(use-package checkdoc
  :ensure nil
  :defer t
  :commands (checkdoc-defun checkdoc-current-buffer))

;; Go directly to symbol definition (elisp)
(use-package elisp-def
  :defer t
  :hook (emacs-lisp-mode . elisp-def-mode))

;; Display function results in buffer (elisp)
(use-package eros
  :defer t
  :hook (emacs-lisp-mode . eros-mode))

;; Elisp REPL
(use-package ielm
  :ensure nil
  :defer t
  :bind ("C-c I" . ielm))

;; Inspection tool (elisp)
(use-package inspector
  :defer t
  :bind (:map emacs-lisp-mode-map ("M-I e" . inspector-inspect-expression))
  :custom (inspector-switch-to-buffer nil))

;; Integration (elisp)
(use-package eros-inspector
  :after (eros inspector)
  :demand t
  :bind (:map emacs-lisp-mode-map
              ([remap eros-eval-last-sexp] . eros-inspector-eval-last-sexp)
              ([remap eros-eval-defun]     . eros-inspector-eval-defun)))

;; Interactively parse macros (elisp)
(use-package macrostep
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c C-m" . macrostep-expand)))

;; Additional font hl (elisp)
(use-package morlock
  :defer t
  :hook (emacs-lisp-mode . morlock-mode))

;; Provide tool to accomplish X
(use-package suggest
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c S" . suggest)))

;; Tree-style viewer for inspector
(use-package tree-inspector
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("M-I t" . tree-inspector-inspect-expression)
              ("M-I s" . tree-inspector-inspect-last-sexp)))

;; Modern SLIME (cl)
(use-package sly
  :defer t
  :preface (declare-function corfu-mode "corfu")
  :bind ("C-c s" . sly)
  :hook (lisp-mode . sly-editing-mode)
  :init
  (setq
   sly-lisp-implementations
   '((sbcl ("sbcl" "--noinform") :init sly-init-using-slynk-loader)))
  :custom (sly-contribs '(sly-fancy))
  :config (add-hook 'sly-mrepl-mode-hook #'corfu-mode))


;;; Python:
(defvar python-base-mode-map)
;; FUNCTIONS
(defun user/python-uv-script-p ()
  "Return non-nil if current buffer is a uv script."
  (and buffer-file-name
       (save-excursion
         (goto-char (point-min))
         (looking-at-p
          (rx "#!/usr/bin/env -S uv tool run --script")))))

(defun user/python-run-smart ()
  "Run current Python file appropriately."
  (interactive)
  (cond
   ((user/python-uv-script-p)
    (compile
     (format "uv run %s"
             (shell-quote-argument buffer-file-name))))
   ((locate-dominating-file default-directory "pyproject.toml")
    (compile "uv run python -m pytest"))
   (t
    (compile
     (format "python %s"
             (shell-quote-argument buffer-file-name))))))

(with-eval-after-load 'python
  (define-key python-base-mode-map (kbd "C-c C-r") #'user/python-run-smart))

;; Live coding
(use-package live-py-mode
  :defer t
  :bind (:map python-base-mode-map
              ("C-c L" . live-py-mode)))

;; Support testing frameworks
(use-package python-pytest
  :defer t
  :bind (:map python-base-mode-map
              ("C-c C-t" . python-pytest-dispatch)))

;; Enhance built-in python(-ts)-mode
(use-package python-x
  :defer t
  :hook ((python-mode python-ts-mode) . python-x-setup))


;;; Additional languages:
;; Fish shell
(use-package fish-mode
  :defer t
  :interpreter "fish"
  :mode "\\.fish\\'"
  :custom (fish-enable-auto-indent t))

;; Rust/cargo
(use-package rustic
  :defer t
  :hook ((rust-mode rust-ts-mode) . rustic-mode)
  :custom
  (compilation-ask-about-save t)
  (rustic-analyzer-command '("/usr/lib/rustup/bin/rust-analyzer"))
  (rustic-cargo-use-last-stored-arguments t)
  (rustic-format-on-save-method 'rustic-format-buffer)
  (rustic-format-trigger 'on-save)
  (rustic-lsp-client 'eglot))


;;; Configuration file modes:
(use-package csv-mode
  :defer t
  :preface
  (defun user/function-for-csv-mode-hook ()
    "Use this as a the hook for `csv-mode'."
    (visual-line-mode -1)
    (toggle-truncate-lines 1)
    (csv-guess-set-separator)
    (csv-align-mode 1))
  :hook (csv-mode . user/function-for-csv-mode-hook)
  :mode "\\.csv\\'"
  :functions (csv-guess-set-separator csv-align-mode))

(use-package docker-compose-mode
  :defer t
  :mode ("docker-copmpose\\.ya?ml\\'" "compose\\.ya?ml\\'"))

(use-package eask-mode
  :defer t
  :mode "Eask\\'")

(use-package glsl-mode
  :defer t
  :mode "\\.glsl\\'")

(use-package ini-mode
  :defer t
  :mode ("\\.ini\\'" "\\.desktop\\'" "\\.hook\\'"))

(use-package just-ts-mode
  :defer t
  :mode "justfile\\'")

(use-package kdl-mode
  :defer t
  :mode "\\.kdl\\'")

(use-package systemd
  :defer t
  :mode (("\\.container\\'" . systemd-mode)
         ("\\.service\\'"   . systemd-mode)
         ("\\.socket\\'"    . systemd-mode)))


;;; Enhance built-in modes:
;; XML tag assistant
(use-package auto-rename-tag
  :defer t
  :hook (nxml-mode . auto-rename-tag-mode))

;; Doc support in cmake(-ts)-mode
(use-package eldoc-cmake
  :defer t
  :hook ((cmake-mode cmake-ts-mode) . eldoc-cmake-enable))

;; Support for gfm in markdown(-ts)-mode
(use-package grip-mode
  :defer t
  :preface (defvar markdown-ts-mode-map)
  :bind (:map markdown-ts-mode-map
              ("C-c j" . grip-mode)
              :map markdown-mode-map
              ("C-c j" . grip-mode))
  :custom (grip-command 'auto))

;; YAML like a pro
(use-package yaml-pro
  :defer t
  :hook ((yaml-mode yaml-ts-mode) . yaml-pro-mode))


(provide '07-language-configs)
;;; 07-language-configs.el ends here
