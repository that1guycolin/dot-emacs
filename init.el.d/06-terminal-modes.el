;;; 06-terminal-modes.el --- Support for terminal and Emacs' shells -*- lexical-binding: t; -*-

;;; Packages included:
;; eat, ghostel, mistty, native-complete, vterm, with-editor

;;; Commentary:
;; Support in Emacs for various shell buffers.  The packages in this file
;; support either linux native terminal shells or the Emacs native eshell.

;;; Code:
;;;; =======  HELPFUL FUNCTIONS  =======
(defun user/normal-window-p (win)
  "Return non-nil if WIN is a normal, non-side, non-minibuffer window."
  (and (window-live-p win)
       (not (window-minibuffer-p win))
       (not (window-parameter win 'window-side))))

(defun user/normal-windows ()
  "Return all normal, non-side, non-minibuffer windows."
  (seq-filter #'user/normal-window-p
              (window-list nil 'no-minibuf)))

(defun user/call-in-other-window-advice (orig-fn &rest args)
  "Call ORIG-FN with ARGS in another normal window, splitting if needed."
  (let* ((normal-windows (user/normal-windows))
         (target-window
          (cond
           ((null normal-windows)
            (error "No normal window available"))
           ((= 1 (length normal-windows))
            (split-window (car normal-windows) nil 'right))
           (t
            (seq-find (lambda (win)
                        (not (eq win (selected-window))))
                      normal-windows)))))
    (select-window target-window)
    (apply orig-fn args)))


;;;; =======  TERMINAL SHELLS  =======
;; `eat'         (Emulate A Terminal)
;; `ghostel'     (terminal shell based on libghostty)
;; `mistty'      (commit shell layer)
;; `vterm'       (fully functional terminal shell)
;;   =================================
(use-package eat
  :defer t
  :bind ("C-c s e"   . eat)
  :hook (eshell-mode . eat-eshell-visual-command-mode))

(use-package ghostel
  :ensure (ghostel
           :source nil :package "ghostel" :id ghostel :fetcher github
           :repo "dakra/ghostel"
           :files (:defaults
                   "README.md" "etc" "src" "vendor" "build.zig" "build.zig.zon"
                   "symbols.map" ("build" "Makefile"))
           :type git :protocol https :inherit t :depth treeless)
  :defer t
  :preface (advice-add 'ghostty :around #'user/call-in-other-window-advice)
  :bind ("C-c s g" . ghostel)
  :custom
  (ghostel-module-auto-install 'compile)
  :config
  (with-eval-after-load 'disproject
    (transient-append-suffix 'disproject-dispatch
      "s"
      '("o" "Ghostel" ghostel-project))))

(use-package mistty
  :defer t
  :preface (advice-add 'mistty :around #'user/call-in-other-window-advice)
  :bind
  (("C-c s m" . mistty)
   :map mistty-prompt-map
   ("M-<up>"    . mistty-send-key)
   ("M-<down>"  . mistty-send-key)
   ("M-<left>"  . mistty-send-key)
   ("M-<right>" . mistty-send-key))
  :config
  (with-eval-after-load 'treemacs
    (transient-append-suffix 'user/project-treemacs-anywhere-dispatch
      "C"
      '("M" "MisTTY @ Project root" mistty-in-project))))

(use-package vterm
  :defer t
  :bind
  (("C-c s v" . vterm)
   ("C-c s V" . vterm-other-window)))


;;;; =======  HELPERS  =======
;; `with-editor' (set envar EDITOR to current Emacs session)
;;   =========================
(use-package with-editor
  :defer t
  :hook ((eshell-mode shell-mode vterm-mode) . with-editor-export-editor))

(use-package native-complete
  :defer t
  :preface
  (defun user/setup-native-complete ()
    "Add `native-complete-at-point' to `completion-at-point-functions'."
    (add-to-list 'completion-at-point-functions #'native-complete-at-point))
  :hook (shell-mode . user/setup-native-complete)
  :commands native-complete-at-point)


(provide '06-terminal-modes)
;;; 06-terminal-modes.el ends here
