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
  :demand t
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
      (lisp-mode              . 80)    (lua-ts-mode            . 120)
      (makefile-mode          . 100)   (markdown-ts-mode       . 80)
      (nxml-mode              . 0)     (python-mode            . 88)
      (python-ts-mode         . 88)    (rustic-mode            . 100)
      (rust-ts-mode           . 100)   (scheme-mode            . 80)
      (sh-mode                . 80)    (sly-mrepl-mode         . 0)
      (systemd-mode           . 100)   (telega-root-mode       . 100)
      (toml-ts-mode           . 0)     (typescript-ts-mode     . 80)
      (yaml-ts-mode           . 0))
    "Alist mapping major-modes to their default `fill-column' value.")

  (defun that1guycolin/display-max-line-length (ll)
    "Set `fill-column' to LL.
Also toggle `auto-fill-mode', `display-fill-column-indicator-mode', and
`visual-line-mode'."
    (setq-local fill-column ll)
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
`that1guycolin/display-max-line-length' using 80 as the \\='max'
argument."
    (interactive)
    (if (member major-mode (mapcar #'car that1guycolin/mode-fill-column-alist))
        (let ((fc (cdr (assoc major-mode
                              that1guycolin/mode-fill-column-alist))))
          (if (= fc 0)
              (that1guycolin/no-display-line-length)
            (that1guycolin/display-max-line-length fc)))
      (that1guycolin/display-max-line-length 80)))
  :hook (visual-line-mode . visual-fill-column-for-vline)
  :functions (visual-line-mode visual-fill-column-for-vline)
  :init (add-hook 'find-file-hook #'that1guycolin/auto-set-fill-column))


;;; Font:
;; Packages:
(use-package default-font-presets
  :demand t
  :preface
  (defvar that1guycolin/default-font-presets--idx-fonts-alist nil
    "An alist mapping fonts from `default-font-presets-list' to an index.")

  (defun that1guycolin/default-font-presets-generate-font-index ()
    "(Re)Generate the alist of cons cells mapping fonts to an index number.
Uses `default-font-presets-list' as the backend for what fonts to include."
    (interactive)
    (let ((tmp-list (list))
          (idx 0))
      (dolist (font-name default-font-presets-list)
        (push (cons idx font-name) tmp-list)
        (incf idx))
      (setq
       that1guycolin/default-font-presets--idx-fonts-alist
       (nreverse tmp-list))))

  (defun that1guycolin/default-font-presets--get-font ()
    "Return the current font."
    (unless that1guycolin/default-font-presets--idx-fonts-alist
      (that1guycolin/default-font-presets-generate-font-index))
    (cdr (assoc default-font-presets--index
                that1guycolin/default-font-presets--idx-fonts-alist)))
  
  (defcustom that1guycolin/default-font-presets--font-size nil
    "A human-readable font-size that could be used in a standard office suite.
The Emacs' `font-face' attribute `height' is the font size (this number)
multiplied by 10.  Setting this value directly will nothing, it must be updated
via the function `that1guycolin/default-font-presets-set-size'."
    :type 'integer
    :group 'default-font-presets)
  
  (defun that1guycolin/default-font-presets-set-size (new-size)
    "Set the current font size to NEW-SIZE."
    (interactive
     (list
      (read-number (format "Font Size (Current: %i): "
                           that1guycolin/default-font-presets--font-size))))
    (set-face-attribute
     'default nil :font (concat (that1guycolin/default-font-presets--get-font)
                                "-" (number-to-string new-size)))
    (setf that1guycolin/default-font-presets--font-size new-size))

  (defun that1guycolin/default-font-presets-random-font ()
    "Activate a random font from `default-fonts-presets-list'."
    (interactive)
    (default-font-presets--ensure-once)
    (unless that1guycolin/default-font-presets--idx-fonts-alist
      (that1guycolin/default-font-presets-generate-font-index))
    (let* ((new-cons
            (nth
             (random
              (length that1guycolin/default-font-presets--idx-fonts-alist))
             that1guycolin/default-font-presets--idx-fonts-alist))
           (new-font (cdr new-cons))
           (new-index (car new-cons)))
      (default-font-presets--switch-pre)
      (setq default-font-presets--index new-index)
      (condition-case _err
          (default-font-presets--index-update-on-switch)
        (error nil))
      (message "New Font: %s" new-font)))

  (defun that1guycolin/default-font-presets--new-frame (frame)
    (with-selected-frame frame
      (let ((font (that1guycolin/default-font-presets--get-font)))
        (set-face-attribute
         'default t
         :font (concat font "-"
                       (number-to-string
                        that1guycolin/default-font-presets--font-size))))))

  :unless (eq system-type 'android)
  :bind (("C-+" . default-font-presets-scale-increase)
         ("C--" . default-font-presets-scale-decrease)
         ("C-=" . default-font-presets-scale-fit)
         ("C-0" . default-font-presets-scale-reset)
         ("M-<up>" . default-font-presets-forward)
         ("M-<down>" . default-font-presets-backward))
  :functions (default-font-presets--ensure-once
              default-font-presets--switch-pre
              default-font-presets--index-update-on-switch)
  :custom (default-font-presets-list
           (list
            "0x Proto Nerd Font Mono" "3270 Nerd Font Mono"
            "Adwaita Mono Nerd Font Mono" "Agave Nerd Font Mono"
            "Anonymice Pro Nerd Font Mono" "Arimo Nerd Font"
            "Big Blue Term437 Nerd Font Mono"
            "Big Blue Term Plus Nerd Font Mono" "Bitstrom Wera Nerd Font Mono"
            "Blex Mono Nerd Font Mono" "Caskaydia Cove Nerd Font Mono"
            "Caskaydia Mono Nerd Font Mono" "Cousine Nerd Font Mono"
            "D2 Koding Ligature Nerd Font Mono" "Daddy Time Mono Nerd Font Mono"
            "Deja Vu Sans M Nerd Font Mono" "Envy Code R Nerd Font Mono"
            "Fantasque Sans M Nerd Font Mono" "Fira Code Nerd Font Mono"
            "Gohu Font11 Nerd Font Mono" "Gohu Font14 Nerd Font Mono"
            "Gohu Fontuni11 Nerd Font Mono" "Gohu Fontuni14 Nerd Font Mono"
            "Go Mono Nerd Font Mono" "Hack Nerd Font Mono"
            "Heavy Data Nerd Font" "i M Writing Duo Nerd Font"
            "i M Writing Mono Nerd Font Mono" "i M Writing Quat Nerd Font"
            "Inconsolata Go Nerd Font Mono" "Inconsolata LGC Nerd Font Mono"
            "Inconsolata Nerd Font Mono" "Intone Mono Nerd Font Mono"
            "Iosevka Nerd Font Mono" "Iosevka Term Nerd Font Mono"
            "Iosevka Term Slab Nerd Font Mono" "Jet Brains Mono Nerd Font Mono"
            "Jet Brains Mono NL Nerd Font Mono" "Lekton Nerd Font Mono"
            "Lilex Nerd Font Mono" "Literation Mono Nerd Font Mono"
            "M+1 Code Nerd Font Mono" "Martian Mono Nerd Font Mono"
            "M+Code Lat50 Nerd Font Mono" "M+Code Lat60 Nerd Font Mono"
            "Meslo LGLDZ Nerd Font Mono" "Meslo LGL Nerd Font Mono"
            "Meslo LGMDZ Nerd Font Mono" "Meslo LGM Nerd Font Mono"
            "Meslo LGSDZ Nerd Font Mono" "Meslo LGS Nerd Font Mono"
            "Monofur Nerd Font Mono" "Monoid Nerd Font Mono"
            "Mononoki Nerd Font Mono" "Noto Mono Nerd Font Mono"
            "Noto Sans M Nerd Font Mono" "Pro Font I Ix Nerd Font Mono"
            "Pro Font Windows Nerd Font Mono" "Proggy Clean CE Nerd Font Mono"
            "Proggy Clean Nerd Font Mono" "Proggy Clean SZ Nerd Font Mono"
            "Rec Mono Casual Nerd Font Mono" "Rec Mono Duotone Nerd Font Mono"
            "Rec Mono Linear Nerd Font Mono" "Rec Mono Sm Casual Nerd Font Mono"
            "Roboto Mono Nerd Font Mono" "Sauce Code Pro Nerd Font Mono"
            "Shure Tech Mono Nerd Font Mono" "Space Mono Nerd Font Mono"
            "Terminess Nerd Font Mono" "Tinos Nerd Font"
            "Ubuntu Mono Nerd Font Mono" "Victor Mono Nerd Font Mono"
            "Zed Mono Nerd Font Mono"))
  :config
  (let ((font "Blex Mono Nerd Font Mono")
        (size 11)
        (content (list)))
    (unless (daemonp)
      (set-face-attribute
       'default t
       :font (concat font "-" (number-to-string size))))
    (setq that1guycolin/default-font-presets--font-size size)
    (let ((index 0))
      (dolist (font-name default-font-presets-list)
        (push (cons font-name index) content)
        (incf index)))
    (setq content (nreverse content))
    (default-font-presets--switch-pre)
    (setq default-font-presets--index (cdr (assoc font content))))
  (when (daemonp)
    (add-hook 'after-make-frame-functions
              #'that1guycolin/default-font-presets--new-frame)))

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
     ["Theme"
      ("t" "Switch theme"       modus-themes-select)
      ("o" "Rotate theme"       modus-themes-rotate)
      ("l" "Random light theme" modus-themes-load-random-light :transient t)
      ("d" "Random dark theme"  modus-themes-load-random-dark :transient t)
      ("x" "Random theme"       modus-themes-load-random :transient t)]
     ["Fonts"
      ("n" "Next font"          default-font-presets-forward :transient t)
      ("p" "Previous font"      default-font-presets-backward :transient t)
      ("c" "Choose font"        default-font-presets-choose)
      ("r" "Random font"        that1guycolin/default-font-presets-random-font
       :transient t)]
     [""
      ("s" "Set font size"      that1guycolin/default-font-presets-set-size)
      ("0" "Reset font scale"   default-font-presets-scale-reset)
      ("f" "Show font family"   show-font-select-preview)
      ("a" "Show Fonts (All)"   show-font-tabulated)]])
  (keymap-global-set "C-c u" 'that1guycolin/visual-settings-dispatch))


;;; Dashboard:
(use-package dashboard
  :demand t
  :preface (defun that1guycolin/dashboard-setup ()
             "Correctly start dashboard during Elpaca-managed init."
             (dashboard-insert-startupify-lists)
             (dashboard-initialize))
  :functions (dashboard-insert-startupify-lists
              dashboard-initialize dashboard-setup-startup-hook
              dashboard-refresh-buffer dashboard-display-icons-p)
  :init
  (add-hook 'elpaca-after-init-hook #'that1guycolin/dashboard-setup)
  (unless (eq system-type 'android)
    (setq initial-buffer-choice #'dashboard-refresh-buffer))
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
