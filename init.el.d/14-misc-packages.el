;;; 14-misc-packages.el --- Misc & Dashboard -*- lexical-binding: t; -*-

;;; Packages included:
;; casual, casual-avy, dashboard, emacs-everywhere, free-keys, popper, telega

;;; Commentary:
;; Packages that don't fit nicely into another category or, as is the case with
;; dashboard, benefit from loading near the end of the startup process.

;;; Code:
;; =======  MISC  =======
;; `emacs-everywhere'
;; `free-keys' (buffer of available keybinds)
;; `popper' (keep select buffers hidden yet easily unhidden)
;; `telega' (chat in Emacs)
;; ======================
;; Configuration is done primarly in DE.
(use-package emacs-everywhere
  :config
  ;; Customizing the frame appearance for a "popup" feel
  (setq emacs-everywhere-frame-parameters
        '((name . "emacs-everywhere") (width . 80) (height . 20)
	  (menu-bar-lines . 0) (tool-bar-lines . 0)
	  (vertical-scroll-bars . nil))))

(use-package free-keys
  :defer t
  :bind ("C-c C-=" . free-keys))

(use-package popper
  :demand t
  :preface (keymap-global-unset "M-'")
  :bind
  (("C-'"   . popper-toggle)
   ("M-'"   . popper-cycle)
   ("C-M-'" . popper-toggle-type))
  :functions
  popper-mode popper-echo-mode
  :custom
  (popper-reference-buffers
   '("\\*Messages\\*" "Output\\*$" "\\*Async Shell Command\\*" help-mode
     helpful-mode compilation-mode "^\\*vterm.*\\*$" vterm-mode
     "^\\*eat.*\\*$" eat-mode free-keys-mode))
  :config
  (popper-mode +1)
  (popper-echo-mode +1))

(use-package telega
  :defer t
  :preface
  (defun user/telega-setup (&optional frame)
    "Define settings for telega."
    (with-selected-frame (or frame (selected-frame))
      (when (display-graphic-p)
        (telega-mode-line-mode 1))))
  :bind ("C-M-g" . telega)
  :functions
  telega-mode-line-mode telega-appindicator-mode
  telega-auto-download-mode telega-autoplay-mode telega-chat-auto-fill-mode
  telega-highlight-text-mode telega-notifications-mode
  telega-root-auto-fill-mode telega-transient-keymaps-mode
  
  :init
  (setq telega-use-images t)
  (if (daemonp)
      (add-hook 'after-make-frame-functions #'user/telega-setup)
    (add-hook 'telega-load-hook #'user/telega-setup))

  :config
  (telega-appindicator-mode 1)
  (telega-auto-download-mode 1)
  (telega-autoplay-mode 1)
  (telega-chat-auto-fill-mode 1)
  (telega-highlight-text-mode 1)
  (telega-notifications-mode 1)
  (telega-root-auto-fill-mode 1)
  (telega-transient-keymaps-mode 1)
  
  (message "Telega loaded successfully."))


;; =======  CASUAL  =======
;; Setup/account for functions/variables
(defvar org-agenda-mode-map)
(defvar calc-mode-map)
(defvar calc-alg-ent-map)
(defvar calendar-mode-map)
(defvar compilation-mode-map)
(defvar grep-mode-map)
(defvar css-mode-map)
(defvar csv-mode-map)
(defvar dired-mode-map)
(defvar emacs-lisp-mode-map)
(defvar eshell-mode-map)
(defvar eww-mode-map)
(defvar eww-bookmark-mode-map)
(defvar ibuffer-mode-map)
(defvar image-mode-map)
(defvar Info-mode-map)
(defvar isearch-mode-map)
(defvar makefile-mode-map)
(defvar org-mode-map)
(defvar org-table-fedit-map)
(defvar reb-mode-map)
(defvar reb-lisp-mode-map)

(declare-function org-agenda-clock-goto "org")

