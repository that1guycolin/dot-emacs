;;; external-connections.el --- External integrations (Org, EMMS) -*- lexical-binding: t; -*-

;;; Commentary:
;; Configure external integrations: Org-mode for notes/agenda/capture,
;; and EMMS as a system-wide media library using mpv as the player.

;;; Packages included:
;; org, emms

;;; Code:
;; =======  ORG  =======
(use-package org
  :elpaca (org
           :repo "https://git.savannah.gnu.org/git/emacs/org-mode.git"
           :branch "main"
	   :build (:not elpaca--compile-info))
  :bind
  ("C-c o" . org-mode)
  ("C-c C-l" . org-store-link)
  ("C-c a" . org-agenda)
  ("C-c c" . org-capture)
  :mode ("\\.org\\'" . org-mode))



;; =======  EMMS  =======
(defun user/seek-backward-med ()
  "Seek backwards 30 seconds in Emms."
  (interactive)
  (emms-seek -30))

(defun user/seek-forward-med ()
  "Seek forward 30 seconds in Emms."
  (interactive)
  (emms-seek 30))

(defun user/seek-backward-long ()
  "Seek backwards 2 minutes in Emms."
  (interactive)
  (emms-seek (* -2 60)))

(defun user/seek-forward-long ()
  "Seek forward 2 minutes in Emms."
  (interactive)
  (emms-seek (* 2 60)))

(declare-function defhydra "hydra")
(use-package emms
  :defer t
  :bind (("<f6>" . emms-browser)
         ("<f7>" . emms-playlist-mode-go))
  :functions (emms-all
	      emms-default-players
	      emms-seek
	      user/emms-playlist-map)
  :defines user-playlist-cmd
  :config
  (require 'emms-setup)
  (emms-all)
  (setq emms-player-list '(emms-player-mpv))
  (setq emms-player-mpv-parameters '("--force-window=yes"))
  (defhydra user-playlist-cmd (:hint nil :color pink)
    "Custom hydra for user-preferred keybindings in Emms playlist mode."
    ("SPC" emms-pause)
    ("m" emms-next )
    ("n" emms-previous)
    ("s" emms-playlist-shuffle)
    ("j" emms-seek-backward)
    ("k" emms-seek-forward)
    ("J" user/seek-backward-med)
    ("K" user/seek-forward-med)
    ("M-j" user/seek-backward-long)
    ("M-k" user/seek-forward-long)
    ("p" emms-play-playlist :exit t)
    ("f" emms-play-file :exit t)
    ("d" emms-play-find :exit t)
    ("C-s" emms-playlist-save :exit t)
    ("C-x n" emms-playlist-new :exit t)
    ("i" emms-show)
    ("l" emms-sort)
    ("y" emms-playlist-mode-yank)
    ("C-p" emms-playlist-mode-go-popup))
  (bind-keys :map emms-playlist-mode-map
	     ("<space>" . user-playlist-cmd/body)))

(provide 'external-connections)
;;; external-connections.el ends here
