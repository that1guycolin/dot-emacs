;;; 15-install-themes.el --- Install themes -*- lexical-binding: t; -*-

;;; Themes included:
;; ancient-one-dark, caroline, curry-on, dakrone, darkokai, dream, edna,
;; evangelion, fantom, foggy-night, gotham, iceberg, idea-darkula, madhat2r,
;; material, miasma, monokai-alt, morrowind, night-owl, nordic-night, nord,
;; oblivion, obsidian, overcast, planet, purple-haze, rebecca, reykjavik,
;; simplicity, starlit, vscode-dark-plus, weyland-yutani, zerodark

;;; Commentary:
;; Define a custom list of themes and install them with elpaca.

;;; Code:
;; =======  THEME  =======
;; Themes list
(defvar user/themes-list
  '(weyland-yutani
    ancient-one-dark caroline curry-on dakrone darkokai dream edna evangelion
    fantom foggy-night gotham iceberg idea-darkula madhat2r material miasma
    monokai-alt morrowind night-owl nordic-night nord oblivion obsidian overcast
    planet purple-haze rebecca reykjavik simplicity starlit vscode-dark-plus
    zerodark)
  "Custom list of themes defined by user.")

(defun user/get-themes ()
  "Get full names of themes in `user/themes-list'."
  (let ((theme-symbols '()))
    (dolist (theme user/themes-list)
      (let* ((theme-name-full (concat (symbol-name theme) "-theme"))
	     (theme-symbol (intern theme-name-full)))
	(push theme-symbol theme-symbols)))
    (nreverse theme-symbols)))

;; Install themes
(declare-function elpaca-wait "elpaca")
(dolist (theme (user/get-themes))
  (eval `(elpaca ,theme)))

(elpaca-wait)
(load-theme 'weyland-yutani t)


(provide '15-install-themes)
;;; 15-install-themes.el ends here.
