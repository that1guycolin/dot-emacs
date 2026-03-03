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
    (defvar-keymap user/emms-playlist-mode-map
      :doc "User binds for interacting with playlists in Emms."
      :parent emms-playlist-mode-map
      :name "playlist-mode-map"
      "<SPACE>" #'emms-pause
      "m" #'emms-next
      "n" #'emms-previous
      "s" #'emms-playlist-shuffle
      "j" #'emms-seek-backward
      "k" #'emms-seek-forward
      "J" #'user/seek-backward-med
      "K" #'user/seek-forward-med
      "M-j" #'user/seek-backward-long
      "M-k" #'user/seek-forward-long
      "p" #'emms-play-playlist
      "f" #'emms-play-file
      "d" #'emms-play-find
      "C-s" #'emms-playlist-save
      "C-x n" #'emms-playlist-new
      "i" #'emms-show
      "l" #'emms-sort
      "y"#'emms-playlist-mode-yank
      "C-p" #'emms-playlist-mode-go-popup)))

(provide 'external-connections)
;;; external-connections.el ends here
