;;; 12-media-player.el --- Listen to music & watch videos -*- lexical-binding: t; -*-

;;; Commentary:
;; Uses the package `emms' to allow video/audio playback and control via Emacs.
;; Requires FFmpeg & mpv.

;;; Code:
(use-package emms
  :defer t
  :bind ("<f6>" . emms-browser)

  :functions
  emms-all
  emms-seek
  emms-player-mpv-pause
  emms-player-mpv-resume
  user/toggle-play-pause
  emms-pause
  emms-next
  emms-previous
  emms-playlist-shuffle
  emms-seek-backward
  emms-seek-forward
  user/seek-backward-med
  user/seek-forward-med
  user/seek-backward-long
  user/seek-forward-long
  emms-play-playlist
  emms-play-file
  emms-play-find
  emms-playlist-save
  emms-playlist-new
  emms-show
  emms-sort
  emms-playlist-mode-yank
  emms-playlist-mode-go-popup

  :defines
  emms-info-functions
  emms-playlist-mode-map

  :custom
  (emms-info-functions )
  :config
  (require 'emms-setup)
  (emms-all)
  (require 'emms-player-mpv)
  (setq emms-player-list '(emms-player-mpv))

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

  (defvar user/player-is-playing nil
    "Non-nil if Emms player is not paused.")

  (defun user/toggle-play-pause ()
    "If player is playing, pause it.  If it is paused, start playing."
    (interactive)
    (if user/player-is-playing
	(progn
	  (emms-player-mpv-pause)
	  (setq user/player-is-playing nil))
      (progn
	(emms-player-mpv-pause))))

  (bind-keys
   :map emms-playlist-mode-map
   ("SPC"   . user/toggle-play-pause)
   ("m"     . emms-next)
   ("n"     . emms-previous)
   ("s"     . emms-playlist-shuffle)
   ("j"     . emms-seek-backward)
   ("k"     . emms-seek-forward)
   ("J"     . user/seek-backward-med)
   ("K"     . user/seek-forward-med)
   ("M-j"   . user/seek-backward-long)
   ("M-k"   . user/seek-forward-long)
   ("p"     . emms-play-playlist)
   ("f"     . emms-play-file)
   ("d"     . emms-play-find)
   ("C-s"   . emms-playlist-save)
   ("C-x n" . emms-playlist-new)
   ("i"     . emms-show)
   ("l"     . emms-sort)
   ("y"     . emms-playlist-mode-yank)
   ("C-p"   . emms-playlist-mode-go-popup)))

(use-package emms-info-mediainfo
  :ensure (emms-info-mediainfo
	   :host github
	   :repo "that1guycolin/emms-info-mediainfo")
  :after emms
  :config
  (setq emms-info-backends '(emms-info-mediainfo)))


(provide '12-media-player)
;;; 12-media-player.el ends here
