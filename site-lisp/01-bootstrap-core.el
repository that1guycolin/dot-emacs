;;; 01-bootstrap-core.el --- Load startup and core packages -*- lexical-binding: t; -*-

;;; Packages included:
;; emacs, envrc, exec-path-from-shell, gcmh, transient

;;; Commentary:
;; Packages that must load first because they impact startup or because their
;; latest version is preferred over their built-in version.

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

  (defvar user/emacs-load-libs '(bs cl-lib hl-line mouse seq subr-x)
    "List of optional Emacs libraries to load at Emacs start.")

  :bind (("C-TAB"   . completion-at-point)
         ("C-c x"   . toggle-frame-maximized)
         ("C-c ("   . user/check-parens-with-message)
         ("C-c #"   . display-line-numbers-mode)
         ("C-c C-#" . global-display-line-numbers-mode)
         ("C-c C-$" . restart-emacs))
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


(provide '01-bootstrap-core)
;;; 01-bootstrap-core.el ends here
