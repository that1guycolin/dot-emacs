;;; 12-user-functions.el --- Custom variables & functions -*- lexical-binding: t; -*-

;;; Packages included: transient

;;; Commentary:
;; Variables and functions defined by the user with no natural home elsewhere in
;; the configuration.  These should load last.

;;; Code:
;; =======  THEME  =======
;; Available theme list
(defvar user/theme-list) ; see 03-visual-settings.el
(defun user/populate-theme-list ()
  "Find new themes, sort them, and append them to `user/theme-list'."
  (let ((build-dir (bound-and-true-p elpaca-builds-directory))
        (new-themes '())) ; Temporary list for newly discovered themes
    (when (and build-dir (file-directory-p build-dir))
      (let ((files (directory-files build-dir nil nil t)))
        (dolist (file files)
	  (let ((full-path (expand-file-name file build-dir)))
	    (when (and (file-directory-p full-path)
		       (string-match "-theme$" file))
	      (let* ((theme-name (substring file 0 (match-beginning 0)))
		     (theme-symbol (intern theme-name)))
                (unless (or (member theme-symbol user/theme-list)
			    (member theme-symbol new-themes))
		  (push theme-symbol new-themes)))))))
      (setq new-themes (sort new-themes
			     (lambda (a b)
			       (string< (symbol-name a) (symbol-name b)))))
      (setq user/theme-list (append user/theme-list new-themes)))))
(user/populate-theme-list)

;; Install themes
(defvar user/themes-to-install-list
  '(
    ancient-one-dark-theme caroline-theme curry-on-theme dakrone-theme
    darkokai-theme dream-theme edna-theme evangelion-theme fantom-theme
    foggy-night-theme gotham-theme iceberg-theme idea-darkula-theme
    madhat2r-theme material-theme miasma-theme monokai-alt-theme
    morrowind-theme night-owl-theme nordic-night-theme nord-theme
    oblivion-theme obsidian-theme overcast-theme planet-theme
    purple-haze-theme rebecca-theme reykjavik-theme simplicity-theme
    starlit-theme vscode-dark-plus-theme zerodark-theme)
  "List of themes to be installed with `user/install-themes(s)'.")
(declare-function elpaca "elpaca")
(defun user/install-themes ()
  "Use elpaca to install all themes in `user/themes-to-install-list'."
  (interactive)
  (dolist (theme user/themes-to-install-list)
    (eval `(elpaca ,theme)))
  (user/populate-theme-list))

(defun user/install-theme (theme)
  "Use elpaca to install a single THEME from `user/themes-to-install-list'."
  (interactive
   (list (intern (completing-read "Select theme: "
				  (mapcar #'symbol-name
					  user/themes-to-install-list)
				  nil t))))
  (eval `(elpaca ,theme))
  (user/populate-theme-list))

;; Select themes
(defvar user/theme-index 0)
(defvar user/theme-name nil
  "A theme's name without the `-theme' suffix.")
(defvar user/theme-dir-name nil
  "A theme's name with the `-theme' suffix.")

(defvar elpaca-builds-directory)
(defun user/cycle-themes ()
  "Cycle through themes in user/theme-list."
  (interactive)
  (disable-theme (nth user/theme-index user/theme-list))
  (setq user/theme-index
        (mod (1+ user/theme-index) (length user/theme-list)))
  (setq user/theme-name (nth user/theme-index user/theme-list))
  (setq user/theme-dir-name (concat (symbol-name user/theme-name) "-theme"))
  (add-to-list 'custom-theme-load-path
	       (expand-file-name user/theme-dir-name elpaca-builds-directory))
  (load-theme user/theme-name t)
  (message "Loaded theme: %s" user/theme-name))

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
      (setq user/theme-dir-name (concat (symbol-name user/theme-name) "-theme"))
      (add-to-list 'custom-theme-load-path
		   (expand-file-name user/theme-dir-name
				     elpaca-builds-directory))
      (load-theme theme t)
      (message "Loaded theme: %s" theme))))


;; =======  FONTS  =======
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


;; =======  TREESIT FALLBACK  =======
(defun user/major-ts-mode-fallback ()
  "Set major-modes to *-ts-mode if treesit-auto fails to activate."
  (interactive)
  (dolist (pair '((bash-mode   . bash-ts-mode)
		  (cmake-mode  . cmake-ts-mode)
		  (json-mode   . json-ts-mode)
		  (python-mode . python-ts-mode)
		  (toml-mode   . toml-ts-mode)
		  (yaml-mode   . yaml-ts-mode)))
    (when (fboundp (cdr pair))
      (setf (alist-get (car pair) major-mode-remap-alist) (cdr pair)))))


;; =======  GARBAGE COLLECTION  =======
(defun user/sane-gcmh ()
  "Restore sane gcmh values."
  (setopt
   gcmh-high-cons-threshold (* 100 1024 1024)
   gc-cons-percentage 0.1))


;; =======  TRANSIENT  =======
(declare-function transient-define-prefix "transient")
(defvar user/custom-functions-dispatch nil)
(transient-define-prefix
 user/custom-functions-dispatch ()
 "Display functions defined by the user."
 [["Custom Functions"
   ("f" "Switch Font" user/switch-font)]
  [("c" "Cycle Themes" user/cycle-themes)
   ("t" "Select Theme" user/select-theme)]
  [("i" "Install single theme" user/install-theme)
   ("I" "Install all themes" user/install-themes)]
  [("g" "Sane GCMH" user/sane-gcmh)
   ("s" "Major -ts-mode fallback" user/major-ts-mode-fallback)]])
(declare-function user/custom-functions-dispatch "transient")
(bind-keys ("C-c u"   . user/custom-functions-dispatch))


(provide '12-user-functions)
;;; 12-user-functions.el ends here
