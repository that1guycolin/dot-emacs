;;; 03-visual.el --- Core UI configuration -*- lexical-binding: t; -*-

;;; Packages included:
;; dashboard, ef-themes, inhibit-mouse, minions, modus-themes, nerd-icons,
;; nerd-icons-corfu, popper, show-font, tab-line-nerd-icons,
;; treemacs-nerd-icons, visual-fill-column

;;; Commentary:
;; Define the user-interface.  In the case of this configuration, start with
;; some functional, yet beautiful themes, go heavy on the nerd-icons, and finish
;; off with a dashboard to greet you every time you open Emacs or a new
;; server-frame.

;;; Code:
;;; Themes & Icons:
;; Readable Emacs' themes
(use-package modus-themes
  :demand t
  :functions (modus-themes-include-derivatives-mode
              modus-themes-load-random-dark modus-themes-load-random))

;; Enhanced themes
(use-package ef-themes
  :demand t
  :init (modus-themes-include-derivatives-mode 1)
  :custom
  (modus-themes-mixed-fonts t)
  (modus-themes-italic-constructs t)
  :config (modus-themes-load-random 'dark))

;; Icons
(use-package nerd-icons
  :demand t
  :functions (nerd-icons-install-fonts)
  :config (when (and (not (member "Symbols Nerd Font Mono" (font-family-list)))
                     (window-system))
            (nerd-icons-install-fonts t)))

(use-package tab-line-nerd-icons
  :after (nerd-icons)
  :demand t
  :functions (tab-line-nerd-icons-global-mode)
  :config (tab-line-nerd-icons-global-mode 1))

(use-package nerd-icons-corfu
  :after (nerd-icons corfu)
  :demand t
  :preface (defvar corfu-margin-formatters)
  :config (add-to-list 'corfu-margin-formatters 'nerd-icons-corfu-formatter))

(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :demand t
  :functions (treemacs-nerd-icons-config)
  :config (treemacs-nerd-icons-config))

;; DON'T MOVE THE MOUSE!
(use-package inhibit-mouse
  :demand t
  :preface
  (defun that1guycolin/inhibit-inhibit-mouse ()
    "Deactivate `inhibit-mouse-mode'.
Effective as hook for major-modes where you want to be able to use the mouse."
    (interactive)
    (inhibit-mouse-mode -1))
  :unless (eq system-type 'android)
  :bind ("C-c C-M-m" . inhibit-mouse-mode)
  :custom
  (inhibit-mouse-adjust-mouse-highlight t)
  (inhibit-mouse-adjust-show-help-function t)
  :config
  (if (daemonp)
      (add-hook 'server-after-make-frame-hook
                #'that1guycolin/inhibit-inhibit-mouse)
    (inhibit-mouse-mode 1))
  (add-hook 'Info-mode-hook #'that1guycolin/inhibit-inhibit-mouse)
  (add-hook 'org-mode-hook #'that1guycolin/inhibit-inhibit-mouse))

;; Madeline:
(use-package minions
  :demand t
  :functions (minions-mode)
  :config (minions-mode 1))

;; Hide (but easily unhide) certain buffers
(use-package popper
  :demand t
  :preface (keymap-global-unset "M-'")
  :bind (("C-'"   . popper-toggle)
         ("M-'"   . popper-cycle)
         ("C-M-'" . popper-toggle-type))
  :functions (popper-mode popper-echo-mode)
  :custom (popper-reference-buffers
           '("\\*Messages\\*" "Output\\*$" "\\*Async Shell Command\\*" help-mode
             helpful-mode compilation-mode "^\\*vterm.*\\*$" vterm-mode
             "^\\*eat.*\\*$" eat-mode free-keys-mode))
  :config
  (popper-mode +1)
  (popper-echo-mode +1))

;; Line-length:
(use-package visual-fill-column
  :preface
  (defvar that1guycolin/mode-fill-column-alist
    '((bash-ts-mode           . 80)    (c-ts-mode              . 100)
      (c++-ts-mode            . 100)   (cmake-ts-mode          . 100)
      (conf-toml-mode         . 0)     (css-mode               . 80)
      (css-ts-mode            . 80)    (csv-mode               . 0)
      (dashboard-mode         . 0)     (emacs-lisp-mode        . 80)
      (fish-mode              . 80)    (dockerfile-ts-mode     . 100)
      (geiser-repl-mode       . 0)     (glsl-mode              . 100)
      (go-ts-mode             . 80)    (ini-mode               . 100)
      (java-ts-mode           . 100)   (js-json-mode           . 80)
      (json-ts-mode           . 80)    (js-ts-mode             . 100)
      (just-ts-mode           . 100)   (kdl-mode               . 100)
      (lisp-mode              . 80)    (lua-ts-mode            . 100)
      (makefile-mode          . 100)   (markdown-ts-mode       . 80)
      (nxml-mode              . 0)     (python-mode            . 88)
      (python-ts-mode         . 88)    (rustic-mode            . 100)
      (rust-ts-mode           . 100)   (scheme-mode            . 80)
      (sh-mode                . 80)    (sly-mrepl-mode         . 0)
      (systemd-mode           . 100)   (telega-root-mode       . 100)
      (toml-ts-mode           . 0)     (typescript-ts-mode     . 80)
      (yaml-ts-mode           . 0))
    "Alist mapping major-modes to their default `fill-column' value.")

  (defun that1guycolin/display-max-line-length (max)
    "Set `fill-column' to MAX.
Also toggle `auto-fill-mode', `display-fill-column-indicator-mode', and
`visual-line-mode'."
    
    (setq-local fill-column max)
    (auto-fill-mode 1)
    (display-fill-column-indicator-mode 1)
    (visual-line-mode 1))

  (defun that1guycolin/no-display-line-length ()
    "Untoggle `minor-modes' that aid in the display of max line-length.
Function also sets `fill-column' to 1000."
    (setq-local fill-column 1000)
    (auto-fill-mode -1)
    (display-fill-column-indicator-mode -1)
    (visual-line-mode -1))

  (defun that1guycolin/auto-set-fill-column ()
    "Check if `major-mode' is in `that1guycolin/mode-fill-column-alist'.
If yes, toggle display of max line-length depending on whether value its
cdr is 0 or a positive integer. If not a member of the list, run
`that1guycolin/display-max-line-length' using 80 as the \='max'
argument."
    (interactive)
    (if (member major-mode (mapcar #'car that1guycolin/mode-fill-column-alist))
        (let ((fc (cdr (assoc major-mode
                              that1guycolin/mode-fill-column-alist))))
          (if (= fc 0)
              (that1guycolin/no-display-line-length)
            (that1guycolin/display-max-line-length fc)))
      (that1guycolin/display-max-line-length 80)))
  :demand t
  :hook (visual-line-mode . visual-fill-column-for-vline)
  :functions (visual-line-mode visual-fill-column-for-vline)
  :init (add-hook 'find-file-hook #'that1guycolin/auto-set-fill-column))


;;; Font:
(use-package default-font-presets
  :demand t
  :preface
  (defvar that1guycolin/keep-frame-size-on-font-switch-p t
    "If non-nil, attempt to keep frame size fixed when changing font.
If nil, the number of frame lines and columns remains fixed.")

  (defun that1guycolin/random-font ()
    "Activate a random font from `that1guycolin/font-alist'."
    (interactive)
    (let ((new-font (nth (random (length default-font-presets-list))
                         default-font-presets-list)))
      (set-frame-font new-font that1guycolin/keep-frame-size-on-font-switch-p t t)
      (message "Font set to %s" new-font)))

  (defun that1guycolin/set-font-size-behaviour (input)
    "Prompt the user for INPUT on handling frame resizing when switching font."
    (declare (interactive-only t))
    (interactive
     (let ((frame-resizing-cons
            (if that1guycolin/keep-frame-size-on-font-switch-p
                '(("Attempt to keep frame size fixed (current)" . t)
                  ("Keep # of frame lines and columns fixed"    . nil))
              '(("Attempt to keep frame size fixed"                  . t)
                ("Keep # of frame lines and columns fixed (current)" . nil )))))
       (list
        (cdr
         (assoc
          (completing-read "How to handle frame-size when switching fonts: "
                           frame-resizing-cons nil t)
          frame-resizing-cons)))))
    (setq that1guycolin/keep-frame-size-on-font-switch-p input))

  :unless (eq system-type 'android)
  :bind (("C-=" . default-font-presets-scale-increase)
         ("C--" . default-font-presets-scale-decrease)
         ("C-0" . default-font-presets-scale-reset)
         ("M-<up>" . default-font-presets-forward)
         ("M-<down>" . default-font-presets-backward))
  :custom
  (default-font-presets-list
   (list
    "0x Proto Nerd Font"
    "0x Proto Nerd Font Mono"
    "0x Proto Nerd Font Propo"
    "3270 Nerd Font"
    "3270 Nerd Font Mono"
    "3270 Nerd Font Propo"
    "Adwaita Mono Nerd Font"
    "Adwaita Mono Nerd Font Mono"
    "Adwaita Mono Nerd Font Propo"
    "Agave Nerd Font"
    "Agave Nerd Font Mono"
    "Agave Nerd Font Propo"
    "Anonymice Pro Nerd Font"
    "Anonymice Pro Nerd Font Mono"
    "Anonymice Pro Nerd Font Propo"
    "Arimo Nerd Font"
    "Arimo Nerd Font Propo"
    "Big Blue Term437 Nerd Font"
    "Big Blue Term437 Nerd Font Mono"
    "Big Blue Term437 Nerd Font Propo"
    "Big Blue Term Plus Nerd Font"
    "Big Blue Term Plus Nerd Font Mono"
    "Big Blue Term Plus Nerd Font Propo"
    "Bitstrom Wera Nerd Font"
    "Bitstrom Wera Nerd Font Mono"
    "Bitstrom Wera Nerd Font Propo"
    "Blex Mono Nerd Font"
    "Blex Mono Nerd Font Mono"
    "Blex Mono Nerd Font Propo"
    "Caskaydia Cove Nerd Font"
    "Caskaydia Cove Nerd Font Mono"
    "Caskaydia Cove Nerd Font Propo"
    "Caskaydia Mono Nerd Font"
    "Caskaydia Mono Nerd Font Mono"
    "Caskaydia Mono Nerd Font Propo"
    "Cousine Nerd Font"
    "Cousine Nerd Font Mono"
    "Cousine Nerd Font Propo"
    "D2 Koding Ligature Nerd Font"
    "D2 Koding Ligature Nerd Font Mono"
    "D2 Koding Ligature Nerd Font Propo"
    "Daddy Time Mono Nerd Font"
    "Daddy Time Mono Nerd Font Mono"
    "Daddy Time Mono Nerd Font Propo"
    "Deja Vu Sans M Nerd Font"
    "Deja Vu Sans M Nerd Font Mono"
    "Deja Vu Sans M Nerd Font Propo"
    "Envy Code R Nerd Font"
    "Envy Code R Nerd Font Mono"
    "Envy Code R Nerd Font Propo"
    "Fantasque Sans M Nerd Font"
    "Fantasque Sans M Nerd Font Mono"
    "Fantasque Sans M Nerd Font Propo"
    "Fira Code Nerd Font"
    "Fira Code Nerd Font Mono"
    "Fira Code Nerd Font Propo"
    "Gohu Font11 Nerd Font"
    "Gohu Font11 Nerd Font Mono"
    "Gohu Font11 Nerd Font Propo"
    "Gohu Font14 Nerd Font"
    "Gohu Font14 Nerd Font Mono"
    "Gohu Font14 Nerd Font Propo"
    "Gohu Fontuni11 Nerd Font"
    "Gohu Fontuni11 Nerd Font Mono"
    "Gohu Fontuni11 Nerd Font Propo"
    "Gohu Fontuni14 Nerd Font"
    "Gohu Fontuni14 Nerd Font Mono"
    "Gohu Fontuni14 Nerd Font Propo"
    "Go Mono Nerd Font"
    "Go Mono Nerd Font Mono"
    "Go Mono Nerd Font Propo"
    "Hack Nerd Font"
    "Hack Nerd Font Mono"
    "Hack Nerd Font Propo"
    "Heavy Data Nerd Font"
    "Heavy Data Nerd Font Propo"
    "i M Writing Duo Nerd Font"
    "i M Writing Duo Nerd Font Propo"
    "i M Writing Mono Nerd Font"
    "i M Writing Mono Nerd Font Mono"
    "i M Writing Mono Nerd Font Propo"
    "i M Writing Quat Nerd Font"
    "i M Writing Quat Nerd Font Propo"
    "Inconsolata Go Nerd Font"
    "Inconsolata Go Nerd Font Mono"
    "Inconsolata Go Nerd Font Propo"
    "Inconsolata LGC Nerd Font"
    "Inconsolata LGC Nerd Font Mono"
    "Inconsolata LGC Nerd Font Propo"
    "Inconsolata Nerd Font"
    "Inconsolata Nerd Font Mono"
    "Inconsolata Nerd Font Propo"
    "Intone Mono Nerd Font"
    "Intone Mono Nerd Font Mono"
    "Intone Mono Nerd Font Propo"
    "Iosevka Nerd Font"
    "Iosevka Nerd Font Mono"
    "Iosevka Nerd Font Propo"
    "Iosevka Term Nerd Font"
    "Iosevka Term Nerd Font Mono"
    "Iosevka Term Nerd Font Propo"
    "Iosevka Term Slab Nerd Font"
    "Iosevka Term Slab Nerd Font Mono"
    "Iosevka Term Slab Nerd Font Propo"
    "Jet Brains Mono Nerd Font"
    "Jet Brains Mono Nerd Font Mono"
    "Jet Brains Mono Nerd Font Propo"
    "Jet Brains Mono NL Nerd Font"
    "Jet Brains Mono NL Nerd Font Mono"
    "Jet Brains Mono NL Nerd Font Propo"
    "Lekton Nerd Font"
    "Lekton Nerd Font Mono"
    "Lekton Nerd Font Propo"
    "Lilex Nerd Font"
    "Lilex Nerd Font Mono"
    "Lilex Nerd Font Propo"
    "Literation Mono Nerd Font"
    "Literation Mono Nerd Font Mono"
    "Literation Mono Nerd Font Propo"
    "Literation Sans Nerd Font"
    "Literation Sans Nerd Font Propo"
    "Literation Serif Nerd Font"
    "Literation Serif Nerd Font Propo"
    "M+1 Code Nerd Font"
    "M+1 Code Nerd Font Mono"
    "M+1 Code Nerd Font Propo"
    "M+1 Nerd Font"
    "M+1 Nerd Font Propo"
    "M+2 Nerd Font"
    "M+2 Nerd Font Propo"
    "Martian Mono Nerd Font"
    "Martian Mono Nerd Font Mono"
    "Martian Mono Nerd Font Propo"
    "M+Code Lat50 Nerd Font"
    "M+Code Lat50 Nerd Font Mono"
    "M+Code Lat50 Nerd Font Propo"
    "M+Code Lat60 Nerd Font"
    "M+Code Lat60 Nerd Font Mono"
    "M+Code Lat60 Nerd Font Propo"
    "Meslo LGLDZ Nerd Font"
    "Meslo LGLDZ Nerd Font Mono"
    "Meslo LGLDZ Nerd Font Propo"
    "Meslo LGL Nerd Font"
    "Meslo LGL Nerd Font Mono"
    "Meslo LGL Nerd Font Propo"
    "Meslo LGMDZ Nerd Font"
    "Meslo LGMDZ Nerd Font Mono"
    "Meslo LGMDZ Nerd Font Propo"
    "Meslo LGM Nerd Font"
    "Meslo LGM Nerd Font Mono"
    "Meslo LGM Nerd Font Propo"
    "Meslo LGSDZ Nerd Font"
    "Meslo LGSDZ Nerd Font Mono"
    "Meslo LGSDZ Nerd Font Propo"
    "Meslo LGS Nerd Font"
    "Meslo LGS Nerd Font Mono"
    "Meslo LGS Nerd Font Propo"
    "Monofur Nerd Font"
    "Monofur Nerd Font Mono"
    "Monofur Nerd Font Propo"
    "Monoid Nerd Font"
    "Monoid Nerd Font Mono"
    "Monoid Nerd Font Propo"
    "Mononoki Nerd Font"
    "Mononoki Nerd Font Mono"
    "Mononoki Nerd Font Propo"
    "Noto Mono Nerd Font"
    "Noto Mono Nerd Font Mono"
    "Noto Mono Nerd Font Propo"
    "Noto Sans M Nerd Font"
    "Noto Sans M Nerd Font Mono"
    "Noto Sans M Nerd Font Propo"
    "Noto Sans Nerd Font"
    "Noto Sans Nerd Font Propo"
    "Noto Serif Nerd Font"
    "Noto Serif Nerd Font Propo"
    "Pro Font I Ix Nerd Font"
    "Pro Font I Ix Nerd Font Mono"
    "Pro Font I Ix Nerd Font Propo"
    "Pro Font Windows Nerd Font"
    "Pro Font Windows Nerd Font Mono"
    "Pro Font Windows Nerd Font Propo"
    "Proggy Clean CE Nerd Font"
    "Proggy Clean CE Nerd Font Mono"
    "Proggy Clean CE Nerd Font Propo"
    "Proggy Clean Nerd Font"
    "Proggy Clean Nerd Font Mono"
    "Proggy Clean Nerd Font Propo"
    "Proggy Clean SZ Nerd Font"
    "Proggy Clean SZ Nerd Font Mono"
    "Proggy Clean SZ Nerd Font Propo"
    "Rec Mono Casual Nerd Font"
    "Rec Mono Casual Nerd Font Mono"
    "Rec Mono Casual Nerd Font Propo"
    "Rec Mono Duotone Nerd Font"
    "Rec Mono Duotone Nerd Font Mono"
    "Rec Mono Duotone Nerd Font Propo"
    "Rec Mono Linear Nerd Font"
    "Rec Mono Linear Nerd Font Mono"
    "Rec Mono Linear Nerd Font Propo"
    "Rec Mono Sm Casual Nerd Font"
    "Rec Mono Sm Casual Nerd Font Mono"
    "Rec Mono Sm Casual Nerd Font Propo"
    "Roboto Mono Nerd Font"
    "Roboto Mono Nerd Font Mono"
    "Roboto Mono Nerd Font Propo"
    "Sauce Code Pro Nerd Font"
    "Sauce Code Pro Nerd Font Mono"
    "Sauce Code Pro Nerd Font Propo"
    "Shure Tech Mono Nerd Font"
    "Shure Tech Mono Nerd Font Mono"
    "Shure Tech Mono Nerd Font Propo"
    "Space Mono Nerd Font"
    "Space Mono Nerd Font Mono"
    "Space Mono Nerd Font Propo"
    "Symbols Nerd Font"
    "Symbols Nerd Font Mono"
    "Terminess Nerd Font"
    "Terminess Nerd Font Mono"
    "Terminess Nerd Font Propo"
    "Tinos Nerd Font"
    "Tinos Nerd Font Propo"
    "Ubuntu Mono Nerd Font"
    "Ubuntu Mono Nerd Font Mono"
    "Ubuntu Mono Nerd Font Propo"
    "Ubuntu Nerd Font"
    "Ubuntu Nerd Font Propo"
    "Victor Mono Nerd Font"
    "Victor Mono Nerd Font Mono"
    "Victor Mono Nerd Font Propo"
    "Zed Mono Nerd Font"
    "Zed Mono Nerd Font Mono"
    "Zed Mono Nerd Font Propo")))

;; preview fonts prior to selection
(use-package show-font
  :defer t
  :commands (show-font-select-preview show-font-tabulated))

;;; Custom visual transient
(with-eval-after-load 'transient
  (declare-function transient-define-prefix "transient")
  (defvar that1guycolin/visual-settings-dispatch nil)
  (transient-define-prefix
    that1guycolin/visual-settings-dispatch ()
    "Display functions that change how the user-interface looks."
    ["Modify UI"
     ["Fonts"
      ("n" "Next font"           default-font-presets-forward :transient t)
      ("p" "Previous font"       default-font-presets-backward :transient t)
      ("r" "Random font"         that1guycolin/random-font :transient t)
      ("b" "Font size behaviour" that1guycolin/set-font-size-behaviour
       :transient t)
      ("f" "Show Font Family"    show-font-select-preview)
      ("a" "Show Fonts (All)"    show-font-tabulated)]
     ["Theme"
      ("t" "Switch theme"        modus-themes-select)
      ("o" "Rotate theme"        modus-themes-rotate)
      ("l" "Random light theme"  modus-themes-load-random-light :transient t)
      ("d" "Random dark theme"   modus-themes-load-random-dark :transient t)
      ("x" "Random theme"        modus-themes-load-random :transient t)]])
  (keymap-global-set "C-c u" 'that1guycolin/visual-settings-dispatch))


;;; Dashboard:
(use-package dashboard
  :demand t
  :preface
  (defun that1guycolin/dashboard-setup ()
    "Correctly start dashboard during Elpaca-managed init."
    (dashboard-insert-startupify-lists)
    (dashboard-initialize))
  
  :functions (dashboard-insert-startupify-lists
              dashboard-initialize dashboard-setup-startup-hook
              dashboard-refresh-buffer dashboard-display-icons-p)
  :init
  (add-hook 'elpaca-after-init-hook #'that1guycolin/dashboard-setup)
  (setq initial-buffer-choice #'dashboard-refresh-buffer)
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-display-icons-p t)
  (dashboard-set-file-icons t)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-banner-logo-title "Welcome back")
  (dashboard-projects-backend 'project-el)
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-items
        `((projects . ,(length (project-known-project-roots)))
          (recents . 5))))


(provide '03-visual)
;;; 03-visual.el ends here
