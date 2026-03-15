;;; 03-visual-settings.el --- Core UI configuration -*- lexical-binding: t; -*-

;;; Packages included:
;; minions, nerd-icons, nerd-icons-corfu, tab-line-nerd-icons

;;; Themes included:
;; ancient-one-dark, caroline, curry-on, dakrone, darkokai, dream, edna,
;; evangelion, fantom, foggy-night, gotham, iceberg, idea-darkula, madhat2r,
;; material, miasma, monokai-alt, morrowind, night-owl, nordic-night, nord,
;; oblivion, obsidian, overcast, planet, purple-haze, rebecca, reykjavik,
;; simplicity, starlit, vscode-dark-plus, weyland-yutani, zerodark

;;; Commentary:
;; Core UI elements that provide visual feedback and interaction.

;;; Code:
;; =======  ICONS  =======
;; font: `CommitMonoNFM'
;; icons: `nerd-icons'
;; =======================
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(when (member "CommitMono Nerd Font Mono" (font-family-list))
  (set-face-attribute 'default nil
                      :family "CommitMono Nerd Font Mono"
                      :foundry "NerdFont"
                      :slant 'normal
                      :weight 'regular
                      :height 110
                      :width 'normal))

(use-package nerd-icons
  :functions nerd-icons-install-fonts
  :config
  (unless (member "Symbols Nerd Font Mono" (font-family-list))
    (when (window-system)
      (nerd-icons-install-fonts t))))

(use-package tab-line-nerd-icons
  :functions tab-line-nerd-icons-global-mode
  :config
  (tab-line-nerd-icons-global-mode 1))

(defvar corfu-margin-formatters)
(use-package nerd-icons-corfu
  :config
  (add-to-list 'corfu-margin-formatters 'nerd-icons-corfu-formatter))

(use-package minions
  :functions minions-mode
  :config
  (minions-mode 1)
  (add-to-list 'minions-prominent-modes 'flycheck-mode)
  (add-to-list 'minions-prominent-modes 'lsp-mode))

;; Which-key needs to load before a lot of other editor functions,
;; which is why it's invoked here.
(use-package which-key
  :config
  (which-key-mode 1))

;; =======  THEMES  =======
;; Initial theme: `weyland-yutani'
;; ========================
(defvar elpaca-builds-directory)
(defvar user/theme-list nil
  "A list of themes in \='elpaca-builds-directory\=' available to be loaded.")
(use-package weyland-yutani-theme)
(add-to-list 'custom-theme-load-path
             (expand-file-name "weyland-yutani-theme" elpaca-builds-directory))
(add-hook 'elpaca-after-init-hook
	  (lambda ()
	    (setq custom-safe-themes t)
	    (load-theme 'weyland-yutani t)
	    (add-to-list 'user/theme-list 'weyland-yutani)))


(provide '03-visual-settings)
;;; 03-visual-settings.el ends here
