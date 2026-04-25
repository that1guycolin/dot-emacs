;;; 03-visual-settings.el --- Core UI configuration -*- lexical-binding: t; -*-

;;; Packages included:
;; minions, nerd-icons, nerd-icons-corfu, tab-line-nerd-icons, which-key

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

;; Fix font displays for various unicode symbols.
(defun user/display-font-symbols-correctly ()
  "Use \"Noto Color Emoji\" to display unicode symbols."
  (dolist (range '((#x1F300 . #x1F5FF)  ;; Misc symbols & pictographs
                   (#x1F600 . #x1F64F)  ;; Emoticons
                   (#x1F680 . #x1F6FF)  ;; Transport & map
                   (#x1F900 . #x1F9FF))) ;; Supplemental symbols
    (set-fontset-font t range "Noto Color Emoji" nil 'append)))
(add-hook 'after-setting-font-hook #'user/display-font-symbols-correctly)


(provide '03-visual-settings)
;;; 03-visual-settings.el ends here
