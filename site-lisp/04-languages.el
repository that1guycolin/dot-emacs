;;; 04-languages.el --- Language Specific Settings -*- lexical-binding: t; -*-

;;; Packages included:
;; adjust-parens, auto-rename-tag, bash-ts-mode, checkdoc, cmake-ts-mode,
;; csv-mode, docker-compose-mode, dockerfile-ts-mode, eask-mode, eldoc-cmake,
;; elisp-def, emacs-lisp-mode, eros, eros-inspector, fish-mode, geiser,
;; geiser-guile, glsl-mode, grip-mode, ielm, ini-mode, inspector, json-ts-mode,
;; just-ts-mode, kdl-mode, lisp-mode, lisp-semantic-hl, live-py-mode,
;; lua-ts-mode, macrostep, macrostep-geiser, markdown-mode, markdown-ts-mode,
;; morlock, nxml-mode, python-pytest, python-ts-mode, python-x, rustic,
;; rust-ts-mode, sh-mode, sly, suggest, systemd, toml-ts-mode, tree-inspector,
;; treesit, yaml-pro, yaml-ts-mode

;;; Commentary:
;; The purpose of this file is to define how Emacs should behave in the
;; major-modes of different coding/scripting languages.  Different languages
;; obviously require different settings.  The use of Emacs' built-in treesitter
;; modes is almost always preferred (in this config), and it's worth noting that
;; the only package loaded with `:demand t' & not `:defer t' is treesit.

