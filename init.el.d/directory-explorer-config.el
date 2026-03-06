;;; directory-explorer-config.el --- Emacs Configuration for Dired & Dirvish -*- lexical-binding: t; -*-

;;; Commentary:
;; Configure Dired to behave more like a traditional file explorer.

;;; Packages included:
;; diredfl, dired-video-thumbnail, dirvish

;;; Code:
(use-package dirvish
  :functions
  dirvish-override-dired-mode
  dirvish-peek-mode
  dirvish-dwim
  dirvish-fd
  dirvish-subtree-toggle-or-open
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
  user/dirvish-yank-dispatch
  dirvish-subtree-toggle
  dirvish-layout-toggle
  dirvish-history-go-backward
  dirvish-history-go-forward
  dirvish-narrow
  dirvish-mark-menu
  dirvish-setup-menu
  dirvish-emerge-menu

  :init
  (dirvish-override-dired-mode)

  :config
  (require 'dirvish-yank)
  (require 'dirvish-subtree)
  (declare-function transient-define-prefix "transient")
  (defvar user/dirvish-yank-dispatch)
  (with-eval-after-load 'transient
    (transient-define-prefix user/dirvish-yank-dispatch ()
      "Create transient buffer for dirvish-yank functions."
      [:description
       (lambda () "File manipulation")
       [("y" "yank" dirvish-yank)]
       [("m" "move" dirvish-move)]
       [("s" "symlink" dirvish-symlink)]
       [("S" "relative symlink" dirvish-relative-symlink)]
       [("h" "hardlink" dirvish-hardlink)]
       [("r" "rsync" dirvish-rsync)]]))

  (dirvish-peek-mode)
  (setq dirvish-attributes
	'(vc-state subtree-state file-modes nerd-icons collapse git-msg
		   file-size file-time))
  (setq dirvish-mode-line-format '(:left (sort symlink)
					 :right (vc-info yank index)))
  (setq dirvish-header-line-height '(25 . 35))
  (setq dirvish-header-line-format '(:left (path) :right (free-space)))
  (setq dired-listing-switches "-l --almost-all --ignore-backups \
--human-readable --group-directories-first --no-group")

  (bind-keys
   ("C-c d"   . dirvish-dwim)
   ("C-c C-d" . dirvish-fd)
   :map dirvish-mode-map
   ;; left click for expand/collapse dir or open file
   ("<mouse-1>" . dirvish-subtree-toggle-or-open)
   ;; middle click for opening file / entering dir in other window
   ("<mouse-2>" . dired-mouse-find-file-other-window)
   ;; right click for opening file / entering dir
   ("<mouse-3>" . dired-mouse-find-file)
   ([remap dired-sort-toggle-or-edit] . dirvish-quicksort)
   ([remap dired-do-redisplay] . dirvish-ls-switches-menu)
   ([remap dired-do-copy] . dirvish-yank-menu)
   ("?"   . dirvish-dispatch)
   ("q"   . dirvish-quit)
   ("a"   . dirvish-quick-access)
   ("f"   . dirvish-file-info-menu)
   ("x"   . dired-do-delete)
   ("X"   . dired-do-flagged-delete)
   ("y"   . user/dirvish-yank-dispatch)
   ("s"   . dirvish-quicksort)
   ("TAB" . dirvish-subtree-toggle)
   ("M-t" . dirvish-layout-toggle)
   ("M-b" . dirvish-history-go-backward)
   ("M-f" . dirvish-history-go-forward)
   ("M-n" . dirvish-narrow)
   ("M-m" . dirvish-mark-menu)
   ("M-s" . dirvish-setup-menu)
   ("M-e" . dirvish-emerge-menu)))

(use-package diredfl
  :hook (dired-mode . diredfl-mode))

(use-package dired-video-thumbnail
  :bind (:map dirvish-mode-map
              ("C-c C-v" . dired-video-thumbnail)))


(provide 'directory-explorer-config)
;;; directory-explorer-config.el ends here