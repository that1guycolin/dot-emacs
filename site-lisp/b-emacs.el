;;; b-emacs.el --- Global Settings -*- lexical-binding: t -*-

;;; Commentary:
;; Define global settings using a use-package sexp for the dummy "emacs" package.

;;; Code:
(use-package emacs
  :ensure nil
  :demand t
  :preface
  (defmacro that1guycolin/desktop-mobile (desk termux &optional gui)
    "Set different options depending on where Emacs is active.
DESK    - Settings for Emacs on PC/laptop.
TERMUX  - Settings for Emacs in the Android `termux' application.
GUI     - Settings for the Emacs Android GUI application (only required when
          the GUI and termux need different settings)."
    (declare (indent defun))
    `(cond
      ((and (eq system-type 'android) (null (getenv "TERMUX_VERSION")))
       ,(or gui termux))
      ((eq system-type 'android) ,termux)
      (t ,desk)))

;;;; Load paths:
  (defvar that1guycolin/projects-directory nil
    "Directory containing active projects.")

  (defvar that1guycolin/scripts-directory nil
    "Directory containing custom \='one off' scripts.")

  (defvar that1guycolin/android-home
    "/data/data/com.termux/files/home"
    "Termux home directory on Android.")

  (that1guycolin/desktop-mobile
    (setq
     that1guycolin/projects-directory (expand-file-name "~/projects/")
     that1guycolin/scripts-directory (expand-file-name "~/scripts/"))
    (setq
     that1guycolin/projects-directory
     (expand-file-name "projects" that1guycolin/android-home)
     that1guycolin/scripts-directory
     (expand-file-name "scripts" that1guycolin/android-home)))

;;;; tabs-to-spaces
  (defun that1guycolin/untabify-buffer ()
    "Run `untabify' over current buffer."
    (interactive)
    (untabify (point-min) (point-max)))

  (defvar that1guycolin/no-tab-modes
    '(bash-ts-mode
      emacs-lisp-mode lisp-mode lisp-data-mode python-mode python-ts-mode
      sh-mode)
    "Major modes indented by spaces and not by tabs.")

  (defun that1guycolin/untabify-when-no-tab-mode ()
    "Run `untabify-buffer' if `major-mode' in `no-tab-modes'."
    (when (member major-mode that1guycolin/no-tab-modes)
      (that1guycolin/untabify-buffer)))

;;;; side window
  (defun that1guycolin/toggle-side-window ()
    "Switch focus between a side window and the main window area.
If in a side window, return to the last used window.
If not in a side window, jump to the first found side window."
    (interactive)
    (let* ((side-window (cl-find-if
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

;;;; misc.
  (defun that1guycolin/check-parens-with-message ()
    "Run `check-parens'.  Print a message when all parentheses match."
    (interactive)
    (when (not (check-parens))
      (message "All parentheses match!")))

  (defun that1guycolin/ibuffer-hook-functions ()
    "Group of functions to include in `ibuffer-mode-hook'."
    (hl-line-mode 1)
    (ibuffer-auto-mode 1))

  (defvar that1guycolin/emacs-load-libs '(bs cl-lib hl-line mouse seq subr-x)
    "List of optional Emacs libraries to load at Emacs start.")

;;;; use-package
  :bind (("C-TAB"   . completion-at-point)
         ("C-c C-x" . toggle-frame-maximized)
         ("C-c ("   . that1guycolin/check-parens-with-message)
         ("C-c #"   . display-line-numbers-mode)
         ("C-c C-#" . global-display-line-numbers-mode)
         ("C-c C-$" . restart-emacs)
         ("M-0"     . that1guycolin/toggle-side-window))
  :bind-keymap ("C-c e"   . that1guycolin/elpaca-options-map)
  :hook (after-save . that1guycolin/untabify-when-no-tab-mode)
  :functions (ibuffer-auto-mode)
  :init
  (setq
   font-use-system-font t)
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  (dolist (lib that1guycolin/emacs-load-libs)
    (require lib))
  :custom
  (auto-save-visited-interval 60)
  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (read-extended-command-predicate #'command-completion-default-include-p)
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (trusted-content
   (list (expand-file-name "early-init.el" user-emacs-directory)
         (expand-file-name "init.el" user-emacs-directory)))
  :config
  (abbrev-mode 1)
  (auto-save-visited-mode 1)
  (context-menu-mode 1)
  (global-display-fill-column-indicator-mode 1)
  (which-key-mode 1)
  (if (>= (string-to-number emacs-version) 31)
      (dolist (elfile (directory-files user-lisp-directory t "\\.el\\'"))
        (add-to-list 'trusted-content elfile))
    (dolist (fl (directory-files
                 (expand-file-name "site-lisp" user-emacs-directory)
                 t "\\.el\\'"))
      (add-to-list 'trusted-content fl)))
  (add-hook 'ibuffer-mode-hook #'that1guycolin/ibuffer-hook-functions))


(provide 'b-emacs)
;;; b-emacs.el ends here
