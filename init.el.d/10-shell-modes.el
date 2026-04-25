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
  :bind ("C-c s m" . mistty)
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
  (("C-c s v" . vterm)
   ("C-c s V" . vterm-other-window)))

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
  (("C-c s g" . ghostel)
   ("C-c s p" . ghostel-project))
  :custom
  (ghostel-module-auto-install 'compile))


;; =======  ESHELL  =======
;; `eshell-syntax-highlighting' (syntax-hl)
;; `esh-autosuggest' (fish-like history-based suggestions)
;; ========================
(keymap-global-set "C-c s e" #'eshell)

(use-package eshell-syntax-highlighting
  :defer t
  :hook (eshell-mode . eshell-syntax-highlighting-global-mode))

(use-package esh-autosuggest
  :defer t
  :hook (eshell-mode . esh-autosuggest-mode))



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