;;; Code:
(use-package treesit
  :ensure nil
  :demand t
  :preface
  (declare-function no-littering-expand-var-file-name "no-littering")
  (defvar user/remapped-langs-alist
    '((bash-mode              . bash-ts-mode)
      (cmake-mode             . cmake-ts-mode)
      (css-mode               . css-ts-mode)
      (dockerfile-mode        . dockerfile-ts-mode)
      (go-mode                . go-ts-mode)
      (json-mode              . json-ts-mode)
      (js-json-mode           . json-ts-mode)
      (lua-mode               . lua-ts-mode)
      (rust-mode              . rust-ts-mode)
      (typescript-mode        . typescript-ts-mode)
      (conf-toml-mode         . toml-ts-mode)
      (xml-mode               . xml-ts-mode)
      (yaml-mode              . yaml-ts-mode))
    "Alist of cons cells mapping orig lang modes to their treesit versions.")
  
  :mode ("\\.tsx\\'" . tsx-ts-mode)
  :init (setq treesit-extra-load-path
              (list (no-littering-expand-var-file-name "tree-sitter")))
  :custom (treesit-font-lock-level 4)
  :config
  (setq
   treesit-language-source-alist
   '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
     (common-lisp . ("https://github.com/tree-sitter-grammars/tree-sitter-commonlisp"))
     (cmake . ("https://github.com/uyha/tree-sitter-cmake"))
     (css . ("https://github.com/tree-sitter/tree-sitter-css"))
     (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
     (dockerfile . ("https://github.com/camdencheek/tree-sitter-dockerfile"))
     (fish . ("https://github.com/ram02z/tree-sitter-fish"))
     (emacs-lisp . ("https://github.com/Wilfred/tree-sitter-elisp"))
     (gitcommit . ("https://github.com/gbprod/tree-sitter-gitcommit"))
     (go . ("https://github.com/tree-sitter/tree-sitter-go"))
     (html . ("https://github.com/tree-sitter/tree-sitter-html"))
     (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"
                    "master" "src"))
     (json . ("https://github.com/tree-sitter/tree-sitter-json"))
     (kdl . ("https://github.com/tree-sitter-grammars/tree-sitter-kdl"))
     (lua . ("https://github.com/MunifTanjim/tree-sitter-lua"))
     (make . ("https://github.com/alemuller/tree-sitter-make"))
     (markdown . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown"
                  "split_parser" "tree-sitter-markdown/src"))
     (markdown-inline . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown"
                         "split_parser" "tree-sitter-markdown-inline/src"))
     (powershell . ("https://github.com/airbus-cert/tree-sitter-powershell"))
     (python . ("https://github.com/tree-sitter/tree-sitter-python"))
     (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))
     (toml . ("https://github.com/ikatyang/tree-sitter-toml"))
     (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript"
             "master" "tsx/src"))
     (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript"
                    "master" "typescript/src"))
     (xml . ("https://github.com/tree-sitter-grammars/tree-sitter-xml"))
     (yaml . ("https://github.com/ikatyang/tree-sitter-yaml"))
     (zsh . ("https://github.com/georgeharker/tree-sitter-zsh"))))
  (dolist (remaped user/remapped-langs-alist)
    (add-to-list 'major-mode-remap-alist remaped)))


;;; CSV:
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


;;; Containers:
(use-package docker-compose-mode
  :defer t
  :mode ("docker-copmpose\\.ya?ml\\'" "compose\\.ya?ml\\'"))

(use-package dockerfile-ts-mode
  :ensure nil
  :defer t
  :mode ("Dockerfile\\'" "Containerfile\\'")
  :config
  (add-hook 'dockerfile-ts-mode-hook
            (lambda () (setq-local fill-column 1000))))


;;; Shaders:
(use-package glsl-mode
  :defer t
  :mode "\\.glsl\\'")


;;; (E)Lisp:
(use-package emacs-lisp-mode
  :ensure nil
  :defer t
  :mode "\\.el\\'")

(use-package lisp-mode
  :ensure nil
  :defer t
  :interpreter "sbcl"
  :mode ("\\.lisp\\'" "\\.cl\\'" "\\.asd\\'"))

;; Smart '()' (both)
(use-package adjust-parens
  :defer t
  :hook ((emacs-lisp-mode lisp-mode) . adjust-parens-mode))

;; Syntax highlighting (both)
(use-package lisp-semantic-hl
  :defer t
  :hook ((emacs-lisp-mode lisp-mode) . lisp-semantic-hl-mode))

;; Style checker (elisp)
(use-package checkdoc
  :ensure nil
  :defer t
  :commands (checkdoc-defun checkdoc-current-buffer))

;; Emacs package assist
(use-package eask-mode
  :defer t
  :mode "Eask\\'")

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

;; Provide tool to accomplish X (elisp)
(use-package suggest
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("C-c S" . suggest)))

;; Tree-style viewer for inspector (elisp)
(use-package tree-inspector
  :defer t
  :bind (:map emacs-lisp-mode-map
              ("M-I t" . tree-inspector-inspect-expression)
              ("M-I s" . tree-inspector-inspect-last-sexp)))

;; Modern SLIME (cl)
(use-package sly
  :defer t
  :preface
  (declare-function corfu-mode "corfu")

  (defvar-keymap user/sly-functions-map
    :doc "Common functions from the sly lisp implementation."
    "s" #'sly-setup
    "r" #'sly-mrepl
    "m" #'sly-mrepl-new
    "y" #'sly-mrepl-sync
    "d" #'sly-mrepl-set-directory
    "c" #'sly-cd
    "i" #'sly-inspect
    "a" #'sly-apropos
    "w" #'sly-describe-symbol)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements user/sly-functions-map
      "s" "Start Sly"
      "r" "Sly REPL"
      "m" "New Sly REPL"
      "y" "Set pkg & dir"
      "d" "Set REPL dir"
      "c" "Set lisp dir"
      "i" "Eval & inspect expr"
      "a" "Symbol match"
      "w" "Describe symbol"))
  
  :bind-keymap ("C-c s" . user/sly-functions-map)
  :hook (lisp-mode . sly-editing-mode)
  :init (setq inferior-lisp-program "sbcl")
  :custom (sly-lisp-implementations
           '((sbcl ("sbcl" "--load"
                    (no-littering-expand-etc-file-name "sly-setup.lisp"))
                   :coding-system utf-8-unix)))
  :config
  (dolist (contrib '(sly-fancy sly-mrepl sly-indentation
                               sly-package-fu))
    (add-to-list 'sly-contribs contrib))
  (setq sly-auto-start 'always)
  (add-hook 'sly-mrepl-mode-hook #'corfu-mode))



;;; Lua:
(use-package lua-ts-mode
  :ensure nil
  :defer t
  :mode "\\.lua\\'"
  :custom (lua-ts-inferior-lua "luajit"))


;;; Markdown:
(use-package markdown-mode
  :defer t
  :preface
  (defvar-keymap user/markdown-toggle-map
    :doc "Functions to toggle the display of elements in markdown."
    "RET" #'markdown-toggle-markup-hiding
    "TAB" #'markdown-toggle-inline-images
    "d"   #'markdown-move-down
    "u"   #'markdown-move-up
    "r"   #'markdown-demote
    "l"   #'markdown-promote
    "m"   #'markdown-insert-list-item
    "w"   #'markdown-insert-wiki-link
    "C-e" #'markdown-toggle-math
    "C-f" #'markdown-toggle-fontify-code-blocks-natively
    "C-l" #'markdown-toggle-url-hiding
    "C-x" #'markdown-toggle-gfm-checkbox)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements user/markdown-toggle-map
      "RET" "Toggle Markup Hiding"
      "TAB" "Toggle Inline Images"
      "d"   "Move Down"
      "u"   "Move Up"
      "r"   "Demote"
      "l"   "Promote"
      "m"   "Insert List Item"
      "w"   "Insert Wiki Link"
      "C-e" "Toggle Math"
      "C-f" "Toggle Code Block Fontification"
      "C-l" "Toggle URL Hiding"
      "C-x" "Toggle GFM Checkbox"))
  
  :bind (:map markdown-ts-mode-map
              ("C-c l" . markdown-mode))
  :bind-keymap (:map markdown-mode-map
                     ("C-c w" . user/markdown-toggle-map))
  :custom (markdown-fontify-codeblocks-natively t)
  :config (keymap-set markdown-mode-map "C-c C-x" #'toggle-frame-maximized))

(use-package markdown-ts-mode
  :ensure nil
  :defer t
  :preface
  (defvar-keymap user/markdown-ts-toggle-map
    :doc "Functions to toggle the display of markdown elements."
    "RET" #'markdown-ts-toggle-hide-markup
    "C-f" #'markdown-ts-emphasize
    "C-v" #'markdown-ts-toggle-inline-images)
  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements user/markdown-ts-toggle-map
      "RET" "Toggle Hide Markup"
      "C-f" "Emphasize"
      "C-v" "Toggle Inline Images"))
  :bind (:map markdown-mode-map
              ("C-c l" . markdown-ts-mode))
  :bind-keymap (:map markdown-ts-mode-map
                     ("C-c w" . user/markdown-ts-toggle-map))
  :define (markdown-ts-mode-map)
  :mode ("\\.md\\'" "README\\'" "INSTALL\\'")
  :config (keymap-set markdown-ts-mode-map "C-c C-x" #'toggle-frame-maximized))

(use-package grip-mode
  :defer t
  :bind (:map markdown-ts-mode-map
              ("C-c j" . grip-mode)
              :map markdown-mode-map
              ("C-c j" . grip-mode))
  :custom (grip-command 'auto))


;;; Python:
(use-package python-ts-mode
  :ensure nil
  :defer t
  :preface
  (defvar python-base-mode-map)

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

  :bind (:map python-base-mode-map
              ("C-c C-k c" . python-skeleton-class)
              ("C-c C-k d" . python-skeleton-def)
              ("C-c C-k f" . python-skeleton-for)
              ("C-c C-k i" . python-skeleton-if)
              ("C-c C-k m" . python-skeleton-import)
              ("C-c C-k t" . python-skeleton-try)
              ("C-c C-k w" . python-skeleton-while)
              ("C-c C-r"   . user/python-run-smart))
  :interpreter ("python3" "uv")
  :mode "\\.py\\'"
  :functions (python-skeleton-class
              python-skeleton-def python-skeleton-for python-skeleton-if
              python-skeleton-import python-skeleton-try python-skeleton-while)
  :custom
  (python-indent-offset 4)
  (python-shell-interpreter "python3")
  :config (keymap-unset python-base-mode-map "C-c C-t"))

;; Live coding
(use-package live-py-mode
  :after (:any python-mode python-ts-mode)
  :defer t
  :bind (:map python-base-mode-map
              ("C-c L" . live-py-mode)))

;; Support testing frameworks
(use-package python-pytest
  :after (:any python-mode python-ts-mode)
  :defer t
  :bind (:map python-base-mode-map
              ("C-c C-t" . python-pytest-dispatch)))

;; Enhance built-in python(-ts)-mode
(use-package python-x
  :after (:any python-mode python-ts-mode)
  :demand t
  :functions (python-x-setup)
  :config (python-x-setup))


;;; Rust/Cargo:
(use-package rust-ts-mode
  :ensure nil
  :defer t
  :mode "\\.rs\\'")

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


;;; Scheme:
(use-package geiser
  :defer t
  :bind ("C-c C-s" . geiser)
  :custom (geiser-repl-use-other-window nil))

(use-package geiser-guile
  :after (geiser)
  :demand t)

(use-package macrostep-geiser
  :defer t
  :bind ())

;;; Shell scripts:
(use-package bash-ts-mode
  :ensure nil
  :defer t
  :interpreter "bash"
  :mode "\\.bash\\'")

(use-package sh-mode
  :ensure nil
  :defer t
  :interpreter ("sh" "zsh" "dash")
  :mode ("\\.zsh\\'" "\\.dash\\'"))

;; Fish shell:
(use-package fish-mode
  :defer t
  :interpreter "fish"
  :mode "\\.fish\\'"
  :custom (fish-enable-auto-indent t))


;;; Build File Modes:
;;; CMake:
(use-package cmake-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.cmake\\'" "CMakeLists\\.txt\\'"))

(use-package eldoc-cmake
  :defer t
  :hook ((cmake-mode cmake-ts-mode) . eldoc-cmake-enable))

;; Justfile:
(use-package just-ts-mode
  :defer t
  :mode "justfile\\'")


;;; Config File Modes:
;; INI:
(use-package ini-mode
  :defer t
  :mode ("\\.ini\\'" "\\.desktop\\'" "\\.hook\\'"))

;; JSON:
(use-package json-ts-mode
  :ensure nil
  :defer t
  :mode ("\\.json\\'" "\\.json\\'"))

;; KDL:
(use-package kdl-mode
  :defer t
  :mode "\\.kdl\\'")

;; Systemd:
(use-package systemd
  :defer t
  :mode (("\\.container\\'" . systemd-mode)
         ("\\.service\\'"   . systemd-mode)
         ("\\.socket\\'"    . systemd-mode)))

;; TOML:
(use-package toml-ts-mode
  :ensure nil
  :defer t
  :mode "\\.toml\\'")

;; XML:
(use-package nxml-mode
  :ensure nil
  :defer t
  :mode ("\\.xml\\'"
         "\\.xsd\\'" "\\.xslt\\'" "\\.svg\\'" "\\.rss\\'" "\\.pom\\'")
  :custom
  (nxml-child-indent 2)
  (nxml-attribute-indent 2)
  (nxml-slash-auto-complete-flag t))

(use-package auto-rename-tag
  :defer t
  :hook (nxml-mode . auto-rename-tag-mode))

;;; YAML:
(use-package yaml-ts-mode
  :ensure nil
  :defer t
  :preface
  :mode ("\\.yml\\'" "\\.yaml\\'")
  :config
  (add-hook 'yaml-ts-mode-hook
            (lambda () (setq-local fill-column 1000))))

(use-package yaml-pro
  :defer t
  :hook ((yaml-mode yaml-ts-mode) . yaml-pro-mode))


(provide '04-languages)
;;; 04-languages.el ends here