(declare-function compilation-previous-error "compilation-mode")
(declare-function compilation-next-error "compilation-mode")
(declare-function compilation-display-error "compilation-mode")
(declare-function compilation-previous-file "compilation-mode")
(declare-function compilation-next-file "compilation-mode")

(declare-function eww-browse-with-external-browser "eww")
(declare-function shr-next-link "eww")
(declare-function shr-previous-link "eww")
(declare-function eww-previous-url "eww")
(declare-function eww-next-url "eww")
(declare-function eww-forward-url "eww")
(declare-function eww-back-url "eww")
(declare-function eww-bookmark-browse "eww")

(declare-function ibuffer-backwards-next-marked "ibuffer")
(declare-function ibuffer-forward-next-marked "ibuffer")
(declare-function ibuffer-backward-filter-group "ibuffer")
(declare-function ibuffer-forward-filter-group "ibuffer")
(declare-function ibuffer-toggle-filter-group "ibuffer")
(declare-function ibuffer-visit-buffer "ibuffer")
(declare-function ibuffer-visit-buffer-other-window "ibuffer")

(declare-function Info-history-back "Info")
(declare-function Info-history-forward "Info")
(declare-function Info-prev "Info")
(declare-function Info-next-reference "Info")
(declare-function Info-prev-reference "Info")
(declare-function Info-next "Info")
(declare-function Info-search "Info")

