;;; 13-media-player.el --- Listen to music & watch videos -*- lexical-binding: t; -*-

;;; Packages included:
;; emms, emms-info-mediainfo

;;; Commentary:
;; Uses the package `emms' to allow video/audio playback and control via Emacs.
;; Requires FFmpeg, mediainfo, & mpv.

;;; Code:
(use-package emms
  :defer t
  :bind
  (("<f6>"    . emms-browser)
   ("C-c m b" . emms-browser)
   ("<f7>"    . emms-smart-browse)
   ("C-c m s" . emms-smart-browse))

  :functions
  emms-all emms-seek emms-player-mpv-pause emms-player-mpv-resume
  user/toggle-play-pause emms-playlist-mode-go emms-playlist-mode-go-popup
  emms-pause emms-next emms-previous emms-playlist-shuffle emms-seek-backward
  emms-seek-forward user/seek-backward-med user/seek-forward-med
  user/seek-backward-long user/seek-forward-long emms-play-playlist
  emms-play-file emms-play-find emms-playlist-save emms-playlist-new emms-show
  emms-sort emms-playlist-mode-yank

  :defines
  emms-info-functions emms-playlist-mode-map emms-player-mpv-command-name
  emms-player-mpv-parameters emms-browser-default-browse-type
  emms-browser-info-title-format

  :init
  (require 'emms-setup)
  
  :config
  (emms-all)
  (setq emms-info-functions '(emms-info-native emms-info-exiftool)
	emms-player-list '(emms-player-mpv)
	emms-player-mpv-command-name "mpv"
	emms-player-mpv-parameters '("--force-window=yes"))
  
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
   ("<f8>"    . emms-playlist-mode-go)
   ("C-c m g" . emms-playlist-mode-go)
   ("<f9>"    . emms-playlist-mode-go-popup)
   ("C-c m p" . emms-playlist-mode-go-popup)
   
   :map emms-playlist-mode-map
   ("SPC"     . user/toggle-play-pause)
   ("m"       . emms-next)
   ("n"       . emms-previous)
   ("s"       . emms-playlist-shuffle)
   ("j"       . emms-seek-backward)
   ("k"       . emms-seek-forward)
   ("J"       . user/seek-backward-med)
   ("K"       . user/seek-forward-med)
   ("M-j"     . user/seek-backward-long)
   ("M-k"     . user/seek-forward-long)
   ("p"       . emms-play-playlist)
   ("f"       . emms-play-file)
   ("d"       . emms-play-find)
   ("C-s"     . emms-playlist-save)
   ("C-x n"   . emms-playlist-new)
   ("i"       . emms-show)
   ("l"       . emms-sort)
   ("y"       . emms-playlist-mode-yank)))

(use-package emms-info-mediainfo
  :ensure (emms-info-mediainfo
	   :host github
	   :repo "that1guycolin/emms-info-mediainfo"
	   :files (:defaults)
	   :method https
	   :wait t)
  :after emms
  :config
  (setq emms-info-functions (append '(emms-info-mediainfo) emms-info-functions)))


(provide '13-media-player)
;;; 13-media-player.el ends here
