;;; user-interface-config.el --- Emacs user configuration for dashboard & other visual settings -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for the Emacs user workspace, including the startup screen
;; (dashboard), file navigation (ranger, treemacs), completion UI
;; (corfu, vertico, orderless, marginalia), snippets (yasnippet),
;; terminal emulator (mistty), and Dired extensions.

;;; Packages included:
;; adjust-parens, auto-complete, buffer-terminator, cape, corfu, dashboard,
;; dired-efap, diredfl, dired-narrow, dired-quick-sort, dired-rsync,
;; dired-rsync-transient, dired-video-thumbnail, editorconfig, marginalia,
;; mistty, nerd-icons, nerd-icons-dired, orderless, rainbow-delimiters, ranger,
;; savehist, transient-dwim, vertico, which-key, yasnippet, yasnippet-capf,
;; yasnippet-snippets

;;; Code:
;; Basic look & feel. Theme: 'weyland-yutani', font: 'CommitMonoNerdFontMonos'
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq custom-safe-themes t)

(load-theme 'weyland-yutani t)
(set-face-attribute 'default nil
                    :family "CommitMono Nerd Font Mono"
                    :foundry "NerdFont"
                    :slant 'normal
                    :weight 'regular
                    :height 110
                    :width 'normal)

(use-package nerd-icons
  :demand t)

(use-package dashboard
  :ensure (:repo "that1guycolin/emacs-dashboard" :branch elpaca-integration)
  :demand t
  :functions dashboard-setup-startup-hook
  :custom
  (dashboard-projects-backend 'projectile)
  (dashboard-startup-banner 'logo)
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-set-navigator t)
  (dashboard-navigation-cycle t)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-banner-logo-title "Welcome back")
  (dashboard-items '((bookmarks . 3)
                     (recents  . 7)
                     (projects . 5)))
  :config
  (dashboard-setup-startup-hook))

;; 'transient-dwim' (transient buffer by context)
(use-package transient-dwim
  :ensure t
  :bind ("M-=" . transient-dwim-dispatch))

;; Dired as 'ranger' (file explorer) w/ extensions.
(use-package ranger
  :demand t)

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package diredfl
  :hook (dired-mode . diredfl-mode))

(use-package dired-efap
  :bind (:map dired-mode-map
	      ("<f2>" . dired-efap)
	      ("<down-mouse-1>" . dired-efap-click)))

(use-package dired-rsync
  :bind (:map dired-mode-map
              ("C-c C-r" . dired-rsync)))

(use-package dired-rsync-transient
  :bind (:map dired-mode-map
              ("C-c C-x" . dired-rsync-transient)))

(use-package dired-video-thumbnail
  :bind (:map dired-mode-map
              ("C-t v" . dired-video-thumbnail)))

(use-package dired-narrow
  :commands (dired-narrow dired-narrow-regexp dired-narrow-fuzzy))

(use-package dired-quick-sort
  :demand t
  :functions dired-quick-sort-setup
  :config
  (dired-quick-sort-setup))

;; Colored bracket support
(use-package rainbow-delimiters
  :hook (elpaca-after-init . rainbow-delimiters-mode))

;; Completions:
;; 'corfu' (inline completion), 'vertigo' (minibuffer completions),
;; 'savehist' (history across sessions), 'orderless' (fuzzy matching),
;; 'marginalia' - rich annotations.
(use-package corfu
  :demand t
  :functions (global-corfu-mode corfu-history-mode corfu-popupinfo-mode)
  :custom
  (corfu-cycle t)
  (corfu-quit-at-boundary nil)
  (corfu-on-exact-match 'insert)
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode))

(use-package cape
  :demand t
  :bind ("C-c p" . cape-prefix-map)
  :functions (cape-dabbrev cape-file cape-elisp-block cape-history)
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-hook 'completion-at-point-functions #'cape-history))

(use-package vertico
  :demand t
  :functions vertico-mode
  :init
  (vertico-mode)
  :custom
  (vertico-resize t)
  (vertico-cycle t))

(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (completion-category-defaults nil))

(use-package savehist
  :ensure nil
  :demand t)

(use-package marginalia
  :bind
  ((:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
   (:map completion-list-mode-map
         ("M-A" . marginalia-cycle)))
  :functions marginalia-mode
  :init
  (marginalia-mode))

;; Snippets
;; 'yasnippet' (functions), 'yasnippet-snippets' (library),
;; 'yasnippet-capf' (completions)
(use-package yasnippet
  :demand t
  :functions (yas-global-mode yas-reload-all)
  :custom
  (add-to-list 'yasnippet-snippets-dirs
               '(expand-file-name "snippets" user-emacs-directory))
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet
  :demand t)

(use-package yasnippet-capf
  :after (cape yasnippet)
  :demand t
  :functions yasnippet-capf
  :config
  (add-to-list 'completion-at-point-functions #'yasnippet-capf))

;; Use shell: 'MisTTY'
(use-package mistty
  :bind (("C-c s" . mistty)
         (:map mistty-prompt-map
               ("M-<up>" . mistty-send-key)
               ("M-<down>" . mistty-send-key)
               ("M-<left>" . mistty-send-key)
               ("M-<right>" . mistty-send-key))))

;; Basic
(use-package editorconfig
  :hook (projectile-mode . editorconfig-mode))

(use-package which-key
  :hook (elpaca-after-init . which-key-mode))

(use-package auto-complete
  :demand t)

(use-package adjust-parens
  :bind ("C-c M-p" . adjust-parens-mode))

(use-package buffer-terminator
  :ensure t
  :demand t
  :custom
  (buffer-terminator-verbose nil)
  ;; Time in seconds, modify middle number (minutes).
  ;; Time buffer needs to be inactive to trigger close.
  (buffer-terminator-inactivity-timeout (* 3 60))
  ;; Freqency of sweeps.
  (buffer-terminator-interval (* 5 60))
  (buffer-terminator-mode 1))

;; Helpful changes to emacs (suggested by 'corfu' and 'verigo').
(keymap-global-unset "C-z")
(keymap-global-unset "C-c C-f")
(use-package emacs
  :ensure nil
  :bind
  (("C-z"     . shell)
   ("C-c x"   . toggle-frame-maximized)
   ("C-c ("   . check-parens)
   ("C-c n"   . display-line-numbers-mode)
   ("C-c C-n" . global-display-line-numbers-mode)
   ("C-c r"   . restart-emacs))
  :custom
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (context-menu-mode t)
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))


(provide 'user-interface-config)
;;; user-interface-config.el ends here
