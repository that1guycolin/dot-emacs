;;; 15-user-functions.el --- Custom variables & functions -*- lexical-binding: t; -*-

;;; Commentary:
;; Variables, functions, and transient dispatches defined by the user.
;; Items in this file either have no natural home elsewhere in the configuration,
;; or, more likely, need to be loaded last.

;;; Code:
;; =======  HELPER FUNCTIONS  =======
(defun user/pick-random (list)
  "Return a random element from LIST."
  (nth (random (length list)) list))


;; =======  FONTS  =======
(defvar user/font-alist
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
    ("Martian-Condensed"         . "MartianMonoNerdFontMono-CondensedRegular")
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
    ("Noto Sans-Condensed"       . "NotoSansMNerdFontMono-CondensedRegular")
    ("Noto Sans-Extra Condensed" . "NotoSansMNerdFontMono-ExtraCondensedRegular")
    ("Noto Sans"                 . "NotoSansMNerdFontMono")
    ("Noto Sans-Semi Condensed"  . "NotoSansMNerdFontMono-SemiCondensedRegular")
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
    ("Zed"                       . "ZedMonoNerdFontMono"))
  "An alist mapping human-readable font names to their filename.
In this iteration, all the fonts on the list are monospaced nerd fonts.")

(defun user/switch-font (font)
  "Switch to a FONT contained in `user/font-alist'."
  (interactive
   (list (completing-read
	  "Font: " (mapcar #'car user/font-alist)
	  nil t)))
  (set-frame-font (cdr (assoc font user/font-alist)) t t t)
  (message "Font set to %s" font))

(defun user/random-font ()
  "Activate a random font from `user/font-alist'."
  (interactive)
  (let* ((font-cons (nth (random (length user/font-alist)) user/font-alist))
	 (font (cdr font-cons)))
    (set-frame-font font t t t)
    (message "Font set to %s" (car font-cons))))


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

(defvar user/init-directory)
(defvar user/tools-directory)
(defun user/get-package-list ()
  "Return packages installed with elpaca-use-package as strings.
The returned list does not include packages with :ensure explicitly set to nil."
  (let ((package-list '(elpaca elpaca-use-package)))
    (dolist (file
	     (directory-files
	      user/init-directory t directory-files-no-dot-files-regexp))
      (with-temp-buffer
	(insert-file-contents file)
	(goto-char (point-min))
	(condition-case nil
	    (while t
	      (let ((form (read (current-buffer))))
		(when (and (listp form)
			   (eq (car form) 'use-package))
		  (let* ((plist (cddr form))
			 (has-ensure (plist-member plist :ensure))
			 (ensure-val (plist-get plist :ensure)))
		    (unless (and has-ensure (null ensure-val))
		      (push (cadr form) package-list))))))
	  (end-of-file))))
    (nreverse package-list)))

(defun user/elpaca-update-packages ()
  "Asynchronously update all Elpaca packages."
  (interactive)
  (let ((packages (user/get-package-list))
	(init-file (expand-file-name "init.el" user-emacs-directory)))
    (message "Updating Elpaca packages in the background...")
    (async-start
     `(lambda ()
	(require 'cl-lib)
	(load ,init-file)
	(let ((log '()))
	  (cl-labels ((log-message
			(fmt &rest args)
			(push (apply #'format fmt args) log)))
            (dolist (package ',packages)
	      (log-message "Updating %s" package)
              (elpaca-fetch package)
	      (elpaca-merge package)
	      (elpaca-rebuild package)
	      (log-message "%s updated!" package))
	    (elpaca-wait)
	    (log-message "All packages updated!")
	    (nreverse log))))
     (lambda (messages)
       (dolist (msg messages)
	 (message "%s" msg))))))


;; =======  TRANSIENT  =======
(declare-function transient-define-prefix "transient")
(defvar user/custom-functions-dispatch nil)
(transient-define-prefix
  user/custom-functions-dispatch ()
  "Display functions defined by the user."
  ["Custom Functions"
   ["Fonts"
    ("f" "Switch font" user/switch-font)
    ("r" "Random font" user/random-font)]
   ["Elpaca"
    ("m" "Update elpaca menus" user/update-elpaca-menus)
    ("p" "Update packages" user/elpaca-update-packages)]])
(keymap-global-set "C-c u" 'user/custom-functions-dispatch)


(provide '15-user-functions)
;;; 15-user-functions.el ends here
