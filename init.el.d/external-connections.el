;;; external-connections.el --- External integrations (Org, EMMS) -*- lexical-binding: t; -*-

;;; Commentary:
;; Configure external integrations: Org-mode for notes/agenda/capture,
;; and EMMS as a system-wide media library using mpv as the player.

;;; Packages included:
;; org, emms

;;; Code:
;; Org-mode
(use-package org
  :elpaca (org
           :repo "https://git.savannah.gnu.org/git/emacs/org-mode.git"
           :branch "main"
	   :build (:not elpaca--compile-info))
  :mode ("\\.org\\'" . org-mode)
  :config
  (keymap-global-set "C-c o" #'org-mode)
  (keymap-global-set "C-c C-l" #'org-store-link)
  (keymap-global-set "C-c a" #'org-agenda)
  (keymap-global-set "C-c c" #'org-capture))

;; Emms
(defun user/seek-backward-med ()
  "Seek backward 30 seconds in Emms."
  (emms-seek -30))

(defun user/seek-forward-med ()
  "Seek forward 30 seconds in Emms."
  (emms-seek 30))

(defun user/seek-backward-long ()
  "Seek background 2 minutes in Emms."
  (emms-seek '(* -2 60)))

(defun user/seek-forward-long ()
  "Seek forward 2 minutes in Emms."
  (emms-seek '(* 2 60)))

(use-package emms
  :defer t
  :bind (("<f6>" . emms-browser)
         ("<f7>" . emms-playlist-mode-go))
  :functions (emms-all emms-default-players emms-seek)
  :custom
  (emms-player-list '(emms-player-mpv))
  (emms-player-mpv-parameters '("--force-window=yes"))
  :config
  (require 'emms-playlist-mode)
  (with-eval-after-load 'emms-playlist-mode
    (define-key emms-playlist-mode-map (kbd "<SPACE>") #'emms-pause)
    (define-key emms-playlist-mode-map (kbd "m") #'emms-next)
    (define-key emms-playlist-mode-map (kbd "n") #'emms-previous)
    (define-key emms-playlist-mode-map (kbd "s") #'emms-playlist-shuffle)
    (define-key emms-playlist-mode-map (kbd "j") #'emms-seek-backward)
    (define-key emms-playlist-mode-map (kbd "k") #'emms-seek-forward)
    (define-key emms-playlist-mode-map (kbd "J") #'user/seek-backward-med)
    (define-key emms-playlist-mode-map (kbd "K") #'user/seek-forward-med)
    (define-key emms-playlist-mode-map (kbd "M-j") #'user/seek-backward-long)
    (define-key emms-playlist-mode-map (kbd "M-k") #'user/seek-forward-long)
    (define-key emms-playlist-mode-map (kbd "p") #'emms-play-playlist)
    (define-key emms-playlist-mode-map (kbd "f") #'emms-play-file)
    (define-key emms-playlist-mode-map (kbd "d") #'emms-play-find)
    (define-key emms-playlist-mode-map (kbd "C-s") #'emms-playlist-save)
    (define-key emms-playlist-mode-map (kbd "C-x n") #'emms-playlist-new)
    (define-key emms-playlist-mode-map (kbd "i") #'emms-show)
    (define-key emms-playlist-mode-map (kbd "l") #'emms-sort)
    (define-key emms-playlist-mode-map (kbd "y") #'emms-playlist-mode-yank)
    (define-key emms-playlist-mode-map (kbd "C-p")
		#'emms-playlist-mode-go-popup)))

(provide 'external-connections)
;;; external-connections.el ends here
