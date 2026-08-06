;;; 01-environment.el --- Startup & Core Packages -*- lexical-binding: t; -*-

;;; Packages included:
;; avy, cape, consult, corfu, corfu-prescient, embark, embark-consult, envrc,
;; exec-path-from-shell, gcmh, helpful, marginalia, orderless, prescient,
;; savehist, tempel, tempel-collection, transient, vertico, vertico-prescient

;;; Commentary:
;; The packages in this file affect startup (gcmh), are designed to be loaded
;; early so they can observe/influence subsequently loaded packages
;; (exec-path-from-shell), or otherwise form the foundation upon which the rest
;; of this configuration is built (corfu, vertico, etc...). In particular, the
;; load order of the packages following transit is specific and intentional:
;; snippets (tempel) are loaded first because they hook into the completion
;; functions that follow.
;;
;; Note that every package in this file, even if called with `:after t', is
;; called with `:demand t'.

;;; Code:
;;; Bootstraps:
;; Smart garbage collection
(use-package gcmh
  :demand t
  :functions (gcmh-mode)
  :init (gcmh-mode 1))

;; Environment
(use-package exec-path-from-shell
  :demand t
  :preface
  (defvar that1guycolin/exec-path-from-shell-vars
    '("CC" "CXX" "GUILE_LOAD_PATH" "GUILE_LOAD_COMPILED_PATH" "INFOPATH"
      "LSP_USE_PLISTS" "PKG_CONFIG_PATH" "SSH_AGENT_PID" "SSH_AUTH_SOCK"
      "WAYLAND_DISPLAY")
    "List of environment variables to load at Emacs start.")
  :functions (exec-path-from-shell-initialize)
  :custom (exec-path-from-shell-shell-name "zsh")
  :config
  (dolist (var that1guycolin/exec-path-from-shell-vars)
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(use-package envrc
  :demand t
  :functions (envrc-global-mode)
  :config (envrc-global-mode 1))

;; Override-built-in version w/ package's latest version
(use-package transient
  :ensure (:wait t)
  :demand t)


;;; Snippets:
;; modern snippet framework with ancient roots
(use-package tempel
  :demand t
  :preface
  (defvar no-littering-etc-directory)
  (declare-function no-littering-expand-etc-file-name "no-littering")
  (defun that1guycolin/tempel-setup-capf ()
    "Locally add relevant tempel items to `completion-at-point-functions'."
    (setq-local completion-at-point-functions
                (cons #'tempel-complete completion-at-point-functions)))

  (defun that1guycolin/select-file-from-list (files prompt &optional other-win)
    "Request the user select a file from FILES to open.
Provide a custom PROMPT to display to the user.  If `other-win' is non-nil,
open the file in another window."
    (when (= 1 (length files))
      (let ((file (car files)))
        (warn "Only one file in provided, opening %s..." file)
        (if other-win (find-file-other-window file)
          (find-file file))))
    (let* ((choices (mapcar
                     (lambda (f) (cons (abbreviate-file-name f) f))
                     files))
           (choice (completing-read prompt choices nil t))
           (file (cdr (assoc choice choices))))
      (if other-win
          (find-file-other-window file)
        (find-file file))))
  
  (defun that1guycolin/tempel-edit-custom-templates ()
    "Open tempel template file(s) in another window."
    (interactive)
    (if (listp tempel-path)
        (that1guycolin/select-file-from-list
         tempel-path "Template file to open? " t)
      (find-file-other-window tempel-path)))
  
  :bind (("M-+"   . tempel-insert)
         ("M-*"   . tempel-complete)
         ("C-M-+" . that1guycolin/tempel-edit-custom-templates)
         :map tempel-map
         ("TAB"   . tempel-next)
         ("C-TAB" . tempel-previous))
  :hook ((text-mode prog-mode conf-mode) . that1guycolin/tempel-setup-capf)
  :functions (tempel-complete tempel-abbrev-mode)
  :init
  (setq tempel-path
        (directory-files
         (no-littering-expand-etc-file-name "templates") t
         directory-files-no-dot-files-regexp))
  (tempel-abbrev-mode 1))

;; tempel library
(use-package tempel-collection
  :after (tempel)
  :demand t)


;;; Completions:
;; Maintain history across sessions
(use-package savehist
  :ensure nil
  :demand t
  :config (savehist-mode 1))

;; Fuzzy matching
(use-package orderless
  :demand t
  :init
  (setq
   completion-styles '(orderless basic)
   completion-category-overrides '((file (styles basic partial-completion)))
   completion-category-defaults nil))

;; Sort & filter completions
(use-package prescient
  :demand t
  :init (add-to-list 'completion-styles 'prescient)
  :custom (prescient-sort-full-matches-first t))

;; Minibuffer completions
(use-package vertico
  :demand t
  :functions (vertico-mode)
  :custom
  (vertico-resize t)
  (vertico-cycle t)
  :config (vertico-mode 1))

(use-package vertico-prescient
  :after (prescient vertico)
  :demand t
  :functions (vertico-prescient-mode)
  :config (vertico-prescient-mode 1))

;; Rich annotations
(use-package marginalia
  :demand t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle)
              :map completion-list-mode-map
              ("M-A" . marginalia-cycle))
  :functions (marginalia-mode)
  :config (marginalia-mode 1))

;; Inline completions
(use-package corfu
  :demand t
  :bind (:map corfu-map
              ("C-n"   . corfu-next)
              ("C-p"   . corfu-previous)
              ("TAB"   . corfu-complete)
              ("RET"   . corfu-complete)
              ("C-RET" . corfu-reset)
              ("M-d"   . corfu-popupinfo-toggle)
              ("M-n"   . corfu-popupinfo-scroll-down)
              ("M-p"   . corfu-popupinfo-scroll-up))
  :functions (global-corfu-mode corfu-history-mode corfu-popupinfo-mode)
  
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 4)
  (corfu-auto-delay 1.6)
  (corfu-cycle t)
  (corfu-quit-at-boundary t)
  (corfu-quit-no-match t)
  (corfu-on-exact-match 'insert)
  (corfu-popupinfo-delay nil)

  :config
  (global-corfu-mode 1)
  (corfu-history-mode 1)
  (add-to-list 'savehist-additional-variables 'corfu-history)
  (corfu-popupinfo-mode 1))

(use-package corfu-prescient
  :after (corfu prescient)
  :demand t
  :functions (corfu-prescient-mode)
  :config (corfu-prescient-mode 1))

;; Extend completion framework
(use-package cape
  :demand t
  :bind ("C-c TAB" . cape-prefix-map)
  :functions (cape-dabbrev cape-file cape-elisp-block cape-history)
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-history))


;;; Additional frameworks:
;; Jump to...
(use-package avy
  :demand t)

;; Gather data
(use-package consult
  :demand t
  :preface
  (declare-function consult-register-window "consult-register")
  (defvar register-preview-delay)
  (defvar xref-show-xrefs-function)
  (defvar xref-show-definitions-function)

  :bind (("C-c M-x"            . consult-mode-command)
         ("C-c h"              . consult-history)
         ("C-c k"              . consult-kmacro)
         ("C-c M-m"            . consult-man)
         ("C-c i"              . consult-info)
         ([remap Info-search]  . consult-info)

         ("C-x M-:"            . consult-complex-command)
         ("C-x b"              . consult-buffer)
         ("C-x 4 b"            . consult-buffer-other-window)
         ("C-x 5 b"            . consult-buffer-other-frame)
         ("C-x t b"            . consult-buffer-other-tab)
         ("C-x r b"            . consult-bookmark)
         
         ("C-x r j"            . consult-register-load)
         ("C-x r s"            . consult-register-store)
         ("C-x r M-r"          . consult-register)
         
         ("M-y"                . consult-yank-pop)
         
         ("M-s d"              . consult-find)
         ("M-s g"              . consult-grep)
         ("M-s G"              . consult-git-grep)
         ("M-s r"              . consult-ripgrep)
         ("M-s l"              . consult-line)
         ("M-s L"              . consult-line-multi)
         ("M-s k"              . consult-keep-lines)
         ("M-s u"              . consult-focus-lines)
         
         ([remap goto-line]    . consult-goto-line)
         ([remap imenu]        . consult-imenu))
  :functions (consult--customize-put consult-xref)
  :init
  (setq register-preview-delay 0.5)
  (with-eval-after-load 'consult-register
    (advice-add 'register-preview :override #'consult-register-window))
  :custom
  (consult-narrow-key "<")
  (consult-project-function #'consult--default-project-function)
  :config
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   :preview-key '(:debounce 0.4 any))

  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

;; Mouse events on keyboard
(use-package embark
  :demand t
  :preface
  (defvar completion-category-overrides)
  (defvar display-buffer-alist)
  (defvar eldoc-documentation-strategy)
  (defvar prefix-help-command)

  :bind (("C-."   . embark-act)
         ("C-;"   . embark-dwim)
         ("C-h B" . embark-bindings))
  :functions (embark-prefix-help-command embark-eldoc-first-target)
  :init (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list
   'completion-category-overrides
   '(embark-keybinding (styles . (substring))))

  (add-to-list
   'display-buffer-alist
   '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
     nil
     (window-parameters (mode-line-format . none))))

  (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly))

;; Integrations
(use-package embark-consult
  :after (embark consult)
  :demand t
  :functions (consult-preview-at-point-mode)
  :config (add-hook 'embark-collect-mode-hook #'consult-preview-at-point-mode))

;; Even better help
(use-package helpful
  :demand t
  :preface (dolist (bind '("C-h f" "C-h v" "C-h k" "C-h x" "C-h F" "C-z"))
             (keymap-global-unset bind))
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)
         ("C-h ;" . helpful-at-point)
         ("C-h F" . helpful-function)
         ("C-h z" . helpful-kill-buffers)))


(provide '01-environment)
;;; 01-environment.el ends here
