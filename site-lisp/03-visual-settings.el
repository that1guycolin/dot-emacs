;;; 03-visual-settings.el --- Core UI configuration -*- lexical-binding: t; -*-

;;; Packages included:
;; editorconfig, ef-themes, inhibit-mouse, minions, modus-themes, nerd-icons,
;; nerd-icons-corfu, show-font, tab-line-nerd-icons, visual-fill-column

;;; Commentary:
;; Core UI elements that provide visual feedback and interaction.

;;; Code:
;;; Start fullscreen:
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq font-use-system-font t)

;;; Themes:
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


;;; Icons:
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
  :after (nerd-icons)
  :demand t
  :preface (defvar corfu-margin-formatters)
  :config (add-to-list 'corfu-margin-formatters 'nerd-icons-corfu-formatter))


;;; Font:
(defvar user/font-alist nil
  "Alist mapping human-readable font names to non-directory filenames.")

(if (eq system-type 'android)
    (setq user/font-alist
          '(("Anonymice Pro NF"          . "AnonymicePro Nerd Font")
            ("Anonymice Pro NFM"         . "AnonymicePro Nerd Font Mono")
            ("Anonymice Pro NFP"         . "AnonymicePro Nerd Font Propo")
            ("Blex NF"                   . "BlexMono Nerd Font")
            ("Blex NFM"                  . "BlexMono Nerd Font Mono")
            ("Blex NFP"                  . "BlexMono Nerd Font Propo")
            ("DaddyTime NF"              . "DaddyTimeMono Nerd Font")
            ("DaddyTime NFM"             . "DaddyTimeMono Nerd Font Mono")
            ("DaddyTime NFP"             . "DaddyTimeMono Nerd Font Propo")
            ("Droid Sans NF"             . "DroidSansM Nerd Font")
            ("Droid Sans NFM"            . "DroidSansM Nerd Font Mono")
            ("Droid Sans NFP"            . "DroidSansM Nerd Font Propo")
            ("Fantasque Sans NF"         . "FantasqueSansM Nerd Font")
            ("Fantasque Sans NFM"        . "FantasqueSansM Nerd Font Mono")
            ("Fantasque Sans NFP"        . "FantasqueSansM Nerd Font Propo")
            ("Go NF"                     . "GoMono Nerd Font")
            ("Go NFM"                    . "GoMono Nerd Font Mono")
            ("Go NFP"                    . "GoMono Nerd Font Propo")
            ("Space NF"                  . "SpaceMono Nerd Font")
            ("Space NFM"                 . "SpaceMono Nerd Font Mono")
            ("Space NFP"                 . "SpaceMono Nerd Font Propo")))
  (setq user/font-alist
        '(("0xProto"                   . "0xProtoNerdFontMono")
          ("3270"                      . "3270NerdFontMono")
          ("Adwaita"                   . "AdwaitaMonoNerdFontMono")
          ("Agave"                     . "AgaveNerdFontMono")
          ("Anonymice Pro"             . "AnonymiceProNerdFontMono")
          ("Big Blue Term 437"         . "BigBlueTerm437NerdFontMono")
          ("Big Blue Term Plus"        . "BigBlueTermPlusNerdFontMono")
          ("Bitstrom Wera"             . "BitstromWeraNerdFontMono")
          ("Blex"                      . "BlexMonoNerdFontMono")
          ("Caskaydia Cove"            . "CaskaydiaCoveNerdFontMono")
          ("Caskaydia"                 . "CaskaydiaMonoNerdFontMono")
          ("Cousine"                   . "CousineNerdFontMono")
          ("D2 Coding Ligature"        . "D2CodingLigatureNerdFontMono")
          ("Daddy Time"                . "DaddyTimeMonoNerdFontMono")
          ("DejaVu Sans"               . "DejaVuSansMNerdFontMono")
          ("Envy CodeR"                . "EnvyCodeRNerdFontMono")
          ("Fantasque Sans"            . "FantasqueSansMNerdFontMono")
          ("Fira Code"                 . "FiraCodeNerdFontMono")
          ("Gohu Font 11"              . "GohuFont11NerdFontMono")
          ("Gohu Font 14"              . "GohuFont14NerdFontMono")
          ("Gohu Fontuni 11"           . "GohuFontuni11NerdFontMono")
          ("Gohu Fontuni 14"           . "GohuFontuni14NerdFontMono")
          ("Go"                        . "GoMonoNerdFontMono")
          ("Hack"                      . "HackNerdFontMono")
          ("i M Writing"               . "iMWritingMonoNerdFontMono")
          ("Inconsolata Go"            . "InconsolataGoNerdFontMono")
          ("Inconsolata LGC"           . "InconsolataLGCNerdFontMono")
          ("Inconsolata"               . "InconsolataNerdFontMono")
          ("Intone"                    . "IntoneMonoNerdFontMono")
          ("Iosevka"                   . "IosevkaNerdFontMono")
          ("Iosevka Term"              . "IosevkaTermNerdFontMono")
          ("Iosevka Term Slab"         . "IosevkaTermSlabNerdFontMono")
          ("Jet Brains"                . "JetBrainsMonoNerdFontMono")
          ("Jet Brains NL"             . "JetBrainsMonoNLNerdFontMono")
          ("Lekton"                    . "LektonNerdFontMono")
          ("Lilex"                     . "LilexNerdFontMono")
          ("Literation"                . "LiterationMonoNerdFontMono")
          ("M+1 Code"                  . "M+1CodeNerdFontMono")
          ("M+Code Lat50"              . "M+CodeLat50NerdFontMono")
          ("M+Code Lat60"              . "M+CodeLat60NerdFontMono")
          ("Martian-Condensed"         .
           "MartianMonoNerdFontMono-CondensedRegular")
          ("Martian"                   . "MartianMonoNerdFontMono")
          ("Meslo LGLDZ"               . "MesloLGLDZNerdFontMono")
          ("Meslo LGL"                 . "MesloLGLNerdFontMono")
          ("Meslo LGMDZ"               . "MesloLGMDZNerdFontMono")
          ("Meslo LGM"                 . "MesloLGMNerdFontMono")
          ("Meslo LGSDZ"               . "MesloLGSDZNerdFontMono")
          ("Meslo LGS"                 . "MesloLGSNerdFontMono")
          ("Monofur"                   . "MonofurNerdFontMono")
          ("Monoid"                    . "MonoidNerdFontMono")
          ("Mononoki"                  . "MononokiNerdFontMono")
          ("Noto"                      . "NotoMonoNerdFontMono")
          ("Noto Sans-Condensed"       .
           "NotoSansMNerdFontMono-CondensedRegular")
          ("Noto Sans-Extra Condensed" .
           "NotoSansMNerdFontMono-ExtraCondensedRegular")
          ("Noto Sans"                 . "NotoSansMNerdFontMono")
          ("Noto Sans-Semi Condensed"  .
           "NotoSansMNerdFontMono-SemiCondensedRegular")
          ("Pro Font IIx"              . "ProFontIIxNerdFontMono")
          ("Pro Font Windows"          . "ProFontWindowsNerdFontMono")
          ("Proggy Clean CE"           . "ProggyCleanCENerdFontMono")
          ("Proggy Clean"              . "ProggyCleanNerdFontMono")
          ("Proggy Clean SZ"           . "ProggyCleanSZNerdFontMono")
          ("Rec Casual"                . "RecMonoCasualNerdFontMono")
          ("Rec Duotone"               . "RecMonoDuotoneNerdFontMono")
          ("Rec Linear"                . "RecMonoLinearNerdFontMono")
          ("Rec Sm Casual"             . "RecMonoSmCasualNerdFontMono")
          ("Roboto"                    . "RobotoMonoNerdFontMono")
          ("Sauce Code Pro"            . "SauceCodeProNerdFontMono")
          ("Shure Tech"                . "ShureTechMonoNerdFontMono")
          ("Space"                     . "SpaceMonoNerdFontMono")
          ("Terminess"                 . "TerminessNerdFontMono")
          ("Ubuntu"                    . "UbuntuMonoNerdFontMono")
          ("Victor"                    . "VictorMonoNerdFontMono")
          ("Zed"                       . "ZedMonoNerdFontMono"))))

