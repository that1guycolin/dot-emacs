;;; 15-user-functions.el --- Custom variables & functions -*- lexical-binding: t; -*-

;;; Commentary:
;; Variables, functions, and transient dispatches defined by the user.
;; Items in this file either have no natural home elsewhere in the configuration,
;; or, more likely, need to be loaded last.

;;; Code:
;; =======  THEME  =======
(defvar user/themes-list)
(defun user/add-theme (theme)
  "Install new THEME and add it to `user/themes-list'."
  (interactive)
  (let ((theme-name-full (concat (symbol-name theme) "-theme")))
    (when (eval `(elpaca ,theme-name-full))
      (add-to-list 'user/themes-list theme))))

;; Select themes
(defvar user/themes-index 0
  "Index location of user/themes-list.")

(defvar elpaca-builds-directory)
(defun user/smart-load-theme (theme)
  "Load THEME.  If theme directory is not in`load-path', add it."
  (let* ((theme-name-full (concat (symbol-name theme) "-theme"))
	 (theme-directory
	  (expand-file-name theme-name-full elpaca-builds-directory)))
    (unless (member theme-directory custom-theme-load-path)
      (add-to-list 'custom-theme-load-path theme-directory))
    (load-theme theme t)))

(defun user/cycle-themes ()
  "Cycle through themes in `user/themes-list'."
  (interactive)
  (disable-theme (nth user/themes-index user/themes-list))
  (setq user/themes-index
        (mod (1+ user/themes-index) (length user/themes-list)))
  (let ((theme (nth user/themes-index user/themes-list)))
    (user/smart-load-theme theme)
    (message "Loaded theme: %s" theme)))

(defun user/select-theme (theme)
  "Switch to a THEME from `user/themes-list'."
  (interactive
   (list (intern (completing-read "Select theme: "
				  user/themes-list nil t))))
  (let ((new-index (seq-position user/themes-list theme)))
    (when new-index
      (disable-theme (nth user/themes-index user/themes-list))
      (setq user/themes-index new-index)
      (user/smart-load-theme theme)
      (message "Loaded theme: %s" theme))))


;; =======  FONTS  =======
(defvar user/font-alist
  '(
    ("0xProto NFM"          . "0xProto Nerd Font Mono")
    ("03270 NFM"            . "03270 Nerd Font Mono")
    ("AdwaitaMono NFM"      . "AdwaitaMono Nerd Font Mono")
    ("Agave NFM"            . "Agave Nerd Font Mono")
    ("AnonymicePro NFM"     . "AnonymicePro Nerd Font Mono")
    ("BigBlueTerm437 NFM"   . "BigBlueTerm437 Nerd Font Mono")
    ("BigBlueTermPlus NFM"  . "BigBlueTermPlus Nerd Font Mono")
    ("BitstromWera NFM"     . "BitstromWera Nerd Font Mono")
    ("BlexMono NFM"         . "BlexMono Nerd Font Mono")
    ("CaskaydiaCove NFM"    . "CaskaydiaCove Nerd Font Mono")
    ("CaskaydiaMono NFM"    . "CaskaydiaMono Nerd Font Mono")
    ("Cousine NFM"          . "Cousine Nerd Font Mono")
    ("D2CodingLigature NFM" . "D2CodingLigature Nerd Font Mono")
    ("DaddyTimeMono NFM"    . "DaddyTimeMono Nerd Font Mono")
    ("DejaVuSansM NFM"      . "DejaVuSansM Nerd Font Mono")
    ("EnvyCodeR NFM"        . "EnvyCodeR Nerd Font Mono")
    ("FantasqueSansM NFM"   . "FantasqueSansM Nerd Font Mono")
    ("FiraCode NFM"         . "FiraCode Nerd Font Mono")
    ("GohuFont11 NFM"       . "GohuFont11 Nerd Font Mono")
    ("GohuFont14 NFM"       . "GohuFont14 Nerd Font Mono")
    ("GohuFontuni11 NFM"    . "GohuFontuni11 Nerd Font Mono")
    ("GohuFontuni14 NFM"    . "GohuFontuni14 Nerd Font Mono")
    ("GoMono NFM"           . "GoMono Nerd Font Mono")
    ("Hack NFM"             . "Hack Nerd Font Mono")
    ("iMWritingMono NFM"    . "iMWritingMono Nerd Font Mono")
    ("InconsolataGo NFM"    . "InconsolataGo Nerd Font Mono")
    ("InconsolataLGC NFM"   . "InconsolataLGC Nerd Font Mono")
    ("Inconsolata NFM"      . "Inconsolata Nerd Font Mono")
    ("IntoneMono NFM"       . "IntoneMono Nerd Font Mono")
    ("Iosevka NFM"          . "Iosevka Nerd Font Mono")
    ("IosevkaTerm NFM"      . "IosevkaTerm Nerd Font Mono")
    ("IosevkaTermSlab NFM"  . "IosevkaTermSlab Nerd Font Mono")
    ("JetBrainsMono NFM"    . "JetBrainsMono Nerd Font Mono")
    ("JetBrainsMonoNL NFM"  . "JetBrainsMonoNL Nerd Font Mono")
    ("Lekton NFM"           . "Lekton Nerd Font Mono")
    ("Lilex NFM"            . "Lilex Nerd Font Mono")
    ("LiterationMono NFM"   . "LiterationMono Nerd Font Mono")
    ("M+1Code NFM"          . "M+1Code Nerd Font Mono")
    ("M+CodeLat50 NFM"      . "M+CodeLat50 Nerd Font Mono")
    ("M+CodeLat60 NFM"      . "M+CodeLat60 Nerd Font Mono")
    ("MartianMono NFM"      . "MartianMono Nerd Font Mono")
    ("MesloLGLDZ NFM"       . "MesloLGLDZ Nerd Font Mono")
    ("MesloLGL NFM"         . "MesloLGL Nerd Font Mono")
    ("MesloLGMDZ NFM"       . "MesloLGMDZ Nerd Font Mono")
    ("MesloLGM NFM"         . "MesloLGM Nerd Font Mono")
    ("MesloLGSDZ NFM"       . "MesloLGSDZ Nerd Font Mono")
    ("MesloLGS NFM"         . "MesloLGS Nerd Font Mono")
    ("Monofur NFM"          . "Monofur Nerd Font Mono")
    ("Monoid NFM"           . "Monoid Nerd Font Mono")
    ("Mononoki NFM"         . "Mononoki Nerd Font Mono")
    ("NotoMono NFM"         . "NotoMono Nerd Font Mono")
    ("NotoSansM NFM"        . "NotoSansM Nerd Font Mono")
    ("ProFontIIx NFM"       . "ProFontIIx Nerd Font Mono")
    ("ProFontWindows NFM"   . "ProFontWindows Nerd Font Mono")
    ("ProggyCleanCE NFM"    . "ProggyCleanCE Nerd Font Mono")
    ("ProggyClean NFM"      . "ProggyClean Nerd Font Mono")
    ("ProggyCleanSZ NFM"    . "ProggyCleanSZ Nerd Font Mono")
    ("RecMonoCasual NFM"    . "RecMonoCasual Nerd Font Mono")
    ("RecMonoDuotone NFM"   . "RecMonoDuotone Nerd Font Mono")
    ("RecMonoLinear NFM"    . "RecMonoLinear Nerd Font Mono")
    ("RecMonoSmCasual NFM"  . "RecMonoSmCasual Nerd Font Mono")
    ("RobotoMono NFM"       . "RobotoMono Nerd Font Mono")
    ("SauceCodePro NFM"     . "SauceCodePro Nerd Font Mono")
    ("ShureTechMono NFM"    . "ShureTechMono Nerd Font Mono")
    ("SpaceMono NFM"        . "SpaceMono Nerd Font Mono")
    ("Symbols NFM"          . "Symbols Nerd Font Mono")
    ("Terminess NFM"        . "Terminess Nerd Font Mono")
    ("UbuntuMono NFM"       . "UbuntuMono Nerd Font Mono")
    ("VictorMono NFM"       . "VictorMono Nerd Font Mono")
    ("ZedMono NFM"           . "ZedMono Nerd Font Mono"))
  "Short name → Nerd Font family mapping.")

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


;; =======  ELPACA  =======
(declare-function elpaca-update-menus "elpaca")
(declare-function feature-file "savehist")
(declare-function async-start "async")
(defvar elpaca-installer-version)
(defun user/update-elpaca-menus ()
  "Asynchronously update all Elpaca menus."
  (interactive)
  (let ((menus '(elpaca-menu-extensions
                 elpaca-menu-lock-file
                 elpaca-menu-org
                 elpaca-menu-gnu-elpa
                 elpaca-menu-nongnu-elpa
                 elpaca-menu-melpa))
	(elpaca-path (file-name-directory (feature-file 'elpaca))))
    (message "Updating Elpaca menus in the background...")
    (async-start
     `(lambda ()
	(defvar elpaca-installer-version ,elpaca-installer-version)
	(add-to-list 'load-path ,elpaca-path)
        (require 'elpaca-autoloads nil t)
        (dolist (menu ',menus)
          (elpaca-update-menus menu))
        "All menus updated!")
     (lambda (result)
       (message result)))))

(defvar user-init-directory)
(defun user/get-package-list ()
  "Return a list of all packages installed with elpaca-use-package."
  (let ((package-list '()))
    (let* ((get-files-command (format "ls %s" user-init-directory))
	   (init-file-list (split-string
			    (shell-command-to-string get-files-command))))
      (dolist (file init-file-list)
	(let* ((script (expand-file-name "tools/list-use-packages.el"
					 user-emacs-directory))
	       (get-packages-command
		(format "emacs --script %s %s" script file))
	       (packages-string (shell-command-to-string get-packages-command))
	       (package-split-string (split-string packages-string)))
	  (dolist (package package-split-string)
	    (push (intern package) package-list)))))
    (nreverse package-list)))

(defun user/elpaca-update-packages ()
  "Asynchronously update all Elpaca packages (excepting themes)."
  (interactive)
  (let ((packages (user/get-package-list))
	(init-file (expand-file-name "init.el" user-emacs-directory)))
    (message "Updating Elpaca packages in the background...")
    (async-start
     `(lambda ()
	(load ,init-file)
        (dolist (package ',packages)
          (elpaca-fetch package)
	  (elpaca-merge package)
	  (elpaca-rebuild package))
        "All packages updated!")
     (lambda (result)
       (message result)))))


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
   [("E" "Update elpaca menus" user/update-elpaca-menus)
    ("p" "Update packages" user/elpaca-update-packages)]
   [("s" "Major -ts-mode fallback" user/major-ts-mode-fallback)]])
(declare-function user/custom-functions-dispatch "15-user-functions")
(bind-keys ("C-c u" . user/custom-functions-dispatch))


(provide '15-user-functions)
;;; 15-user-functions.el ends here
