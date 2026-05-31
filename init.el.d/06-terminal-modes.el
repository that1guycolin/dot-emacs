;;; 06-terminal-modes.el --- Support for terminal and Emacs' shells -*- lexical-binding: t; -*-

;;; Packages included:
;; eat, esh-autosuggest, eshell, eshell-git-prompt, eshell-syntax-highlighting,
;; esh-help, ghostel, mistty, native-complete, vterm, with-editor

;;; Commentary:
;; Support in Emacs for various shell buffers.  The packages in this file
;; support either linux native terminal shells or the Emacs native eshell.

;;; Code:
;; =======  HELPFUL FUNCTIONS  =======
(defun user/normal-window-p (win)
  "Return non-nil if WIN is a normal, non-side, non-minibuffer window."
  (and (window-live-p win)
       (not (window-minibuffer-p win))
       (not (window-parameter win 'window-side))))

(defun user/get-normal-window ()
  "Return a normal, non-side, non-minibuffer window."
  (get-window-with-predicate #'user/normal-window-p nil t))

(defun user/only-one-non-side-window-p ()
  "Return non-nil if there is only one non-side, non-minibuffer window."
  (= 1 (length (seq-filter #'user/normal-window-p
			   (window-list nil 'no-minibuf)))))

(defun user/call-in-other-window-advice (orig-fn &rest args)
  "Call ORIG-FN (with ARGS) in another normal window, splitting if needed."
  (let ((normal-window (user/get-normal-window)))
    (unless normal-window
      (error "No normal window available"))
    (select-window normal-window)
    (if (user/only-one-non-side-window-p)
	(progn
	  (split-window-right)
	  (other-window 1))
      (other-window 1))
    (apply orig-fn args)))


;; =======  TERMINAL SHELLS  =======
;; `eat' (Emulate A Terminal)
;; `ghostel' (terminal shell based on libghostty)
;; `mistty' (commit shell layer)
;; `vterm' (fully functional terminal shell)
;; =================================
(use-package eat
  :defer t
  :bind ("C-c S e"   . eat)
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
  :bind ("C-c S g" . ghostel)
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
  (("C-c S m" . mistty)
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
  (("C-c S v" . vterm)
   ("C-c S V" . vterm-other-window)))


;; =======  ESHELL  =======
;; `eshell-syntax-highlighting' (syntax-hl)
;; `esh-autosuggest' (fish-like history-based suggestions)
;; `eshell-git-prompt' (themed prompt)
;; `esh-help' (display help like in .el buffer)
;; ========================
(use-package eshell
  :ensure nil
  :defer t
  :preface (advice-add 'eshell :around #'user/call-in-other-window-advice)
  :bind ("C-c S E" . eshell))

(use-package eshell-syntax-highlighting
  :defer t
  :hook (eshell-mode . eshell-syntax-highlighting-global-mode))

(use-package esh-autosuggest
  :defer t
  :hook (eshell-mode . esh-autosuggest-mode))

(use-package eshell-git-prompt
  :after eshell
  :functions eshell-git-prompt-use-theme
  :config
  (eshell-git-prompt-use-theme 'multiline2))

(use-package esh-help
  :after eshell
  :preface
  (declare-function helpful-callable "helpful")
  (defun user/esh-help-run-help-advice (orig-fn cmd)
    "Use `helpful-callable' instead of `describe-function' in ORIG-FN."
    (cl-letf (((symbol-function #'describe-function) #'helpful-callable))
      (funcall orig-fn cmd)))
  (advice-add #'esh-help-run-help :around #'user/esh-help-run-help-advice)
  :bind
  (:map eshell-mode-map
	("C-c C-h" . esh-help-run-help))
  :functions setup-esh-help-eldoc
  :init
  (setup-esh-help-eldoc))


;; =======  HELPER  =======
;; `with-editor' (set envar EDITOR to current Emacs session)
;; ========================
(use-package with-editor
  :defer t
  :hook ((eshell-mode shell-mode vterm-mode) . with-editor-export-editor))

(use-package native-complete
  :ensure (:wait t)
  :defer t
  :preface
  (defun user/setup-native-complete ()
    "Add `native-complete-at-point' to `completion-at-point-functions'."
    (add-to-list 'completion-at-point-functions #'native-complete-at-point))
  :hook (shell-mode . user/setup-native-complete)
  :commands native-complete-at-point)


(provide '06-terminal-modes)
;;; 06-terminal-modes.el ends here
