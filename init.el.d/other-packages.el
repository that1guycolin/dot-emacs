;;; other-packages.el --- Packages that defy categorization -*- lexical-binding: t; -*-

;;; Commentary:
;; These packages either don't fall into an easily defineable category OR
;; they benefit from loading towards the very end of the startup process.

;;; Packages included:
;; buffer-terminator, gcmh, mistty, smartparens, transient-dwim, which-key

;;; Code:
;; Utilities
(use-package which-key
  :hook (emacs-startup . which-key-mode))

(use-package smartparens
  :hook
  ((prog-mode . smartparens-mode)
   (text-mode . smartparens-mode)
   (markdown-mode . smartparens-mode))
  :config
  (require 'smartparens-config))

(use-package transient-dwim
  :bind ("M-=" . transient-dwim-dispatch))

;; Use shell: 'MisTTY'
(use-package mistty
  :bind ("C-c s" . mistty)
  :functions mistty-send-key
  :defines mistty-prompt-map
  :config
  (bind-keys
   :map mistty-prompt-map
   ("M-<up>" . mistty-send-key)
   ("M-<down>" . mistty-send-key)
   ("M-<left>" . mistty-send-key)
   ("M-<right>" . mistty-send-key)))

;; Terminate inactive buffers
(use-package buffer-terminator
  :functions buffer-terminator-mode
  :custom
  (buffer-terminator-verbose nil)
  ;; Time (in seconds), that buffer needs to be inactive to trigger close.
  (buffer-terminator-inactivity-timeout (* 5 60))
  ;; Frequency of sweeps.
  (buffer-terminator-interval (* 3 60))
  :config
  (buffer-terminator-mode 1))

(use-package hydra
  :commands defhydra
  :defer t)

;; garbage collection
(use-package gcmh
  :hook (emacs-startup . gcmh-mode)
  :config
  ;;  (setopt garbage-collection-messages t)
  (setopt gcmh-high-cons-threshold (* 100 1024 1024))
  (setopt gcmh-low-cons-threshold (* 8 1024 1024))
  (setopt gcmh-idle-delay 3)
  (setopt gc-cons-percentage 0.1))

(provide 'other-packages)
;;; other-packages.el ends here