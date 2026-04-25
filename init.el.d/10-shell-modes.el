;;; 10-shell-modes.el --- Support for terminal and Emacs' shells -*- lexical-binding: t; -*-

;;; Packages included:
;;

;;; Commentary:
;; Support in Emacs for various shell buffers.  The packages in this file
;; support either linux native terminal shells or the Emacs native eshell.

;;; Code:
;; =======  TERMINAL SHELLS  =======
;; `mistty' (commit shell layer)
;; `vterm' (fully functional terminal shell)
;; `ghostel' (terminal shell based on libghostty)
;; =================================
(use-package mistty
  :defer t
  :bind ("C-c S m" . mistty)
  :functions mistty-send-key
  :defines mistty-prompt-map
  :config
  (bind-keys
   :map mistty-prompt-map
   ("M-<up>" . mistty-send-key)
   ("M-<down>" . mistty-send-key)
   ("M-<left>" . mistty-send-key)
   ("M-<right>" . mistty-send-key)))

(use-package vterm
  :defer t
  :bind
  (("C-c S v" . vterm)
   ("C-c S V" . vterm-other-window)))

(use-package ghostel
  :ensure (ghostel
	   :source nil
	   :package "ghostel"
	   :id ghostel
	   :fetcher github
	   :repo "dakra/ghostel"
	   :files (:defaults "README.md" "etc" "src" "vendor" "build.zig"
			     "build.zig.zon" "symbols.map" ("build" "Makefile"))
	   :type git
	   :protocol https
	   :inherit t
	   :depth treeless)
  :defer t
  :bind
  (("C-c S g" . ghostel)
   ("C-c S p" . ghostel-project))
  :custom
  (ghostel-module-auto-install 'compile))


;; =======  ESHELL  =======
;; `eshell-syntax-highlighting' (syntax-hl)
;; `esh-autosuggest' (fish-like history-based suggestions)
;; `eshell-git-prompt' (themed prompt)
;; `esh-help' (display help like in .el buffer)
;; ========================
(keymap-global-set "C-c S e" #'eshell)

(use-package eshell-syntax-highlighting
  :defer t
  :hook (eshell-mode . eshell-syntax-highlighting-global-mode))

(use-package esh-autosuggest
  :defer t
  :hook (eshell-mode . esh-autosuggest-mode))

(use-package eshell-git-prompt
  :after esh-opt
  :functions eshell-git-prompt-use-theme
  :config
  (eshell-git-prompt-use-theme 'multiline2))

(declare-function helpful-callable "helpful")
(use-package esh-help
  :after esh-opt
  :functions
  setup-esh-help-eldoc esh-help-run-help user/esh-help-run-help-advice

  :init
  (setup-esh-help-eldoc)
  :config
  (require 'cl-lib)
  (defun user/esh-help-run-help-advice (orig-fn cmd)
    "Use `helpful-callable' instead of `describe-function' in ORIG-FN."
    (cl-letf (((symbol-function #'describe-function) #'helpful-callable))
      (funcall orig-fn cmd)))
  (advice-add #'esh-help-run-help :around #'user/esh-help-run-help-advice)

  (bind-keys
   :map eshell-mode-map
   ("C-c C-h" . esh-help-run-help)))


;; =======  HELPER  =======
;; `with-editor' (set envar EDITOR to current Emacs session)
;; ========================
(use-package with-editor
  :hook
  ((shell-mode  . with-editor-export-editor)
   (eshell-mode . with-editor-export-editor)
   (vterm-mode  . with-editor-export-editor)))

(use-package native-complete
  :defer t
  :commands native-complete-at-point
  :config
  (add-hook 'shell-mode-hook
	    (lambda ()
	      (add-to-list 'completion-at-point-functions
			   #'native-complete-at-point))))

(provide '10-shell-modes)
;;; 10-shell-modes.el ends here
