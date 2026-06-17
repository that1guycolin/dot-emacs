;;; 03-visual-settings.el --- Core UI configuration -*- lexical-binding: t; -*-

;;; Packages included:

;;; Packages included:
;; editorconfig, ef-themes, folding-mode, minions, modus-themes, nerd-icons,
;; nerd-icons-corfu, tab-line-nerd-icons, visual-fill-column

;;; Commentary:
;; Core UI elements that provide visual feedback and interaction.

;;; Code:
;; Start fullscreen.
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq font-use-system-font t)

;; =======  THEMES  =======
;; `modus-themes' (Collection of readable Emacs' themes)
;; `ef-themes' (Additional & enhanced Emacs' themes)
;; ========================
(use-package modus-themes
  :demand t
  :functions
  modus-themes-include-derivatives-mode modus-themes-load-random-dark
  modus-themes-select-dark modus-themes-load-random modus-themes-rotate)

(use-package ef-themes
  :demand t
  :preface
  ;; This keymap is bound in 15-user-functions.el.
  (defvar-keymap user/theme-functions
    :prefix t
    :doc "Functions to change the theme."
    "s" #'modus-themes-select-dark
    "r" #'modus-themes-load-random-dark
    "n" #'modus-themes-rotate)
  :init
  (modus-themes-include-derivatives-mode 1)
  :custom
  (modus-themes-mixed-fonts t)
  (modus-themes-italic-constructs t)
  :config
  (modus-themes-load-random 'dark))


;; =======  ICONS  =======
;; `nerd-icons' (icons)
;; `tab-line-nerd-icons' (nerd-icons in tab-line)
;; `nerd-icons-corfu' (nerd-icons in corfu)
;; =======================
(use-package nerd-icons
  :demand t
  :functions nerd-icons-install-fonts
  :config
  (when (and (not (member "Symbols Nerd Font Mono" (font-family-list)))
	     (window-system))
    (nerd-icons-install-fonts t)))

(use-package tab-line-nerd-icons
  :after nerd-icons
  :functions tab-line-nerd-icons-global-mode
  :config
  (tab-line-nerd-icons-global-mode 1))

(use-package nerd-icons-corfu
  :after nerd-icons
  :preface (defvar corfu-margin-formatters)
  :config
  (add-to-list 'corfu-margin-formatters 'nerd-icons-corfu-formatter))


;; =======  MODELINE  =======
;; `minons' (declutter modeline w/ menu for minor-modes)
;; ==========================
(use-package minions
  :demand t
  :functions minions-mode
  :config
  (minions-mode 1))


;; =======  VISUAL LINE  =======
;; `editorconfig' (support .editorconfig)
;; `visual-fill-column' (fill-column for visual-line-mode)
;; =============================
(use-package editorconfig
  :defer t
  :preface
  (defun user/function-for-editorconfig-hook ()
    "Use this as the function to add to *-mode-hook for editorconfig."
    (editorconfig-mode 1))
  :hook ((prog-mode text-mode conf-mode) . user/function-for-editorconfig-hook))

(use-package visual-fill-column
  :defer t
  :hook
  ((visual-line-mode               . visual-fill-column-for-vline)
   ((prog-mode text-mode conf-mode) . visual-line-mode)))

(use-package hideshow
  :ensure nil
  :defer t
  :preface
  (defun user/hideshow-toggle-fold ()
    "Reliably toggle folding on the current block by jumping to EOL first."
    (interactive)
    (save-excursion
      (end-of-line)
      (hs-toggle-hiding)))
  :hook (prog-mode . hs-minor-mode)
  :bind (:map hs-minor-mode-map
	      ("C-c TAB" . user/hideshow-toggle-fold)
	      ("C-c M-h" . hs-hide-all)
	      ("C-c M-s" . hs-show-all)))



(provide '03-visual-settings)
;;; 03-visual-settings.el ends here
