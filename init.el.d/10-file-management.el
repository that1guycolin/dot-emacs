;;; 10-file-management.el --- File explorer functions -*- lexical-binding: t; -*-

;;; Packages included:
;; dirvish, dwim-shell-command, ready-player

;;; Commentary:
;; Leverage dirvish (layer on top of Dired) settings & extensions to provide a
;; functional file explorer inside Emacs.

;;; Code:
;; =======  FILE EXPLORER  =======
;; `dirvish' (Dired w `batteries included')
;; `dwim-shell-command' (execute shell commands on marked files)
;; `ready-player' (launch media directly from dirvish)
;; ===============================
(use-package dirvish
  :defer t
  :preface
  (defvar user/dirvish-clipboard-files nil
    "Files currently staged by `user/dirvish-copy' or `user/dirvish-cut'.")

  (defvar user/dirvish-clipboard-action nil
    "Current Dirvish clipboard action.
Expected values are `copy' or `cut'.")

  (defvar-local user/dirvish-preview-buffer nil
    "Non-nil when this buffer was made read-only as a Dirvish preview.")

  (defun user/dirvish--file-at-point ()
    "Return the file at point, or signal a user error."
    (or (dired-get-filename nil t)
        (user-error "No file at point")))

  (defun user/dirvish--marked-files-or-current ()
    "Return marked files, or the file at point if nothing is marked."
    (let ((files (dired-get-marked-files nil nil)))
      (unless files
        (user-error "No files selected"))
      files))

  (defun user/dirvish-rename-file ()
    "Rename the file at point by editing only its basename."
    (interactive)
    (let* ((old-file (directory-file-name (user/dirvish--file-at-point)))
           (old-dir  (file-name-directory old-file))
           (old-name (file-name-nondirectory old-file))
           (new-name (read-string "Rename to: " old-name)))
      (when (string-empty-p (string-trim new-name))
        (user-error "Filename cannot be empty"))
      (when (file-name-directory new-name)
        (user-error "Rename only changes the filename, not the directory"))
      (when (member new-name '("." ".."))
        (user-error "Invalid filename: %s" new-name))
      (let ((new-file (expand-file-name new-name old-dir)))
        (if (string= old-file (directory-file-name new-file))
            (message "Rename canceled")
          (rename-file old-file new-file nil)
          (revert-buffer)
          (dired-goto-file new-file)
          (message "Renamed %s -> %s" old-name new-name)))))

  (defun user/dirvish-copy ()
    "Stage marked files, or current file, for copying."
    (interactive)
    (setq user/dirvish-clipboard-files (user/dirvish--marked-files-or-current)
          user/dirvish-clipboard-action 'copy)
    (message "Copied %d item(s)" (length user/dirvish-clipboard-files)))

  (defun user/dirvish-cut ()
    "Stage marked files, or current file, for moving."
    (interactive)
    (setq user/dirvish-clipboard-files (user/dirvish--marked-files-or-current)
          user/dirvish-clipboard-action 'cut)
    (message "Cut %d item(s)" (length user/dirvish-clipboard-files)))

  (defun user/dirvish--paste-target-directory ()
    "Return the directory where staged files should be pasted.

If point is on a directory, paste into that directory.
Otherwise paste into the current Dired/Dirvish directory."
    (let ((file (dired-get-filename nil t)))
      (file-name-as-directory
       (if (and file (file-directory-p file))
           file
         (dired-current-directory)))))

  (defun user/dirvish--copy-one-file (src dest)
    "Copy SRC to DEST without overwriting."
    (if (file-directory-p src)
        (copy-directory src dest t nil nil)
      (copy-file src dest nil t)))

  (defun user/dirvish-paste ()
    "Paste staged files into the directory at point or current directory."
    (interactive)
    (unless user/dirvish-clipboard-files
      (user-error "Nothing has been copied or cut"))
    (unless (memq user/dirvish-clipboard-action '(copy cut))
      (user-error "Unknown clipboard action: %s" user/dirvish-clipboard-action))
    (let* ((dest-dir (user/dirvish--paste-target-directory))
           (files user/dirvish-clipboard-files)
           (action user/dirvish-clipboard-action)
           first-dest)
      (dolist (src files)
        (let* ((base (file-name-nondirectory (directory-file-name src)))
               (dest (expand-file-name base dest-dir)))
          (when (file-exists-p dest)
            (user-error "Target already exists: %s" dest))
          (unless first-dest
            (setq first-dest dest))
          (pcase action
            ('copy (user/dirvish--copy-one-file src dest))
            ('cut  (rename-file src dest nil)))))
      (when (eq action 'cut)
        (setq user/dirvish-clipboard-files nil
              user/dirvish-clipboard-action nil))
      (revert-buffer)
      (when (and first-dest (file-exists-p first-dest))
        (ignore-errors (dired-goto-file first-dest)))
      (message "%s %d item(s) to %s"
               (pcase action
                 ('copy "Copied")
                 ('cut  "Moved"))
               (length files)
               dest-dir)))

  (defun user/dirvish-down-directory ()
    "Open the directory at point in the current Dirvish window."
    (interactive)
    (let ((file (user/dirvish--file-at-point)))
      (unless (file-directory-p file)
        (user-error "Not a directory: %s" file))
      (dired-find-file)))

  (defun user/dirvish-make-opened-file-editable ()
    "Undo preview read-only state after opening a file normally."
    (when (and buffer-file-name
               (bound-and-true-p user/dirvish-preview-buffer))
      (setq-local user/dirvish-preview-buffer nil)
      (when (bound-and-true-p view-mode)
        (view-mode -1))
      (when (file-writable-p buffer-file-name)
        (read-only-mode -1))))

  (defun user/dirvish-return-dwim ()
    "On directories, descend.  On files, open the file normally."
    (interactive)
    (let ((file (user/dirvish--file-at-point)))
      (if (file-directory-p file)
          (user/dirvish-down-directory)
        (dired-find-file)
        (user/dirvish-make-opened-file-editable))))

  (defun user/dirvish-tab-dwim ()
    "Change behaviour based on current marker positions.
On directories, toggle subtree.  On files, use Dirvish file outline viewer."
    (interactive)
    (unless (fboundp 'dirvish-subtree-toggle)
      (user-error "`dirvish-subtree-toggle' is not available"))
    (dirvish-subtree-toggle))

  (defun user/dirvish-preview-read-only ()
    "Make Dirvish preview buffers read-only."
    (setq-local user/dirvish-preview-buffer t)
    (read-only-mode 1))

  (declare-function transient-define-prefix "transient")

  :bind ("C-x d" . dirvish)
  :commands dirvish-dwim

  :functions
  dired-create-directory dired-create-empty-file dired-current-directory
  dired-do-rename dired-find-file dired-get-filename dired-get-marked-files
  dired-goto-file dired-next-line dired-previous-line dired-up-directory
  dirvish-override-dired-mode dirvish-subtree-toggle user/dirvish-dispatch
  :defines dirvish-mode-map

  :init
  (dirvish-override-dired-mode 1)

  :custom
  (dirvish-hide-cursor nil)
  (dirvish-attributes '(subtree-state file-size file-time nerd-icons))
  (dirvish-hide-details t)
  (dirvish-reuse-session nil)

  :config
  (dolist (plugin '(dirvish-extras dirvish-subtree dirvish-yank))
    (require plugin))

  (dolist (optional-plugin '(dirvish-vc dirvish-emerge))
    (require optional-plugin nil t))

  (add-hook 'dirvish-preview-setup-hook #'user/dirvish-preview-read-only)

  (defvar user/dirvish-dispatch)
  (transient-define-prefix user/dirvish-dispatch ()
    "Custom Dirvish command menu."
    [
     ["Navigation"
      ("C-p"   "Previous line"       dired-previous-line :transient t)
      ("C-n"   "Next line"           dired-next-line :transient t)
      ("^"     "Up directory"        dired-up-directory :transient t)
      ("C-M-p" "Up directory"        dired-up-directory :transient t)
      ("C-M-n" "Down directory"      user/dirvish-down-directory :transient t)
      ("TAB"   "Subtree / outline"   user/dirvish-tab-dwim :transient t)
      ("RET"   "Open / down"         user/dirvish-return-dwim)]

     ["File operations"
      ("R"   "Rename filename only" user/dirvish-rename-file)
      ("m"   "Move..."              dired-do-rename)
      ("C-w" "Cut"                  user/dirvish-cut)
      ("M-w" "Copy"                 user/dirvish-copy)
      ("C-y" "Paste here"           user/dirvish-paste)
      ("c f" "Create file"          dired-create-empty-file)
      ("c d" "Create directory"     dired-create-directory)]

     ["Dirvish native menus"
      ("a"   "Setup UI"             dirvish-setup-menu)
      ("f"   "File info"            dirvish-file-info-menu)
      ("o"   "Quick access"         dirvish-quick-access)
      ("s"   "Sort"                 dirvish-quicksort)
      ("l"   "ls switches"          dirvish-ls-switches-menu)
      ("*"   "Mark menu"            dirvish-mark-menu)
      ("y"   "Yank menu"            dirvish-yank-menu)]
     [""
      ("v"   "VC menu"              dirvish-vc-menu)
      ("N"   "Narrow"               dirvish-narrow)
      ("M-b" "History back"         dirvish-history-go-backward :transient t)
      ("M-f" "History forward"      dirvish-history-go-forward :transient t)
      ("M-e" "Emerge menu"          dirvish-emerge-menu)
      ("g"   "Revert"               revert-buffer :transient t)
      ("q"   "Quit Dirvish"         dirvish-quit)]])
  
  (let ((map dirvish-mode-map)
        (create-map (make-sparse-keymap)))
    (keymap-set map "C-p"	 #'dired-previous-line)
    (keymap-set map "C-n"	 #'dired-next-line)
    (keymap-set map "R"		 #'user/dirvish-rename-file)
    (keymap-set map "m"		 #'dired-do-rename)
    (keymap-set map "c"            create-map)
    (keymap-set map "C-w"	 #'user/dirvish-cut)
    (keymap-set map "M-w"	 #'user/dirvish-copy)
    (keymap-set map "C-y"	 #'user/dirvish-paste)
    (keymap-set map "^"		 #'dired-up-directory)
    (keymap-set map "C-M-p"	 #'dired-up-directory)
    (keymap-set map "C-M-n"	 #'user/dirvish-down-directory)
    (keymap-set map "TAB"	 #'user/dirvish-tab-dwim)
    (keymap-set map "RET"	 #'user/dirvish-return-dwim)
    (keymap-set map "?"		 #'user/dirvish-dispatch)
    (keymap-set create-map "f"	 #'dired-create-empty-file)
    (keymap-set create-map "d"	 #'dired-create-directory))

  (transient-append-suffix 'user/project-treemacs-anywhere-dispatch "r"
    '("c" "Dirvish" (lambda () (interactive)
		      (call-interactively #'dirvish)))))

(use-package dwim-shell-command
  :defer t
  :preface
  (keymap-global-unset "M-!")

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

  (defvar-keymap user/ffmpeg-actions-map
    :prefix t
    :doc "Keymap with FFmpeg actions to run on marked files in dired/dirvish."
    "4" #'user/convert-ts-to-mp4
    "v" #'user/extract-video-only
    "a" #'user/extract-audio-only)
  
  :bind
  (("M-!" . dwim-shell-command)
   :map dirvish-mode-map
   ("F" . user/ffmpeg-actions-map))
  :commands dwim-shell-command-on-marked-files
  :config
  (transient-append-suffix 'user/dirvish-dispatch "c d"
    '("F" "FFmpeg Actions" user/ffmpeg-actions-map)))

(use-package ready-player
  :defer t
  :hook (dired-mode . ready-player-mode))


(provide '10-file-management)
;;; 10-file-management.el ends here
