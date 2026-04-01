;;; 10-org-mode-extensions.el --- Extensions for Org-mode -*- lexical-binding: t; -*-

;;; Packages included:
;; org-edna, org-gtd, org-projectile, toc-org

;;; Commentary:
;; Provide extensions for Emacs' Org-mode.

;;; Code:
(defvar org-directory)

(defun user/convert-md-links-to-org ()
  "Convert all [label](link) patterns in the current buffer to [[link][label]]."
  (interactive)
  (save-excursion
    (goto-char (point-min)) ; Start at the beginning of the file
    (while (re-search-forward "\\[\\([^]]+\\)\\](\\([^)]+\\))" nil t)
      (replace-match "[[\\2][\\1]]" nil nil))))

(use-package org-edna
  :after org
  :functions org-edna-mode
  :config
  (org-edna-mode 1))

(use-package org-gtd
  :after org
  :functions
  org-gtd-capture org-gtd-engage org-gtd-process-inbox org-gtd-show-all-next
  org-gtd-reflect-stuck-projects org-gtd-organize org-gtd-agenda-transient
  :defines
  org-gtd-update-ack
  
  :init
  (setq
   org-gtd-update-ack "4.0.0"
   org-gtd-directory (expand-file-name "tasks" org-directory))

  :custom
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "WAIT(w)" "|" "DONE(d)" "CNCL(c)")))
  (org-gtd-keyword-mapping '((todo . "TODO(t)")
                             (next . "NEXT(n)")
                             (wait . "WAIT(w)")
			     (done . "DONE(d)")
                             (canceled . "CNCL(c)")))
  (org-gtd-refile-to-any-target nil)
  (org-gtd-refile-prompt-for-types
   '(single-action project-heading project-task calendar someday tickler
		   habit knowledge quick-action trash))
  
  :config
  (org-edna-mode 1)
  (bind-keys
   ("C-c d c" . org-gtd-capture)
   ("C-c d e" . org-gtd-engage)
   ("C-c d p" . org-gtd-process-inbox)
   ("C-c d n" . org-gtd-show-all-next)
   ("C-c d s" . org-gtd-reflect-stuck-projects)
   :map org-gtd-clarify-mode-map
   ("C-c c" . org-gtd-organize)
   :map org-agenda-mode-map
   ("C-c ." . org-gtd-agenda-transient)))

(use-package org-project-capture
  :ensure (org-project-capture
	   :source "MELPA"
	   :package "org-project-capture"
	   :id org-project-capture
	   :repo "colonelpanic8/org-project-capture"
	   :fetcher github
	   :files ("org-project-capture.el"
		   "org-project-capture-backend.el"
		   "org-projectile.el")
	   :type git
	   :protocol https
	   :inherit t
	   :depth treeless)
  :after (org projectile)
  :functions
  org-project-capture-capture-for-current-project
  org-project-capture-project-todo-completing-read
  org-project-capture-agenda-for-current-project

  :functions
  org-project-capture-per-project

  :config
  (require 'org-projectile)
  (setq org-project-capture-default-backend
	(make-instance 'org-project-capture-projectile-backend))
  (org-project-capture-per-project)

  (bind-keys
   ("C-c p c" . org-project-capture-capture-for-current-project)
   ("C-c p p" . org-project-capture-project-todo-completing-read)
   ("C-c p a" . org-project-capture-agenda-for-current-project)))

(use-package org-roam
  :after org
  :functions
  org-roam-db-autosync-mode org-roam-node-insert org-roam-node-find
  org-roam-capture user/org-roam-global-prefix-map
  :custom
  (org-roam-directory (expand-file-name "knowledge-base" org-directory))
  (org-roam-db-location (expand-file-name "org-roam.db" org-directory))
  :config
  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))
  (org-roam-db-autosync-mode 1)
  (defvar-keymap user/org-roam-global-prefix-map
    :doc "Prefix for org-roam-commands that can be called at any time."
    :prefix 'user/org-roam-global-prefix-map
    "i" #'org-roam-node-insert
    "f" #'org-roam-node-find
    "c" #'org-roam-capture)
  (bind-keys ("C-c r" . user/org-roam-global-prefix-map)))

(use-package org-roam-ql
  :after (org-roam)
  :bind ((:map org-roam-mode-map
	       ("v" . org-roam-ql-buffer-dispatch))
         (:map minibuffer-mode-map
               ("C-c n i" . org-roam-ql-insert-node-title))))

(use-package org-make-toc
  :defer t
  :bind (:map org-mode-map
	      ("C-c T i" . org-make-toc-insert)
	      ("C-c T m" . org-make-toc))
  :custom
  (org-make-toc-insert-custom-ids t))


(provide '10-org-mode-extensions)
;;; 10-org-mode-extensions.el ends here
