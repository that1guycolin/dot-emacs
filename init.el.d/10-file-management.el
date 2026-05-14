;;; 10-file-management.el --- File explorer functions -*- lexical-binding: t; -*-

;;; Packages included:
;; async, dired, diredfl, dired-preview, dwim-shell-command, ready-player-mode

;;; Commentary:
;; Leverage Dired built-in settings & extensions to provide a functional file
;; explorer inside Emacs.

;;; Code:
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

(use-package dired-preview
  :after dired
  :functions
  dired-preview-find-file dired-preview-open-dwim dired-preview-page-up
  dired-preview-page-down
  :config
  (bind-keys
   :map dired-mode-map
   ("C-m" . dired-preview-find-file)
   ("P"   . dired-preview-open-dwim)
   ("C-M-p" . dired-preview-page-up)
   ("C-M-n" . dired-preview-page-down)))

(use-package ready-player
  :after dired
  :functions ready-player-mode
  :config
  (ready-player-mode +1))

(use-package diredfl
  :after dired
  :functions diredfl-mode
  :config
  (diredfl-mode 1))

(use-package async
  :defer t
  :commands async-start async-start-process
  :hook (dired-mode . dired-async-mode)
  :init
  (require 'dired-async))

(declare-function transient-define-prefix "transient")
(defvar user/dired-dispatch)
(with-eval-after-load 'dired
  (transient-define-prefix user/dired-dispatch ()
    "Display standard dired keybindings in a helpful transient menu."
    ["Dired"
     ["Navigation"
      :pad-keys t
      ("<" "Prev. Dirline"              dired-prev-dirline)
      (">" "Next Dirline"               dired-next-dirline)
      ("p" "Prev. Line"                 dired-previous-line)
      ("n" "Next Line"                  dired-next-line)
      ("S-SPC" "Prev. Line"             dired-previous-line)
      ("SPC" "Next Line"                dired-next-line)
      ("^" "Up Directory"               dired-up-directory)
      ("M-G" "Goto Subdir"              dired-goto-subdir)
      "Tree Commands"
      ("C-M-d" "Tree Down"              dired-tree-down)
      ("C-M-u" "Tree Up"                dired-tree-up)
      ("C-M-p" "Prev. Subdir."          dired-prev-subdir)
      ("C-M-n" "Next Subdir."           dired-next-subdir)]
     ["File Operations"
      :pad-keys t
      ("a" "Find Alternate"             dired-find-alternate-file)
      ("d" "Flag for Deletion"          dired-flag-file-deletion)
      ("e" "Find File"                  dired-find-file)
      ("C-m" "Preview Find File"        dired-preview-find-file)
      ("o" "Find (Other Window)"        dired-find-file-other-window)
      ("f 4" "Convert .ts To .mp4"      user/convert-ts-to-mp4)
      ("f v" "Extract Video"            user/extract-video-only)
      ("f a" "Extract Audio"            user/extract-audio-only)
      ("C-M-p" "Preview Page Up"        dired-preview-page-up)
      ("C-M-n" "Preview Page Down"      dired-preview-page-down)
      ("g" "Revert Buffer"              revert-buffer)
      ("i" "Insert Subdir."             dired-maybe-insert-subdir)]
     ["File Operations"
      :pad-keys t
      ("j" "Goto File"                  dired-goto-file)
      ("k" "Kill Lines"                 dired-do-kill-lines)
      ("l" "Redisplay"                  dired-do-redisplay)
      ("C-o" "Display File"             dired-display-file)
      ("s" "Sort Toggle Edit"           dired-sort-toggle-or-edit)
      ("v" "View File"                  dired-view-file)
      ("w" "Copy Filename"              dired-copy-filename-as-kill)
      ("W" "Browse URL"                 browse-url-of-dired-file)
      ("x" "Del. Flagged"               dired-do-flagged-delete)
      ("y" "File Type"                  dired-show-file-type)
      ("+" "Create Directory"           dired-create-directory)
      ("@" "Find With Sudo"             tramp-dired-find-file-with-sudo)]
     ["Regexp Commands"
      :pad-keys t
      ("% u" "Upcase"                   dired-upcase)
      ("% l" "Downcase"                 dired-downcase)
      ("% d" "Flag"                     dired-flag-files-regexp)
      ("% g" "Mark Containing"          dired-mark-files-containing-regexp)
      ("% m" "Mark"                     dired-mark-files-regexp)
      ("% r" "Rename"                   dired-do-rename-regexp)
      ("% R" "Rename"                   dired-do-rename-regexp)
      ("% C" "Copy"                     dired-do-copy-regexp)
      ("% H" "Hardlink"                 dired-do-hardlink-regexp)
      ("% S" "Symlink"                  dired-do-symlink-regexp)
      ("% Y" "RelSymlink"               dired-do-relsymlink-regexp)
      ("% &" "Flag Garbage"             dired-flag-garbage-files)]
     ["Hidden"
      :pad-keys t
      ("$" "Hide Subdir."               dired-hide-subdir)
      ("M-$" "Hide All"                 dired-hide-all)
      ("(" "Hide Details"               dired-hide-details-mode)
      "Isearch"
      ("M-s a C-s" "Isearch"            dired-do-isearch)
      ("M-s a C-M-s" "Regexp"           dired-do-isearch-regexp)
      ("M-s f C-s" "Filename"           dired-isearch-filenames)
      ("M-s f C-M-s" "Filename Regexep" dired-isearch-filenames-regexp)]]
    [:class transient-row]
    [["Mark or Flag Categories"
      :pad-keys t
      ("#" "Flag Auto-Save Files"       dired-flag-auto-save-files)
      ("." "Clean Directory"            dired-clean-directory)
      ("~" "Flag Backups"               dired-flag-backup-files)
      ("M-{" "Prev. Marked File"        dired-prev-marked-file)
      ("M-}" "Next Marked  File"        dired-next-marked-file)
      "Mark Files"
      ("* m" "Mark"                     dired-mark)
      ("* u" "Unmark"                   dired-unmark)
      ("* *" "Executables"              dired-mark-executables)
      ("* /" "Directories"              dired-mark-directories)
      ("* @" "Symlinks"                 dired-mark-symlinks)
      ("* %" "Regexp"                   dired-mark-files-regexp)]
     ["Marked Files"
      :pad-keys t
      ("* N" "# Marked"                 dired-number-of-marked-files)
      ("* c" "Change Marks"             dired-change-marks)
      ("* s" "Subdir"                   dired-mark-subdir-files)
      ("* ?" "Unmark All"               dired-unmark-all-files)
      ("M-DEL" "Unmark All"             dired-unmark-all-files)
      ("* !" "Unmark All Marks"         dired-unmark-all-marks)
      ("U" "Unmark All Marks"           dired-unmark-all-marks)
      ("DEL" "Unmark Backward"          dired-unmark-backward)
      ("* C-n" "Next Marked"            dired-next-marked-file)
      ("* C-p" "Prev. Marked"           dired-prev-marked-file)
      ("* t" "Toggle Marks"             dired-toggle-marks)]
     ["Marked Files Operations"
      :pad-keys t
      ("A" "Find Regexp"                dired-do-find-regexp)
      ("B" "Byte Compile"               dired-do-byte-compile)
      ("C" "Copy"                       dired-do-copy)
      ("D" "Delete"                     dired-do-delete)
      ("E" "Open"                       dired-do-open)
      ("P" "Open Preview File"          dired-preview-open-dwim)
      ("G" "Change Group"               dired-do-chgrp)
      ("H" "Hardlink"                   dired-do-hardlink)
      ("I" "Info"                       dired-do-info)
      ("L" "Load"                       dired-do-load)
      ("M" "Chmod"                      dired-do-chmod)
      ("O" "Chown"                      dired-do-chown)]
     ["Marked Files Operations"
      :pad-keys t
      ("N" "Man"                        dired-do-man)
      ("Q" "Find/Replace Regexp"        dired-do-find-regexp-and-replace)
      ("R" "Rename"                     dired-do-rename)
      ("S" "Symlink"                    dired-do-symlink)
      ("T" "Touch"                      dired-do-touch)
      ("X" "Shell Command"              dired-do-shell-command)
      ("Y" "Relative Symlink"           dired-do-relsymlink)
      ("Z" "Compress"                   dired-do-compress)
      ("c" "Compress-to"                dired-do-compress-to)
      ("!" "Shell Command"              dwim-shell-command)
      ("&" "Async Shell Command"        dwim-shell-command)]
     ["GPG"
      :pad-keys t
      (": d" "Decrypt"                  epa-dired-do-decrypt)
      (": v" "Verify"                   epa-dired-do-verify)
      (": s" "Sign"                     epa-dired-do-sign)
      (": e" "Encrypt"                  epa-dired-do-encrypt)
      "Misc"
      ("=" "Diff"                       dired-diff)
      ("?" "Summary"                    dired-summary)]])

  (keymap-unset dired-mode-map "?")
  (keymap-set dired-mode-map "?" 'user/dired-dispatch))


(provide '10-file-management)
;;; 10-file-management.el ends here
