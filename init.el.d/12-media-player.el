;;; 12-media-player.el --- Listen to music & watch videos -*- lexical-binding: t; -*-

;;; Commentary:
;; Uses the package `emms' to allow video/audio playback and control via Emacs.
;; Requires FFmpeg, mediainfo, & mpv.

;;; Code:
(use-package emms
  :defer t
  :bind
  (("<f6>"    . emms-browse)
   ("C-c p b" . emms-browse)
   ("<f7>"    . emms-smart-browse)
   ("C-c p s" . emms-smart-browse))

  :functions
  user/emms-browser-safe-spec
  emms-browser-bdata-data
  emms-track-get
  emms-track-p
  user/seconds-to-duration
  user/emms-track-description
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
  emms-player-mpv-command-name
  emms-player-mpv-parameters
  emms-browser-default-browse-type
  emms-browser-info-title-format

  :init
  (require 'emms-setup)
  
  :config
  (emms-all)
  (setq emms-info-functions '(emms-info-native emms-info-exiftool)
	emms-player-list '(emms-player-mpv)
	emms-player-mpv-command-name "mpv"
	emms-player-mpv-parameters '("--force-window=yes")
	emms-browser-default-browse-type 'info-album
	emms-browser-info-title-format "%i%t (%d)")

  (defun user/emms-browser-safe-spec (orig-fun format spec-alist)
    "Advice for `emms-browser-format-spec' to provide extra track metadata.

This function extracts the EMMS track data at the current line and
augments SPEC-ALIST with the following keys:
  ?t -> The track title (falling back to the filename if unavailable).
  ?d -> The track duration formatted as \='MM:SS' (falling back to \='??').

ORIG-FUN is the original `emms-browser-format-spec`, which is called
with the updated SPEC-ALIST and the original FORMAT string."
    (let* ((bdata (get-text-property
                   (line-beginning-position) 'emms-browser-bdata))
           (tracks (and bdata (emms-browser-bdata-data bdata)))
           (track (when (consp tracks) (car tracks))))
      (when (and track (emms-track-p track))
	(setq spec-alist
              (cons (cons ?t (or (emms-track-get track 'info-title "")
				 (file-name-nondirectory
                                  (emms-track-get track 'name ""))))
                    spec-alist))
	(let* ((dur-sec (or (emms-track-get track 'info-playing-time 0)
                            (let ((m (or (emms-track-get
                                          track 'info-playing-time-min 0) 0))
                                  (s (or (emms-track-get
                                          track 'info-playing-time-sec 0) 0)))
                              (+ (* m 60) s))))
               (dur-str (if (> dur-sec 0)
                            (format "%02d:%02d" (/ dur-sec 60) (% dur-sec 60))
                          "??")))
          (setq spec-alist (cons (cons ?d dur-str) spec-alist))))
      (funcall orig-fun format spec-alist)))

  (advice-add 'emms-browser-format-spec :around #'user/emms-browser-safe-spec)
  
  (defun user/seconds-to-duration (seconds)
    "Convert SECONDS into H:MM:SS string."
    (let* ((hours   (/ seconds 3600))
           (minutes (/ (% seconds 3600) 60))
           (secs    (% seconds 60)))
      (format "%d:%02d:%02d" hours minutes secs)))

  (defun user/emms-track-description (track)
    "Format TRACK as: ALBUM - TITLE (DURATION).
If TITLE is missing, use filename.  If ALBUM is missing, omit it."
    (let* ((album   (emms-track-get track 'info-album))
           (title   (or (emms-track-get track 'info-title)
			(file-name-nondirectory
			 (emms-track-get track 'info-file))))
           (duration (user/seconds-to-duration
                      (or (emms-track-get track 'info-playing-time) 0)))
           (album-part (if album (concat album " - ") ""))
           (title-part (if title (concat title " (" duration ")") duration)))
      (concat album-part title-part)))

  (setq emms-track-description-function #'user/emms-track-description)
  
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
  
  (defun user/function-if-playlist (func)
    "Run FUNC if an `emms-playlist-buffer' exists.
This wrapper function has fallback in case emms-playlist-buffer not defined."
    (cond
     ((and (fboundp emms-playlist-buffer)
	   (buffer-live-p emms-playlist-buffer))
      (funcall func))
     ((fboundp emms-playlist-buffer)
      (message "No playlist buffer exists."))
     (t
      (message "EMMS is not active."))))

  (bind-keys
   ("<f8>"    . (user/function-if-playlist #'emms-playlist-mode-go))
   ("C-c p g" . (user/function-if-playlist #'emms-playlist-mode-go))
   ("<f9>"    . (user/function-if-playlist #'emms-playlist-mode-go-popup))
   ("C-c p p" . (user/function-if-playlist #'emms-playlist-mode-go-popup))
   
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
	   :method https)
  :after emms
  :config
  (defvar user/temp-info-functions emms-info-functions
    "Placeholder to append current `emms-info-functions' to end of that list.")
  (setq emms-info-functions '(emms-info-mediainfo))
  (append emms-info-functions user/temp-info-functions))


(provide '12-media-player)
;;; 12-media-player.el ends here
