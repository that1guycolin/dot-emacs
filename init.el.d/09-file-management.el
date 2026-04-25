;;; 09-file-management.el --- File explorer functions -*- lexical-binding: t; -*-

;;; Packages included:
;; async, deadgrep, diredfl, dirvish

;;; Commentary:
;; Leverage `dirvish', along with some Dired built-in settings & extensions,
;; to provide a functional file explorer inside Emacs.

;;; Code:
(use-package diredfl
  :defer t
  :hook (dired-mode . diredfl-mode))

(use-package async
  :defer t
  :commands
  async-start
  async-start-process
  :hook (dired-mode . dired-async-mode)
  :init
  (require 'dired-async))

(keymap-global-unset "C-x d")
(declare-function diff-hl-dired-mode "diff-hl")
(use-package dirvish
  :defer t
  :commands dirvish
  
  :functions
  dirvish-override-dired-mode
  dirvish-peek-mode
  dirvish-dwim
  dirvish-fd
  dired-mouse-find-file-other-window
  dired-mouse-find-file
  dirvish-quicksort
  dirvish-ls-switches-menu
  dirvish-yank-menu
  dirvish-dispatch
  dirvish-quit
  dirvish-quick-access
  dirvish-file-info-menu
  dired-do-delete
  dired-do-flagged-delete
  dirvish-yank
  dirvish-subtree-toggle
  dirvish-layout-toggle
  dirvish-history-go-backward
  dirvish-history-go-forward
  dirvish-narrow
  dirvish-mark-menu
  dirvish-setup-menu
  dirvish-emerge-menu
  
  :init
  (dirvish-override-dired-mode 1)
  
  :custom
  (dirvish-preview-dispatchers '(archive pdf))
  (dirvish-attributes '(file-size file-time nerd-icons))
  (dirvish-hide-details t)
  (dirvish-reuse-session nil)
  (dired-listing-switches "-l --almost-all --ignore-backups \
--human-readable --group-directories-first --no-group")
  
  :config
  (bind-keys
   ("C-c D"     . dirvish-dwim)
   ("C-c C-S-d" . dirvish-fd)
   :map dirvish-mode-map
   ("<mouse-1>"                       . dirvish-subtree-toggle)
   ("<mouse-2>"                       . dired-mouse-find-file-other-window)
   ("<mouse-3>"                       . dired-mouse-find-file)
   ([remap dired-sort-toggle-or-edit] . dirvish-quicksort)
   ([remap dired-do-redisplay]        . dirvish-ls-switches-menu)
   ([remap dired-do-copy]             . dirvish-yank-menu)
   ("?"                               . dirvish-dispatch)
   ("q"                               . dirvish-quit)
   ("a"                               . dirvish-quick-access)
   ("f"                               . dirvish-file-info-menu)
   ("x"                               . dired-do-delete)
   ("X"                               . dired-do-flagged-delete)
   ("y"                               . dirvish-yank)
   ("s"                               . dirvish-quicksort)
   ("TAB"                             . dirvish-subtree-toggle)
   ("M-t"                             . dirvish-layout-toggle)
   ("M-b"                             . dirvish-history-go-backward)
   ("M-f"                             . dirvish-history-go-forward)
   ("M-n"                             . dirvish-narrow)
   ("M-m"                             . dirvish-mark-menu)
   ("M-s"                             . dirvish-setup-menu)
   ("M-e"                             . dirvish-emerge-menu)
   ("C-c h"                           . diff-hl-dired-mode)))

(use-package dwim-shell-command
  :defer t
  :commands dwim-shell-command-on-marked-files)

(defun user/convert-ts-to-mp4 ()
  "Convert .ts files to .mp4 using FFmpeg."
  (interactive)
  (dwim-shell-command-on-marked-files
   "Convert to mp4"
   "ffmpeg -hide_banner -v quiet -stats -y -i '<<f>>' -map 0:v -map 0:a \
-c copy -movflags +faststart '<<fne>>.mp4'"
   :utils "ffmpeg"))


(provide '09-file-management)
;;; 09-file-management.el ends here
