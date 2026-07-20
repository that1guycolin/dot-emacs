;;; 01-env-cap.el --- Startup & Core Packages -*- lexical-binding: t; -*-

;;; Packages included:
;; avy, cape, consult, corfu, emacs, embark, embark-consult, envrc,
;; exec-path-from-shell, gcmh, helpful, marginalia, orderless, savehist,
;; tempel, tempel-collection, transient, vertico

;;; Commentary:
;; The packages in this file affect startup (gcmh), are designed to be loaded
;; early so they can observe/influence subsequently loaded packages
;; (exec-path-from-shell), or otherwise form the foundation upon which the rest
;; of this configuration is built (corfu, vertico, etc...). In particular, the
;; load order of the packages following transit is specific and intentional:
;; snippets (tempel) are loaded first because they hook into the completion
;; functions that follow.
;;
;; Note that every package in this file, even if called with `:after t', is called with `:demand t'.

;;; Code:
;;; Global Settings:
(use-package emacs
  :ensure nil
  :demand t
  :preface
  (defun user/check-parens-with-message ()
    "Run `check-parens'.  Print a message when all parentheses match."
    (interactive)
    (when (not (check-parens))
      (message "All parentheses match!")))

  (defun user/ibuffer-hook-functions ()
    "Group of functions to include in `ibuffer-mode-hook'."
    (hl-line-mode 1)
    (ibuffer-auto-mode 1))

  (defun user/untabify-buffer ()
    "Run `untabify' over current buffer."
    (interactive)
    (untabify (point-min) (point-max)))

  (defvar user/no-tab-modes
    '(bash-ts-mode
      emacs-lisp-mode lisp-mode python-mode python-ts-mode sh-mode)
    "Major modes indented by spaces and not by tabs.")

  (defun user/untabify-when-no-tab-mode ()
    "Run `user/untabify-buffer' if `major-mode' member `user/no-tab-modes'."
    (when (member major-mode user/no-tab-modes)
      (user/untabify-buffer)))

  ;; Side window:
  (defun user/toggle-side-window ()
    "Switch focus between a side window and the main window area.
If in a side window, return to the last used window.
If not in a side window, jump to the first found side window."
    (interactive)
    (let* ((side-window
            (cl-find-if
             (lambda (w)
               (window-parameter w 'window-side))
             (window-list))))
      (cond
       ((not side-window)
        (message "No side window found in this frame."))
       ((eq (selected-window) side-window)
        (select-window (get-mru-window nil nil t)))
       (t
        (select-window side-window)))))

  (defvar user/emacs-load-libs '(bs cl-lib hl-line mouse seq subr-x)
    "List of optional Emacs libraries to load at Emacs start.")

  :bind (("C-TAB"   . completion-at-point)
         ("C-c C-x" . toggle-frame-maximized)
         ("C-c ("   . user/check-parens-with-message)
         ("C-c #"   . display-line-numbers-mode)
         ("C-c C-#" . global-display-line-numbers-mode)
         ("C-c C-$" . restart-emacs)
         ("M-0"     . user/toggle-side-window))
  :hook (after-save . user/untabify-when-no-tab-mode)
  :functions (ibuffer-auto-mode)
  :custom
  (auto-save-visited-interval 60)
  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (read-extended-command-predicate #'command-completion-default-include-p)
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  :config
  (dolist (lib user/emacs-load-libs)
    (require lib))

  (abbrev-mode 1)
  (auto-save-visited-mode 1)
  (context-menu-mode 1)
  (global-display-fill-column-indicator-mode 1)
  (which-key-mode 1)
  
  (add-hook 'ibuffer-mode-hook #'user/ibuffer-hook-functions))


;;; Elpaca Functions/Keymap:
(use-package elpaca
  :ensure nil
  :demand t
  :preface
  (declare-function elpaca-update-menus                   "elpaca")
  (declare-function elpaca-manager                        "elpaca")
  (declare-function elpaca-fetch                          "elpaca")
  (declare-function elpaca-fetch-all                      "elpaca")
  (declare-function elpaca-merge                          "elpaca")
  (declare-function elpaca-merge-all                      "elpaca")
  (declare-function elpaca-rebuild                        "elpaca")
  (declare-function elpaca-update                         "elpaca")
  (declare-function elpaca-update-all                     "elpaca")
  (declare-function elpaca-build-autoloads                "elpaca")
  (declare-function elpaca-build-docs                     "elpaca")
  (declare-function elpaca-build-docs-process-sentinel    "elpaca")
  (declare-function elpaca-build-compile                  "elpaca")
  
  (defun user/elpaca-update-menus ()
    "Non-interactively run `elpaca-update-menus'."
    (interactive)
    (funcall #'elpaca-update-menus))

  (defvar-keymap user/elpaca-options-map
    :doc "Functions for Elpaca package manager."
    "m"    #'elpaca-manager
    "n"    #'user/elpaca-update-menus
    "f"    #'elpaca-fetch
    "F"    #'elpaca-fetch-all
    "e"    #'elpaca-merge
    "E"    #'elpaca-merge-all
    "r"    #'elpaca-rebuild
    "u"    #'elpaca-update
    "U"    #'elpaca-update-all
    "b a"  #'elpaca-build-autoloads
    "b d"  #'elpaca-build-docs
    "b D"  #'elpaca-build-docs-process-sentinel
    "b c"  #'elpaca-build-compile)

  (with-eval-after-load 'which-key
    (which-key-add-keymap-based-replacements
      user/elpaca-options-map
      "m"   "Elpaca Manager"
      "n"   "Update Menus"
      "f"   "Fetch"
      "F"   "Fetch All"
      "e"   "Merge"
      "E"   "Merge All"
      "r"   "Rebuild"
      "u"   "Update"
      "U"   "Update All"
      "b a" "Build Autoloads"
      "b d" "Build Docs"
      "b D" "Build Docs (Process Sentinel)"
      "b c" "Build Compile"))
  :bind-keymap ("C-c e" . user/elpaca-options-map))

;;; Other bootstraps:
;; Smart garbage collection
(use-package gcmh
  :demand t
  :functions (gcmh-mode)
  :init (gcmh-mode 1))

;; Environment
(use-package exec-path-from-shell
  :demand t
  :preface (defvar user/exec-path-from-shell-vars
             '("CC"
               "CXX" "LSP_USE_PLISTS" "PKG_CONFIG_PATH" "SSH_AGENT_PID"
               "SSH_AUTH_SOCK" "WAYLAND_DISPLAY")
             "List of environment variables to load at Emacs start.")
  :functions (exec-path-from-shell-initialize)
  :custom (exec-path-from-shell-shell-name "zsh")
  :config
  (setenv "PNPM_HOME" "/home/colin-l/.local/share/pnpm")
  (dolist (var user/exec-path-from-shell-vars)
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
  (defun user/tempel-setup-capf ()
    "Locally add relevant tempel items to `completion-at-point-functions'."
    (setq-local completion-at-point-functions
                (cons #'tempel-complete completion-at-point-functions)))

  (defun user/tempel-edit-custom-templates ()
    "Open tempel template file(s) in another window."
    (interactive)
    (if (listp tempel-path)
        (dolist (file tempel-path)
          (find-file-other-window file))
      (find-file-other-window tempel-path)))
  
  :bind (("M-+"   . tempel-insert)
         ("M-*"   . tempel-complete)
         ("C-M-+" . user/tempel-edit-custom-templates)
         :map tempel-map
         ("TAB"   . tempel-next)
         ("C-TAB" . tempel-previous))
  :hook ((text-mode prog-mode conf-mode) . user/tempel-setup-capf)
  :functions (tempel-complete tempel-abbrev-mode)

  :init
  (setq tempel-path (expand-file-name "templates" no-littering-etc-directory))
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

;; Minibuffer completions
(use-package vertico
  :demand t
  :functions (vertico-mode)
  :custom
  (vertico-resize t)
  (vertico-cycle t)
  :config (vertico-mode 1))

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
    (advice-add #'register-preview :override #'consult-register-window))
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


(provide '01-env-cap)
;;; 01-env-cap.el ends here
