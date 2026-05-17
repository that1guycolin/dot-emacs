;;; 10-file-management.el --- File explorer functions -*- lexical-binding: t; -*-

;;; Packages included:
;; async, dired, diredfl, dired-preview, dired-quick-sort, dired-subtree,
;; dwim-shell-command, nerd-icons-dired, ready-player

;;; Commentary:
;; Leverage Dired built-in settings & extensions to provide a functional file
;; explorer inside Emacs.

;;; Code:
(use-package dired
  :ensure nil
  :bind ("C-x d" . dired)
  :functions
  dired-omit-mode dired-next-dirline dired-prev-dirline dired-next-subdir
  dired-prev-subdir dired-next-marked-file dired-prev-marked-file
  dired-goto-subdir image-dired-display-next image-dired-display-previous
  :defines image-dired-thumbnail-mode-map
  :config
  (require 'dired-x)
  (require 'wdired)
  (require 'image-dired)
  (require 'image-dired-dired)

  (add-hook 'dired-mode-hook
	    #'(lambda ()
		(hl-line-mode)
		(context-menu-mode)
		(setq-local mouse-1-click-follows-link 'double)))
  (bind-keys
   :map dired-mode-map
   ("M-o"           . dired-omit-mode)
   ("E"             . wdired-change-to-wdired-mode)
   ("M-n"           . dired-next-dirline)
   ("M-p"           . dired-prev-dirline)
   ("]"             . dired-next-subdir)
   ("["             . dired-prev-subdir)
   ("M-]"           . dired-next-marked-file)
   ("M-["           . dired-prev-marked-file)
   ("A-M-<mouse-1>" . browse-url-of-dired-file)
   ("<backtab>"     . dired-prev-subdir)
   ("TAB"           . dired-next-subdir)
   ("M-j"           . dired-goto-subdir)
   (";"             . image-dired-dired-toggle-marked-thumbs)
   :map image-dired-thumbnail-mode-map
   ("n"             . image-dired-display-next)
   ("p"             . image-dired-display-previous)))

(use-package nerd-icons-dired
  :defer t
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package dired-quick-sort
  :after dired
  :functions dired-quick-sort-setup
  :init
  (dired-quick-sort-setup)
  :config
  (with-eval-after-load 'casual-dired
    (transient-append-suffix 'casual-dired-tmenu "s"
      '("S" "Dired Quick-Sort" dired-quick-sort-transient))))

(use-package async
  :defer t
  :commands async-start async-start-process
  :hook (dired-mode . dired-async-mode)
  :init
  (require 'dired-async))

(use-package diredfl
  :defer t
  :hook (dired-mode . diredfl-mode))

(declare-function transient-define-prefix "transient")
(use-package dired-subtree
  :after dired
  :functions user/dired-subtree-dispatch
  :config
  (defvar user/dired-subtree-dispatch)
  (transient-define-prefix user/dired-subtree-dispatch ()
    "Custom transient dispatch containing functions for dired-subtree."
    ["Dired Subtree"
     [("i" "Insert"              dired-subtree-insert)
      ("r" "Remove"              dired-subtree-remove)
      ("t" "Toggle"              dired-subtree-toggle)
      ("c" "Cycle"               dired-subtree-cycle)
      ("R" "Revert"              dired-subtree-revert)
      ("n" "Narrow"              dired-subtree-narrow)
      ("^" "Up"                  dired-subtree-up)
      ("M-L" "Down"              dired-subtree-down)]
     [("C-n" "Next Sibling"      dired-subtree-next-sibling)
      ("C-p" "Prev. Sibling"     dired-subtree-previous-sibling)
      ("<" "Beginning"           dired-subtree-beginning)
      (">" "End"                 dired-subtree-end)
      ("m" "Mark"                dired-subtree-mark-subtree)
      ("u" "Unmark"              dired-subtree-unmark-subtree)
      ("." "Only This File"      dired-subtree-only-this-file)
      ("+" "Only This Directory" dired-subtree-only-this-directory)]])
  (bind-keys
   :map dired-mode-map
   ("TAB" . user/dired-subtree-dispatch))
  (with-eval-after-load 'casual-dired
    (transient-append-suffix 'casual-dired-tmenu "M-n"
      '("TAB" "Dired Subtree" user/dired-subtree-dispatch))))

(use-package dired-preview
  :defer t
  :hook (dired-mode . dired-preview-mode)
  :functions
  dired-preview-find-file dired-preview-open-dwim dired-preview-page-up
  dired-preview-page-down
  :config
  (bind-keys
   :map dired-mode-map
   ("C-m"   . dired-preview-find-file)
   ("C-M-o" . dired-preview-open-dwim)
   ("C-M-p" . dired-preview-page-up)
   ("C-M-n" . dired-preview-page-down)))

(use-package ready-player
  :defer t
  :hook (dired-hook . ready-player-mode)
  :config
  (ready-player-mode +1))

(use-package dwim-shell-command
  :after dired
  :functions
  dwim-shell-command dwim-shell-command-on-marked-files user/convert-ts-to-mp4
  user/extract-video-only user/extract-audio-only
  
  :config
  (bind-keys
   ([remap shell-command] . dwim-shell-command)
   :map dired-mode-map
   ([remap dired-do-async-shell-command] . dwim-shell-command)
   ([remap dired-do-shell-command]       . dwim-shell-command)
   ([remap dired-smart-shell-command]    . dwim-shell-command))
  (defun user/convert-ts-to-mp4 ()
    "Convert .ts files to .mp4 using FFmpeg."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Convert to mp4"
     "ffmpeg -hide_banner -v quiet -stats -y -i '<<f>>' -map 0:v -map 0:a \
-c copy -movflags +faststart '<<fne>>.mp4'"
     :utils "ffmpeg"))

  (defun user/extract-video-only ()
    "Extract only video streams from file using FFmpeg."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Extract video streams."
     "ffmpeg -hide_banner -v quiet -stats -y -i '<<f>>' -map 0:v -c copy \
-movflags +faststart '<<fne>>-video.mp4'"
     :utils "ffmpeg"))

  (defun user/extract-audio-only ()
    "Extract only audio streams from file using FFmpeg."
    (interactive)
    (dwim-shell-command-on-marked-files
     "Extract audio streams."
     "ffmpeg -hide_banner -v quiet -stats -y -i '<<f>>' -map 0:a -c copy \
-movflags +faststart '<<fne>>-audio.m4a'"
     :utils "ffmpeg"))

  (defvar-keymap user/dired-ffmpeg-actions-map
    :prefix t
    :doc "Keymap with FFmpeg actions to run on marked files in dired/dirvish."
    "4" #'user/convert-ts-to-mp4
    "v" #'user/extract-video-only
    "a" #'user/extract-audio-only))


(provide '10-file-management)
;;; 10-file-management.el ends here
