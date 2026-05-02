;;; 15-user-functions.el --- Custom variables & functions -*- lexical-binding: t; -*-

;;; Commentary:
;; Variables, functions, and transient dispatches defined by the user.
;; Items in this file either have no natural home elsewhere in the configuration,
;; or, more likely, need to be loaded last.

;;; Code:
;; =======  HELPER FUNCTIONS  =======
(defun user/pick-random (lst)
  "Return a random element from LST (list)."
  (nth (random (length lst)) lst))

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
    (mapc #'disable-theme custom-enabled-themes)
    (unless (member theme-directory custom-theme-load-path)
      (add-to-list 'custom-theme-load-path theme-directory))
    (load-theme theme t)
    (message "Loaded theme: %s" theme)))

(defun user/cycle-themes ()
  "Cycle through themes in `user/themes-list'."
  (interactive)
  (setq user/themes-index
        (mod (1+ user/themes-index) (length user/themes-list)))
  (let ((theme (nth user/themes-index user/themes-list)))
    (user/smart-load-theme theme)))

(defun user/select-theme (theme)
  "Switch to a THEME from `user/themes-list'."
  (interactive
   (list (intern (completing-read "Select theme: "
				  user/themes-list nil t))))
  (let ((new-index (seq-position user/themes-list theme)))
    (when new-index
      (setq user/themes-index new-index)
      (user/smart-load-theme theme))))

(defun user/random-theme ()
  "Activate a random theme from `user/themes-list'."
  (interactive)
  (let* ((theme (user/pick-random user/themes-list))
	 (new-index (seq-position user/themes-list theme)))
    (when new-index
      (setq user/themes-index new-index)
      (user/smart-load-theme theme))))


;; =======  FONTS  =======
(defvar user/font-height-alist
  '(("BlexMono Nerd Font Mono"         . 110)
    ("DaddyTimeMono Nerd Font Mono"    . 110)
    ("FantasqueSansM Nerd Font Mono"   . 110)
    ("IntoneMono Nerd Font Mono"       . 110)
    ("RecMonoCasual Nerd Font Mono"    . 110)
    ("SauceCodePro Nerd Font Mono"     . 110))
  "List of cons cells mapping nerd font families to their ideal height.")

(defun user/switch-font (font)
  "Set global \"face-attribute\" :font-family to FONT.
Also sets global \"face-attribute\" :height to value mapped in
user/font-height-alist."
  (interactive
   (list (completing-read
	  "Font: "
	  (mapcar #'car user/font-height-alist)
	  nil t)))
  (let ((height (cdr (assoc font user/font-height-alist))))
    (set-face-attribute 'default nil
                        :family font
                        :height height
                        :weight 'regular)
    (run-hooks 'after-setting-font-hook)
    (message "Font set to %s" font)))

(defun user/random-font ()
  "Activate a random font from `user/font-height-alist'."
  (interactive)
  (let* ((font-cons (user/pick-random user/font-height-alist))
	 (font-family (car font-cons))
	 (font-height (cdr font-cons)))
    (set-face-attribute 'default nil
			:family font-family
			:height font-height
			:weight 'regular)
    (run-hooks 'after-setting-font-hook)
    (message "Loaded font: %s" font-family)))


;; =======  SIDE-WINDOW  =======
(defun user/toggle-side-window ()
  "Switch focus between a side window and the main window area.
If in a side window, return to the last used window.
If not in a side window, jump to the first found side window."
  (interactive)
  (let* ((side-window (cl-find-if (lambda (w) (window-parameter w 'window-side))
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

(defvar user-init-directory)
(defun user/get-init-files ()
  "Return a list of all files in `user/init-directory'."
  (let* ((get-files-command (format "ls %s" user-init-directory))
	 (directory-string (shell-command-to-string get-files-command)))
    (split-string directory-string)))

(defun user/get-package-list ()
  "Return packages installed with elpaca-use-package as strings."
  (let ((package-list '()))
    (dolist (file (user/get-init-files))
      (let* ((script (expand-file-name "tools/list-use-packages.el"
				       user-emacs-directory))
	     (get-packages-command (format "emacs --script %s %s" script file))
	     (packages-string (shell-command-to-string get-packages-command))
	     (package-split-string (split-string packages-string)))
	(dolist (package package-split-string)
	  (push (intern package) package-list))))
    (nreverse package-list)))

(declare-function user/get-themes "15-install-themes")
(defun user/packages-themes ()
  "Return a list of installed packages & themes."
  (let* ((packages (user/get-package-list))
	 (themes (user/get-themes)))
    (append packages themes)))

(defun user/elpaca-update-packages ()
  "Asynchronously update all Elpaca packages."
  (interactive)
  (let ((packages (user/packages-themes))
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
    ("f" "Switch font" user/switch-font)
    ("R" "Random font" user/random-font)]
   [("c" "Cycle themes" user/cycle-themes)
    ("t" "Select theme" user/select-theme)
    ("r" "Random theme" user/random-theme)]
   [("E" "Update elpaca menus" user/update-elpaca-menus)
    ("p" "Update packages" user/elpaca-update-packages)
    ("s" "Major -ts-mode fallback" user/major-ts-mode-fallback)]])
(declare-function user/custom-functions-dispatch "15-user-functions")
(bind-keys ("C-c u" . user/custom-functions-dispatch))


(provide '15-user-functions)
;;; 15-user-functions.el ends here