;; Actual use-package object
(use-package casual
  :bind
  (("C-o" . casual-editkit-main-tmenu)
   (:map org-agenda-mode-map
         ("C-o"   . casual-agenda-tmenu))
   (:map calc-mode-map
         ("C-o"   . casual-calc-tmenu))
   (:map calc-alg-ent-map
         ("C-o"   . casual-calc-tmenu))
   (:map calendar-mode-map
         ("C-o"   . casual-calendar))
   (:map compilation-mode-map
         ("C-o"   . casual-compile-tmenu))
   (:map grep-mode-map
         ("C-o"   . casual-compile-tmenu))
   (:map css-mode-map
         ("M-m"   . casual-css-tmenu))
   (:map csv-mode-map
         ("M-m"   . casual-csv-tmenu))
   (:map dired-mode-map
         ("C-o"   . casual-dired-tmenu))
   (:map dired-mode-map
         ("s"     . casual-dired-sort-by-tmenu))
   (:map dired-mode-map
         ("/"     . casual-dired-search-replace-tmenu))
   (:map dired-mode-map
         ("C-c e" . casual-dired-elisp-tmenu))
   (:map emacs-lisp-mode-map
         ("M-m"   . casual-elisp-tmenu))
   (:map eshell-mode-map
         ("C-o"   . casual-eshell-tmenu))
   (:map eww-mode-map
         ("C-o"   . casual-eww-tmenu))
   (:map eww-bookmark-mode-map
         ("C-o"   . casual-eww-bookmarks-tmenu))
   (:map ibuffer-mode-map
         ("C-o"   . casual-ibuffer-tmenu))
   (:map ibuffer-mode-map
         ("F"     . casual-ibuffer-filter-tmenu))
   (:map ibuffer-mode-map
         ("s"     . casual-ibuffer-sortby-tmenu))
   (:map image-mode-map
         ("C-o"   . casual-image-tmenu))
   (:map Info-mode-map
         ("C-o"   . casual-info-tmenu))
   (:map isearch-mode-map
         ("C-o"   . casual-isearch-tmenu))
   (:map makefile-mode-map
         ("M-m"   . casual-make-tmenu))
   (:map org-mode-map
         ("M-m"   . casual-org-tmenu))
   (:map org-table-fedit-map
         ("M-m"   . casual-org-table-fedit-tmenu))
   (:map reb-mode-map
         ("C-o"   . casual-re-builder-tmenu))
   (:map reb-lisp-mode-map
         ("C-o"   . casual-re-builder-tmenu)))
  :functions
  casual-ediff-install casual-ediff-tmenu casual-editkit-windows-tmenu
  casual-editkit-rectangle-tmenu casual-editkit-registers-tmenu
  casual-editkit-project-tmenu casual-lib-browse-forward-paragraph
  casual-lib-browse-backward-paragraph casual-eww-backward-paragraph-link
  casual-eww-forward-paragraph-link casual-info-browse-backward-paragraph
  casual-info-browse-forward-paragraph
  :defines ediff-mode-map
  :config
  (casual-ediff-install)
  (add-hook 'ediff-keymap-setup-hook
	    #'(lambda ()
		(keymap-set ediff-mode-map "C-o" #'casual-ediff-tmenu)))

  (bind-keys
   ("C-c w"              . casual-editkit-windows-tmenu)
   ("M-r"                . casual-editkit-rectangle-tmenu)
   ("C-c g"              . casual-editkit-registers-tmenu)
   ("C-c p"              . casual-editkit-project-tmenu)
   :map org-agenda-mode-map
   ("M-j"                . org-agenda-clock-goto)
   ("J"                  . bookmark-jump)
   :map compilation-mode-map
   ("k"                  . compilation-previous-error)
   ("j"                  . compilation-next-error)
   ("o"                  . compilation-display-error)
   ("["                  . compilation-previous-file)
   ("]"                  . compilation-next-file)
   :map grep-mode-map
   ("k"                  . compilation-previous-error)
   ("j"                  . compilation-next-error)
   ("o"                  . compilation-display-error)
   ("["                  . compilation-previous-file)
   ("]"                  . compilation-next-file)
   :map eww-mode-map
   ("C-c C-o"            . eww-browse-with-external-browser)
   ("j"                  . shr-next-link)
   ("k"                  . shr-previous-link)
   ("["                  . eww-previous-url)
   ("]"                  . eww-next-url)
   ("M-]"                . eww-forward-url)
   ("M-["                . eww-back-url)
   ("n"                  . casual-lib-browse-forward-paragraph)
   ("p"                  . casual-lib-browse-backward-paragraph)
   ("P"                  . casual-eww-backward-paragraph-link)
   ("N"                  . casual-eww-forward-paragraph-link)
   ("M-l"                . eww)
   :map eww-bookmark-mode-map
   ("p"                  . previous-line)
   ("n"                  . next-line)
   ("<double-mouse-1>"   . eww-bookmark-browse)
   :map ibuffer-mode-map
   ("{"                  . ibuffer-backwards-next-marked)
   ("}"                  . ibuffer-forward-next-marked)
   ("["                  . ibuffer-backward-filter-group)
   ("]"                  . ibuffer-forward-filter-group)
   ("$"                  . ibuffer-toggle-filter-group)
   ("<double-mouse-1>"   . ibuffer-visit-buffer)
   ("M-<double-mouse-1>" . ibuffer-visit-buffer-other-window)
   :map Info-mode-map
   ("M-["                . Info-history-back)
   ("M-]"                . Info-history-forward)
   ("p"                  . casual-info-browse-backward-paragraph)
   ("n"                  . casual-info-browse-forward-paragraph)
   ("h"                  . Info-prev)
   ("j"                  . Info-next-reference)
   ("k"                  . Info-prev-reference)
   ("l"                  . Info-next)
   ("/"                  . Info-search)
   ("B"                  . bookmark-set)))

(use-package casual-avy
  :bind ("M-g" . casual-avy-tmenu))


;; =======  DASHBOARD  =======
(declare-function user/function-after-emacsclient-frame "01-bootstrap-core.el")

(use-package dashboard
  :demand t
  :functions
  dashboard-insert-startupify-lists dashboard-initialize
  dashboard-setup-startup-hook dashboard-refresh-buffer
  dashboard-display-icons-p

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
  (dashboard-items `((agenda   . 5)
		     (projects . ,(length (project-known-project-roots)))
		     (recents  . 5)))
  
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook)
  (setq inhibit-redisplay nil)

  (add-hook 'server-after-make-frame-hook
	    #'(lambda ()
		(user/function-after-emacsclient-frame
		 #'dashboard-refresh-buffer))))


(provide '14-misc-packages)
;;; 14-misc-packages.el ends here