(defvar user/keep-frame-size-on-font-switch-p t
  "If non-nil, attempt to keep frame size fixed when changing font.
If nil, the number of frame lines and columns remains fixed.")

(defun user/switch-font (font)
  "Switch to a FONT contained in `user/font-alist'."
  (interactive
   (list (completing-read
          "Font: " (mapcar #'car user/font-alist)
          nil t)))
  (set-frame-font (cdr (assoc font user/font-alist))
                  user/keep-frame-size-on-font-switch-p t t)
  (message "Font set to %s" font))

(defun user/random-font ()
  "Activate a random font from `user/font-alist'."
  (interactive)
  (let* ((font-cons (nth (random (length user/font-alist)) user/font-alist))
         (font (cdr font-cons)))
    (set-frame-font font user/keep-frame-size-on-font-switch-p t t)
    (message "Font set to %s" (car font-cons))))

(defun user/set-font-size-behaviour (input)
  "Prompt the user for INPUT on handling frame resizing when switching font."
  (declare (interactive-only t))
  (interactive
   (let ((frame-resizing-cons
          (if user/keep-frame-size-on-font-switch-p
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
  (setq user/keep-frame-size-on-font-switch-p input))

;; preview fonts prior to selection
(use-package show-font
  :defer t
  :commands (show-font-select-preview show-font-tabulated))

(with-eval-after-load 'transient
  (declare-function transient-define-prefix "transient")
  (defvar user/visual-settings-dispatch nil)
  (transient-define-prefix
    user/visual-settings-dispatch ()
    "Display functions that change how the user-interface looks."
    ["Modify UI"
     ["Fonts"
      ("f s" "Switch font"         user/switch-font)
      ("f r" "Random font"         user/random-font)
      ("f b" "Font size behaviour" user/set-font-size-behaviour :transient t)
      ("f f" "Show Font Family"    show-font-select-preview)
      ("f a" "Show Fonts (All)"    show-font-tabulated)]
     ["Theme"
      ("t s" "Switch theme"        modus-themes-select-dark)
      ("t r" "Random theme"        modus-themes-load-random-dark)
      ("t n" "Rotate theme"        modus-themes-rotate)]])
  (keymap-global-set "C-c u" 'user/visual-settings-dispatch))


;;; Other:
;; de-clutter modeline w/ menu for minor-modes
(use-package minions
  :demand t
  :functions (minions-mode)
  :config (minions-mode 1))

(use-package editorconfig
  :defer t
  :hook ((prog-mode text-mode conf-mode) . editorconfig-mode))

(use-package visual-fill-column
  :defer t
  :hook ((prog-mode text-mode conf-mode) . visual-line-mode)
  :functions (visual-fill-column-for-vline)
  :init (add-hook 'visual-line-mode-hook #'visual-fill-column-for-vline))

;; DON'T MOVE THE MOUSE!
(use-package inhibit-mouse
  :demand t
  :unless (eq system-type 'android)
  :functions (inhibit-mouse-mode)
  :custom
  (inhibit-mouse-adjust-mouse-highlight t)
  (inhibit-mouse-adjust-show-help-function t)
  :config
  (if (daemonp)
      (add-hook 'server-after-make-frame-hook #'inhibit-mouse-mode)
    (inhibit-mouse-mode 1)))


(provide '03-visual-settings)
;;; 03-visual-settings.el ends here
