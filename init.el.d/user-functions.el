;;; user-functions.el --- Emacs functions defined by user -*- lexical-binding: t; -*-

;;; Commentary:
;; Provide user-defined functions for theme management (cycle, select)
;; and font switching.  Includes a comprehensive list of Nerd Font mappings.

;;; Packages included:
;; None (pure Elisp user functions)

;;; Code:
;; Themes:
;; Sets a list of included themes, defines functions to switch between themes.
;; Local theme files are stored in ~/.emacs.d/themes/
(defvar user/theme-list
  '(weyland-yutani material monokai morrowind night-owl nord nordic-night
                   oblivion obsidian overcast vs-dark))
(defvar user/theme-index 0)

(defun user/cycle-themes()
  "Cycle through themes in user/theme-list."
  (interactive)
  (disable-theme (nth user/theme-index user/theme-list))
  (setq user/theme-index
        (mod (1+ user/theme-index) (length user/theme-list)))
  (load-theme (nth user/theme-index user/theme-list) t)
  (message "Loaded theme: %s" (nth user/theme-index user/theme-list)))

(defun user/select-theme (theme)
  "Switch to a THEME from user/theme-list."
  (interactive
   (list (intern (completing-read "Select theme: "
                                  (mapcar #'symbol-name user/theme-list)
                                  nil t))))
  (let ((new-index (seq-position user/theme-list theme)))
    (when new-index
      (disable-theme (nth user/theme-index user/theme-list))
      (setq user/theme-index new-index)
      (load-theme theme t)
      (message "Loaded theme: %s" theme))))

(defvar user/font-alist
  ;; "Short name → Nerd Font family mapping."
  '(("3270"        . "3270 Nerd Font Mono")
    ("Adwaita"     . "AdwaitaMono Nerd Font Mono")
    ("Agave"       . "Agave Nerd Font Mono")
    ("Anonymice"   . "AnonymicePro Nerd Font Mono")
    ("Arimo"       . "Arimo Nerd Font")
    ("Aurulent"    . "AurulentSansM Nerd Font Mono")
    ("Bitstrom"    . "BitstromWera Nerd Font Mono")
    ("Blex"        . "BlexMono Nerd Font Mono")
    ("CCove"       . "CaskaydiaCove Nerd Font Mono")
    ("Caskaydia"   . "CaskaydiaMono Nerd Font Mono")
    ("Commit"      . "CommitMono Nerd Font Mono")
    ("Cousine"     . "Cousine Nerd Font Mono")
    ("D2CL"        . "D2CodingLigature Nerd Font Mono")
    ("DaddyTime"   . "DaddyTimeMono Nerd Font Mono")
    ("DejaVu"      . "DejaVuSansM Nerd Font Mono")
    ("Droid"       . "DroidSansM Nerd Font Mono")
    ("Envy"        . "EnvyCodeR Nerd Font Mono")
    ("Fantasque"   . "FantasqueSansM Nerd Font Mono")
    ("FCode"       . "FiraCode Nerd Font Mono")
    ("Fira"        . "FiraMono Nerd Font Mono")
    ("Geist"       . "GeistMono Nerd Font Mono")
    ("Go"          . "GoMono Nerd Font Mono")
    ("Hack"        . "HackMono Nerd Font Mono")
    ("Hasklug"     . "Hasklug Nerd Font Mono")
    ("Hurmit"      . "Hurmit Nerd Font Mono")
    ("iMWriting"   . "iMWritingMono Nerd Font Mono")
    ("iMWQuat"     . "iMWritingQuat Nerd Font Mono")
    ("IncLGC"      . "Inconsolata LGC Nerd Font Mono")
    ("Inconsolata" . "Inconsolata Nerd Font Mono")
    ("Intone"      . "IntoneMono Nerd Font Mono")
    ("JetBrains"   . "JetBrainsMono Nerd Font Mono")
    ("JetBMNL"     . "JetBrainsMonoNL Nerd Font Mono")
    ("Literation"  . "LiterationMono Nerd Font Mono")
    ("Martian"     . "MartianMono Nerd Font Mono")
    ("MSpiceAr"    . "MonaspiceAr Nerd Font Mono")
    ("MSpiceKr"    . "MonoaspiceKr Nerd Font Mono")
    ("MSpiceNe"    . "MonoaspiceNe Nerd Font Mono")
    ("MSpiceRn"    . "MonoaspiceRn Nerd Font Mono")
    ("MSpiceXe"    . "MonoaspiceXe Nerd Font Mono")
    ("Monofur"     . "Monofur Nerd Font Mono")
    ("Mononoki"    . "Mononoki Nerd Font Mono")
    ("PFIIx"       . "ProFont IIx Nerd Font Mono")
    ("PFWindows"   . "ProFontWindows Nerd Font Mono")
    ("RMCasual"    . "RecMonoCasual Nerd Font Mono")
    ("RMDuotone"   . "RecMonoDuotone Nerd Font Mono")
    ("RMLinear"    . "RecMonoLinear Nerd Font Mono")
    ("Roboto"      . "RobotoMono Nerd Font Mono")
    ("SauceCode"   . "SauceCodePro Nerd Font Mono")
    ("Space"       . "SpaceMono Nerd Font Mono")
    ("Terminess"   . "Terminess Nerd Font Mono")
    ("Zed"         . "ZedMono Nerd Font Mono")))

(defun user/switch-font (name)
  "Switch font using a short NAME like \"Space\" or \"Zed\"."
  (interactive
   (list (completing-read
          "Font: "
          (mapcar #'car user/font-alist)
          nil t)))
  (let ((font (cdr (assoc name user/font-alist))))
    (set-face-attribute 'default nil
                        :family font
                        :height 110
                        :weight 'regular)
    (message "Font set to %s" font)))

(keymap-global-set "C-c u c" #'user/cycle-themes)
(keymap-global-set "C-c u t" #'user/select-theme)
(keymap-global-set "C-c u f" #'user/switch-font)

(provide 'user-functions)
;;; user-functions.el ends here
