;;; 15-user-functions.el --- Custom variables & functions -*- lexical-binding: t; -*-

;;; Commentary:
;; Variables, functions, and transient dispatches defined by the user.

;;; Code:
;; =======  FONTS  =======
(defvar user/font-alist nil
  "Alist mapping human-readable font names to non-directory filenames.")

(if (eq system-type 'android)
    (setq user/font-alist
	  '(("Anonymice Pro NF"		 . "AnonymiceProNerdFont")
	    ("Anonymice Pro NFM"	 . "AnonymiceProNerdFontMono")
	    ("Anonymice Pro NFP"	 . "AnonymiceProNerdFontPropo")
	    ("Blex NF"			 . "BlexMonoNerdFont")
	    ("Blex NFM"			 . "BlexMonoNerdFontMono")
	    ("Blex NFP"			 . "BlexMonoNerdFontPropo")
	    ("DaddyTime NF"		 . "DaddyTimeMonoNerdFont")
	    ("DaddyTime NFM"		 . "DaddyTimeMonoNerdFontMono")
	    ("DaddyTime NFP"		 . "DaddyTimeMonoNerdFontPropo")
	    ("Droid Sans NF"		 . "DroidSansMNerdFont")
	    ("Droid Sans NFM"		 . "DroidSansMNerdFontMono")
	    ("Droid Sans NFP"		 . "DroidSansMNerdFontPropo")
	    ("Fantasque Sans NF"	 . "FantasqueSansMNerdFont")
	    ("Fantasque Sans NFM"	 . "FantasqueSansMNerdFontMono")
	    ("Fantasque Sans NFP"	 . "FantasqueSansMNerdFontPropo")
	    ("Go NF"			 . "GoMonoNerdFont")
	    ("Go NFM"			 . "GoMonoNerdFontMono")
	    ("Go NFP"			 . "GoMonoNerdFontPropo")
	    ("Space NF"			 . "SpaceMonoNerdFont")
	    ("Space NFM"		 . "SpaceMonoNerdFontMono")
	    ("Space NFP"		 . "SpaceMonoNerdFontPropo")))
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


;; =======  SIDE-WINDOW  =======
(defun user/toggle-side-window ()
  "Switch focus between a side window and the main window area.
If in a side window, return to the last used window.
If not in a side window, jump to the first found side window."
  (interactive)
  (let* ((side-window (cl-find-if (lambda (w)
				    (window-parameter w 'window-side))
                                  (window-list))))
    (cond
     ((not side-window)
      (message "No side window found in this frame."))
     ((eq (selected-window) side-window)
      (select-window (get-mru-window nil nil t)))
     (t
      (select-window side-window)))))
(bind-keys ("M-0" . user/toggle-side-window))

(defvar user/tools-directory)
(defun user/load-generate-readme ()
  "Load generate-readme.el and make its functions available for use."
  (interactive)
  (add-to-list 'load-path user/tools-directory)
  (require 'generate-readme))

(declare-function elpaca-update-menus "elpaca")
(defun user/elpaca-update-menus ()
  "Non-interactively run `elpaca-update-menus'."
  (interactive)
  (funcall #'elpaca-update-menus))


;; =======  TRANSIENT  =======
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
      ("f b" "Font size behaviour" user/set-font-size-behaviour :transient t)]
     ["Theme"
      ("t s" "Switch theme"        modus-themes-select-dark)
      ("t r" "Random theme"        modus-themes-load-random-dark)
      ("t n" "Rotate theme"        modus-themes-rotate)]])
  (keymap-global-set "C-c u" 'user/visual-settings-dispatch))

(declare-function elpaca-manager			"elpaca")
(declare-function elpaca-fetch				"elpaca")
(declare-function elpaca-fetch-all			"elpaca")
(declare-function elpaca-merge				"elpaca")
(declare-function elpaca-merge-all			"elpaca")
(declare-function elpaca-rebuild			"elpaca")
(declare-function elpaca-update                         "elpaca")
(declare-function elpaca-update-all                     "elpaca")
(declare-function elpaca-build-autoloads		"elpaca")
(declare-function elpaca-build-docs                     "elpaca")
(declare-function elpaca-build-docs-process-sentinel	"elpaca")
(declare-function elpaca-build-compile			"elpaca")
(defvar-keymap user/elpaca-options-map
  :prefix t
  :doc "Functions for Elpaca package manager"
  "g"	 #'elpaca-manager
  "n"    #'user/elpaca-update-menus
  "f"	 #'elpaca-fetch
  "F"	 #'elpaca-fetch-all
  "m"	 #'elpaca-merge
  "M"	 #'elpaca-merge-all
  "r"	 #'elpaca-rebuild
  "u"	 #'elpaca-update
  "U"	 #'elpaca-update-all
  "b a"	 #'elpaca-build-autoloads
  "b d"	 #'elpaca-build-docs
  "b D"	 #'elpaca-build-docs-process-sentinel
  "b c"	 #'elpaca-build-compile)

(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements
    user/elpaca-options-map
    "g" "Elpaca Manager"
    "n" "Update Menus"
    "f" "Fetch"
    "F" "Fetch All"
    "m" "Merge"
    "M" "Merge All"
    "r" "Rebuild"
    "u" "Update"
    "U" "Update All"
    "b a" "Build Autoloads"
    "b d" "Build Docs"
    "b D" "Build Docs (Process Sentinel)"
    "b c" "Build Compile"))

(keymap-global-set "C-c e" 'user/elpaca-options-map)


(provide '15-user-functions)
;;; 15-user-functions.el ends here
