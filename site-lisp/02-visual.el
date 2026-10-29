;;; 02-visual.el --- Core UI configuration -*- lexical-binding: t; -*-

;;; Packages included:
;; dashboard, default-font-presets, ef-themes, inhibit-mouse, minions,
;; modus-themes, nerd-icons, nerd-icons-corfu, popper, show-font,
;; tab-line-nerd-icons, treemacs-nerd-icons, visual-fill-column

;;; Commentary:
;; Define the user-interface. In the case of this configuration, start with
;; some functional, yet beautiful themes, go heavy on the nerd-icons, and finish
;; off with a dashboard to greet you every time you open Emacs or a new
;; server-frame.

;;; Code:

(require '00-macros)

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
             helpful-mode compilation-mode))
  :config
  (popper-mode +1)
  (popper-echo-mode +1))

;; Line-length:
(use-package visual-fill-column
  :demand t
  :preface
  (defun that1guycolin/visual-fill-column-setup ()
    "Activate `visual-line-mode' & related minor-modes.
Useful as a hook function."
    (display-fill-column-indicator-mode 1)
    (visual-line-mode 1)
    (auto-fill-mode 1))
  :hook ((visual-line-mode . visual-fill-column-for-vline)
         ((prog-mode text-mode conf-mode) .
          that1guycolin/visual-fill-column-setup)))


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
multiplied by 10. Setting this value directly will nothing, it must be updated
via the function `that1guycolin/default-font-presets-set-size'."
    :type 'integer
    :group 'default-font-presets)
  
  (defun that1guycolin/default-font-presets-set-size (new-size)
    "Set the current font size to NEW-SIZE."
    (interactive
     (list
      (read-number (format "Font Size (Current: %i): "
                           that1guycolin/default-font-presets--font-size))))
    (set-frame-font (format "%s-%i"
                            (that1guycolin/default-font-presets--get-font)
                            new-size)
                    nil t t)
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

  :bind (("C-+" . default-font-presets-scale-increase)
         ("C--" . default-font-presets-scale-decrease)
         ("C-=" . default-font-presets-scale-fit)
         ("C-0" . default-font-presets-scale-reset)
         ("M-<up>" . default-font-presets-forward)
         ("M-<down>" . default-font-presets-backward))
  :functions (default-font-presets--ensure-once
              default-font-presets--switch-pre
              default-font-presets--index-update-on-switch)
  :init (that1guycolin/emacs-set-for-type default-font-presets-list
          '("0xProto Nerd Font Mono" "3270 Nerd Font Mono"
            "AdwaitaMono Nerd Font Mono" "Agave Nerd Font Mono"
            "AnnotationM Nerd Font Mono" "AnonymicePro Nerd Font Mono"
            "Arimo Nerd Font" "AtkynsonMono Nerd Font Mono"
            "AurulentSansM Nerd Font Mono" "BigBlueTerm437 Nerd Font Mono"
            "BigBlueTermPlus Nerd Font Mono" "BitstromWera Nerd Font Mono"
            "BlexMono Nerd Font Mono" "CaskaydiaCove Nerd Font Mono"
            "CaskaydiaMono Nerd Font Mono" "CodeNewRoman Nerd Font Mono"
            "ComicShannsMono Nerd Font Mono" "CommitMono Nerd Font Mono"
            "Cousine Nerd Font Mono" "D2KodingLigature Nerd Font Mono"
            "DaddyTimeMono Nerd Font Mono" "DejaVuSansM Nerd Font Mono"
            "DepartureMono Nerd Font Mono" "DroidSansM Nerd Font Mono"
            "EnvyCodeR Nerd Font Mono" "FantasqueSansM Nerd Font Mono"
            "FiraCode Nerd Font Mono" "FiraMono Nerd Font Mono"
            "GeistMono Nerd Font Mono" "GoMono Nerd Font Mono"
            "GoogleSansCode Nerd Font Mono" "Hack Nerd Font Mono"
            "Hasklug Nerd Font Mono" "HeavyData Nerd Font"
            "Hurmit Nerd Font Mono" "iMWritingDuo Nerd Font"
            "iMWritingMono Nerd Font Mono" "iMWritingQuat Nerd Font"
            "InconsolataGo Nerd Font Mono" "Inconsolata Nerd Font Mono"
            "IntoneMono Nerd Font Mono" "Iosevka Nerd Font Mono"
            "IosevkaTerm Nerd Font Mono" "JetBrainsMono Nerd Font Mono"
            "Lekton Nerd Font Mono" "Lilex Nerd Font Mono"
            "LiterationMono Nerd Font Mono" "M+1Code Nerd Font Mono"
            "MartianMono Nerd Font Mono" "M+CodeLat50 Nerd Font Mono"
            "MesloLGM Nerd Font Mono" "MonaspiceAr Nerd Font Mono"
            "MonaspiceKr Nerd Font Mono" "MonaspiceNe Nerd Font Mono"
            "MonaspiceRn Nerd Font Mono" "MonaspiceXe Nerd Font Mono"
            "Monofur Nerd Font Mono" "Monoid Nerd Font Mono"
            "Mononoki Nerd Font Mono" "NotoMono Nerd Font Mono"
            "NotoSansM Nerd Font Mono" "OverpassM Nerd Font Mono"
            "ProFontIIx Nerd Font Mono" "ProFontWindows Nerd Font Mono"
            "ProggyCleanCE Nerd Font Mono" "RecMonoCasual Nerd Font Mono"
            "RecMonoDuotone Nerd Font Mono" "RecMonoLinear Nerd Font Mono"
            "RecMonoSmCasual Nerd Font Mono" "RobotoMono Nerd Font Mono"
            "SauceCodePro Nerd Font Mono" "ShureTechMono Nerd Font Mono"
            "SpaceMono Nerd Font Mono" "Terminess Nerd Font Mono"
            "Tinos Nerd Font" "UbuntuMono Nerd Font Mono"
            "VictorMono Nerd Font Mono" "ZedMono Nerd Font Mono")
          '()
          '("AnnotationM Nerd Font" "AnnotationM Nerd Font Mono"
            "AnnotationM Nerd Font Propo" "AnonymicePro Nerd Font"
            "AnonymicePro Nerd Font Mono" "AnonymicePro Nerd Font Propo"
            "BlexMono Nerd Font" "BlexMono Nerd Font Mono"
            "BlexMono Nerd Font Propo" "DaddyTimeMono Nerd Font"
            "DaddyTimeMono Nerd Font Mono" "DaddyTimeMono Nerd Font Propo"
            "DroidSansM Nerd Font" "DroidSansM Nerd Font Mono"
            "DroidSansM Nerd Font Propo" "FantasqueSansM Nerd Font"
            "FantasqueSansM Nerd Font Mono"
            "FantasqueSansM Nerd Font Propo"
            "FiraCode Nerd Font" "FiraCode Nerd Font Mono"
            "FiraCode Nerd Font Propo" "GoMono Nerd Font"
            "GoMono Nerd Font Mono" "GoMono Nerd Font Propo"
            "IntoneMono Nerd Font" "IntoneMono Nerd Font Mono"
            "IntoneMono Nerd Font Propo" "RecMonoCasual Nerd Font"
            "RecMonoCasual Nerd Font Mono" "RecMonoCasual Nerd Font Propo"
            "RecMonoDuotone Nerd Font" "RecMonoDuotone Nerd Font Mono"
            "RecMonoDuotone Nerd Font Propo" "RecMonoLinear Nerd Font"
            "RecMonoLinear Nerd Font Mono" "RecMonoLinear Nerd Font Propo"
            "RecMonoSmCasual Nerd Font" "RecMonoSmCasual Nerd Font Mono"
            "RecMonoSmCasual Nerd Font Propo" "SpaceMono Nerd Font"
            "SpaceMono Nerd Font Mono" "SpaceMono Nerd Font Propo"
            "Symbols Nerd Font" "Symbols Nerd Font Mono"))
  :config
  (let ((font "BlexMono Nerd Font Mono")
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
  :preface
  (defun that1guycolin/dashboard-setup-startup-hook ()
    "Setup post-init hooks unless a command line argument is provided."
    (when (< (length command-line-args) 2)
      (add-hook 'window-size-change-functions #'dashboard-resize-on-hook)
      (add-hook 'window-setup-hook #'dashboard-resize-on-hook)
      (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
      (when (eq that1guycolin/emacs-type 'desktop)
        (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
        (setq-default initial-buffer-choice #'dashboard-refresh-buffer))))
  
  (defun that1guycolin/dashboard-home-dir ()
    "Change-directory to \"~\". Add to `dashboard-mode-hook'."
    (interactive)
    (setq-local default-directory "~")
    (cd "~"))
  
  :functions (dashboard-resize-on-hook
              dashboard-insert-startupify-lists dashboard-initialize
              dashboard-setup-startup-hook dashboard-refresh-buffer
              dashboard-display-icons-p)
  :init (that1guycolin/dashboard-setup-startup-hook)
  :custom
  (dashboard-banner-logo-title "Welcome back")
  (dashboard-center-content t)
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-items `((projects . ,(length (project-known-project-roots)))
                     (recents . 5)))
  (dashboard-projects-backend 'project-el)
  (dashboard-set-file-icons t)
  (dashboard-set-heading-icons t)
  (dashboard-startup-banner 'logo)
  (dashboard-vertically-center-content t)
  :config
  (add-hook 'dashboard-mode-hook
            (lambda ()
              (that1guycolin/dashboard-home-dir)
              (delete-other-windows)
              (setq-local fill-column 1000))))


(provide '02-visual)
;;; 02-visual.el ends here
