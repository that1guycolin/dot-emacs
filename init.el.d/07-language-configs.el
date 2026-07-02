;;; 07-language-configs.el --- Packages & settings for select languages -*- lexical-binding: t; -*-

;;; Packages included:
;; adjust-parens, auto-rename-tag, checkdoc, csv-mode, eask-mode, eldoc-cmake,
;; elisp-def, eros, eros-inspector, fish-mode, glsl-mode, grip-mode, ielm,
;; ini-mode, inspector, just-ts-mode, kdl-mode, lisp-semantic-hl, live-py-mode,
;; macrostep, morlock, python-pytest, python-x, rustic, sly, suggest, systemd,
;; tree-inspector, yaml-pro

;;; Commentary:
;; Provide packages and settings that enhance Emacs support for specific markup,
;; scripting, & coding languages.

;;; Code:
;;;; =======  (E)LISP  =======
;; ALL:
;; `adjust-parens'       (smart '()')
;; `lisp-semantic-hl'    (cl & elisp syntax hl)
;; -------------------------
;; EMACS LISP
;; `checkdoc'            (style checker)
;; `elisp-def'           (go directly to symbol def)
;; `eros'                (see function results in buffer)
;; `ielm'                (interactive elisp shell)
;; `inspector'           (inspection tool for emacs-lisp objects)
;; `eros-inspector'      (combine functionality of eros & inspector)
;; `macrostep'           (interactive macro stepper)
;; `morlock'             (additional font hl)
;; `suggest'             (find function to accomplish X)
;; `tree-inspector'      (tree-style view for inspector)
;; -------------------------
;; COMMON
;; `sly'                 (modern slime)
;;   =========================
(use-package adjust-parens
  :defer t
  :hook ((emacs-lisp-mode lisp-mode) . adjust-parens-mode))

(use-package lisp-semantic-hl
  :defer t
  :hook ((emacs-lisp-mode lisp-mode) . lisp-semantic-hl-mode))

(use-package checkdoc
  :ensure nil
  :defer t
  :commands checkdoc-defun checkdoc-current-buffer)

(use-package elisp-def
  :defer t
  :hook (emacs-lisp-mode . elisp-def-mode))

(use-package eros
  :defer t
  :hook (emacs-lisp-mode . eros-mode))

(use-package ielm
  :ensure nil
  :defer t
  :bind ("C-c I" . ielm))

(use-package inspector
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("M-I e" . inspector-inspect-expression))
  :custom
  (inspector-switch-to-buffer nil))

(use-package eros-inspector
  :after eros inspector
  :bind (:map emacs-lisp-mode-map
              ([remap eros-eval-last-sexp] . eros-inspector-eval-last-sexp)
              ([remap eros-eval-defun]     . eros-inspector-eval-defun)))

(use-package macrostep
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c C-m" . macrostep-expand)))

(use-package morlock
  :defer t
  :hook (emacs-lisp-mode . morlock-mode))

(use-package suggest
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c S" . suggest)))

(use-package tree-inspector
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("M-I t" . tree-inspector-inspect-expression)
              ("M-I s" . tree-inspector-inspect-last-sexp)))

(use-package sly
  :defer t
  :hook (lisp-mode . sly-editing-mode)
  :commands sly
  :functions sly-init-string
  :custom
  (inferior-lisp-program "sbcl")
  (sly-lisp-implementations
   '((sbcl ("sbcl" "--dynamic-space-size" "2048")
           :coding-system utf-8-unix)))

  :config
  (let ((ql-setup "~/quicklisp/setup.lisp"))
    (when (file-exists-p ql-setup)
      (setq sly-lisp-implementations
            (mapcar
             (lambda (impl)
               (append impl
                       (list
                        :init
                        (lambda (port-filename coding-system)
                          (format "(progn (load \"%s\") %s)\n"
                                  (expand-file-name ql-setup)
                                  (sly-init-string
                                   port-filename
                                   coding-system))))))
             sly-lisp-implementations))))
  (add-to-list 'sly-contribs 'sly-mrepl))


;;;; =======  PYTHON  =======
;; `live-py-mode'        (live coding)
;; `python-pytest'       (integrate testing)
;; `python-x'            (enhance built-in python(-ts)-mode)
;;   ========================
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

;; PACKAGES
(use-package live-py-mode
  :defer t
  :bind (:map python-base-mode-map
              ("C-c L" . live-py-mode)))

(use-package python-pytest
  :defer t
  :bind (:map python-base-mode-map
              ("C-c C-t" . python-pytest-dispatch)))


(use-package python-x
  :defer t
  :hook ((python-mode python-ts-mode) . python-x-setup))


;;;; =======  ADDITIONAL LANGUAGE SUPPORT  =======
;; `fish-mode'   (fish shell support)
;; `rustic'      (rust/cargo support)
;;   =============================================
(use-package fish-mode
  :defer t
  :interpreter "fish"
  :mode "\\.fish\\'"
  :custom
  (fish-enable-auto-indent t))

(use-package rustic
  :defer t
  :mode ("\\.rs\\'" . rustic-mode)
  :custom
  (compilation-ask-about-save t)
  (rustic-analyzer-command '("/usr/lib/rustup/bin/rust-analyzer"))
  (rustic-cargo-use-last-stored-arguments t)
  (rustic-format-on-save-method 'rustic-format-buffer)
  (rustic-format-trigger 'on-save)
  (rustic-lsp-client 'lsp-mode))


;;;; =======  CONFIG FILE MODES  =======
;; `csv-mode'            (support csv files)
;; `eask-mode'           (support Eask files)
;; `glsl-mode'           (support OpenGL Shading Language)
;; `just-ts-mode'        (justfile-support)
;; `ini-mode'            (config file support)
;; `just-ts-mode'        (justfile support)
;; `kdl-mode'            (support .kdl)
;; `systemd'             (support services & sockets)
;;   ===================================
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
  :functions
  csv-guess-set-separator csv-align-mode)

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
  :mode
  (("\\.container\\'" . systemd-mode)
   ("\\.service\\'"   . systemd-mode)
   ("\\.socket\\'"    . systemd-mode)))


;;;; =======  ENHANCE BUILT-INS  =======
;; `auto-rename-tag'     (xml tag assistant)
;; `eldoc-cmake'         (doc support in cmake-ts-mode)
;; `grip-mode'           (support for gfm)
;; `yaml-pro'            (enhanced .yaml support)
;;   ===================================
(use-package auto-rename-tag
  :defer t
  :hook (nxml-mode . auto-rename-tag-mode))

(use-package eldoc-cmake
  :defer t
  :hook (cmake-ts-mode . eldoc-cmake-enable))

(use-package grip-mode
  :defer t
  :preface (defvar markdown-ts-mode-map)
  :bind
  (:map markdown-ts-mode-map
        ("C-c j" . grip-mode)
        :map markdown-mode-map
        ("C-c j" . grip-mode))
  :custom
  (grip-command 'auto))

(use-package yaml-pro
  :defer t
  :hook (yaml-ts-mode . yaml-pro-mode))


(provide '07-language-configs)
;;; 07-language-configs.el ends here
