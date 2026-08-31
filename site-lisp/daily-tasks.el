;;; daily-tasks.el --- Load files necessary for daily cron jobs -*- lexical-binding: t -*-

;;; Commentary:
;; This file is to be loaded via:
;; #+BEGIN_SRC shell
;;   /path/to/emacs --batch -l "/path/to/daily-tasks.el"
;; #+END_SRC

;;; Code:
(setq
 package-enable-at-startup nil
 package-quickstart-file nil)
(add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory))

(require 'a-elpaca)
(require 'c-org)

(with-eval-after-load 'org
  (that1guycolin/org-rollover-daily-tasks))


(provide 'daily-tasks)
;;; daily-tasks.el ends here
