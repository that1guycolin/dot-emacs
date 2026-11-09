;;; flycheck-custom-checkers.el --- Personal checker definitions -*- lexical-binding: t -*-

;;; Commentary:

;; The parsing functions and definitions for all the custom flycheck syntax
;; checkers (linters) used in this config.

;;; Code:

(require 'flycheck)

;;   (defun that1guycolin/flycheck--parse-pretty-json (output)
;;     "Parse a linter's pretty-printed json OUTPUT.
;; Flycheck's native `flycheck-parse-json' only works if the json is a single line
;; string. The purpose of this function is to account for linters whose json output
;; is in rich text, printed over multiple lines, etc..."
;;     (with-temp-buffer
;;       (insert output)
;;       (goto-char (point-min))
;;       (json-parse-buffer :object-type 'alist :array-type 'list)))


;;; Vale:

(defun that1guycolin/flycheck-vale-setup ()
  "If not setup, install vale from the .ini file in `user-lisp-directory'."
  (let* ((vale-config
          (expand-file-name "site-lisp/.vale.ini" user-emacs-directory))
         (command (format "vale --config %s sync >/dev/null 2>&1"
                          (shell-quote-argument vale-config))))
    (shell-command command)))

(flycheck-define-checker text-vale
  "Tool to bring code-like linting to prose.
See URL `https://vale.sh'."
  :command ("vale" "--config"
            (eval (expand-file-name "site-lisp/.vale.ini" user-emacs-directory))
            "--no-global" "--output" "line" source)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ":"
            (id (one-or-more (not (any ":")))) ":" (message) line-end))
  :modes (text-mode))

(add-to-list 'flycheck-checkers 'text-vale)


;;; Mallet:

(flycheck-define-checker cl-mallet
  "A Common Lisp linter using Mallet.
See URL: \\='https://github.com/fukamachi/mallet'."
  :command ("mallet" source)
  :error-patterns
  ((error line-start (zero-or-more space)
          line ":" column
          (one-or-more space) "error" (one-or-more space)
          (message (minimal-match (one-or-more not-newline)))
          (one-or-more space) (id (one-or-more not-newline))
          line-end)

   (warning line-start (zero-or-more space)
            line ":" column
            (one-or-more space) "warning" (one-or-more space)
            (message (minimal-match (one-or-more not-newline)))
            (one-or-more space) (id (one-or-more not-newline))
            line-end)

   (info line-start (zero-or-more space)
         line ":" column
         (one-or-more space) "info" (one-or-more space)
         (message(minimal-match (one-or-more not-newline)))
         (one-or-more space) (id (one-or-more not-newline))
         line-end))
  :modes (lisp-mode lisp-ts-mode lisp-data-mode))

(add-to-list 'flycheck-checkers 'cl-mallet)


;;; Selene:

(defun that1guycolin/flycheck-parse-selene (output checker buffer)
  "Parse JSON OUTPUT from running CHECKER \"selene\" on BUFFER."
  (let ((violations (flycheck-parse-json output)))
    (mapcar
     (lambda (violation)
       (let-alist violation
         (let ((span (alist-get 'span .primary_label)))
           (flycheck-error-new-at
            (1+ (alist-get 'start_line span))
            (1+ (alist-get 'start_column span))
            (pcase .severity
              ("Error" 'error)
              ("Warning" 'warning)
              (_ 'info))
            .message
            :id .code
            :end-line (1+ (alist-get 'end_line span))
            :end-column (1+ (alist-get 'end_column span))
            :checker checker :buffer buffer
            :filename (alist-get 'filename .primary_label)))))
     violations)))

(flycheck-define-checker lua-selene
  "A tool designed to help write correct and idiomatic Lua code.
See URL \\='https://kampfkarren.github.io/selene/'."
  :command ("selene" "--no-summary" "--display-style=json"
            (source-inplace "lua"))
  :error-parser that1guycolin/flycheck-parse-selene
  :modes lua-ts-mode)

(add-to-list 'flycheck-checkers 'lua-selene)

;;; Rumdl:

(flycheck-define-checker markdown-rumdl
  "A fast Markdown linter written in Rust.
See URL: \\='https://github.com/rvben/rumdl'."
  :command ("rumdl" "check" "--watch" "--stdin" source)
  :error-patterns
  ((error line-start (file-name)
          ":" line ":" column ": "
          (id (one-or-more (not (any " ")))) " " (message) line-end)
   (warning line-start (file-name)
            ":" line ":" column ": "
            (id (one-or-more (not (any " ")))) " " (message) line-end)
   (info line-start (file-name)
         ":" line ":" column ": "
         (id (one-or-more (not (any " ")))) " " (message) line-end))
  :modes (markdown-ts-mode markdown-mode gfm-mode))

(add-to-list 'flycheck-checkers 'markdown-rumdl)


;;; Zsh-lint:

(defun that1guycolin/flycheck-parse-zshlint (output checker buffer)
  "Parse JSON OUTPUT from running CHECKER \"zsh-lint\" on BUFFER."
  (let* ((raw (flycheck-parse-json output))
         (diagnostics (cdr (assoc 'diagnostics (cdar raw)))))
    (mapcar
     (lambda (diagnostic)
       (let-alist diagnostic
         (let ((start (alist-get 'start .range))
               (end (alist-get 'end .range)))
           (flycheck-error-new-at
            (alist-get 'line start)
            (alist-get 'column start)
            (pcase .severity
              ("warning" 'error)
              ("info" 'warning)
              (_ 'info))
            .message
            :id .rule
            :end-line (alist-get 'line end)
            :end-column (alist-get 'column end)
            :checker checker :buffer buffer
            :filename .file))))
     diagnostics)))

(flycheck-define-checker zsh-lint
  "A standalone semantic analyzer for Zsh.
See URL \\='https://wiki.zshell.dev/community/zsh_lint'."
  :command ("zsh-lint" "--format=json" source)
  :error-parser that1guycolin/flycheck-parse-zshlint
  :modes sh-mode)

(add-to-list 'flycheck-checkers 'zsh-lint)


;;; Fish (self):

(flycheck-define-checker fish-self
  "The shell for the 90's built-in syntax checker.
See URL: \\='https://fishshell.com'."
  :command ("fish" "-n" source)
  :error-patterns
  ((error   line-start (file-name) " (line " line "): " (message) line-end)
   (warning line-start (file-name) " (line " line "): " (message) line-end)
   (info    line-start (file-name) " (line " line "): " (message) line-end))
  :modes (fish-mode))

(add-to-list 'flycheck-checkers 'fish-self)


;;; Checkmake:

(defun that1guycolin/flycheck-parse-checkmake (output checker buffer)
  "Parse JSON OUTPUT from running CHECKER \"checkmake\" on BUFFER."
  (let ((objects (flycheck-parse-json output)))
    (mapcar
     (lambda (object)
       (let-alist object
         (flycheck-error-new
          :line .line_number :level 'warning
          :message .violation
          :id .rule :filename .file_name
          :checker checker :buffer buffer)))
     objects)))

(flycheck-define-checker makefile-checkmake
  "Linter/analyzer for Makefiles.
See URL \\='https://github.com/checkmake/checkmake'."
  :command ("checkmake" "--output=json" source-inplace)
  :error-parser that1guycolin/flycheck-parse-checkmake
  :modes makefile-mode)

(add-to-list 'flycheck-checkers 'makefile-checkmake)


;;; Systemd-lint:

(flycheck-define-checker systemd-systemdlint
  "A Systemd unit file linter.
See URL: \\='https://github.com/priv-kweihmann/systemdlint'."
  :command ("systemdlint" source)
  :error-patterns
  ((error line-start (file-name) ":" line ":" (message) line-end)
   (warning line-start (file-name) ":" line ":" (message) line-end)
   (info line-start (file-name) ":" line ":" (message) line-end))
  :modes systemd-mode)

(add-to-list 'flycheck-checkers 'systemd-systemdlint)

;;; DCLint:

(defun that1guycolin/flycheck-parse-dclint (output checker buffer)
  "Parse JSON OUTPUT from running CHECKER \"dclint\" on BUFFER."
  (let* ((raw (flycheck-parse-json output))
         (fpath (cdr (assoc 'filePath (caar raw))))
         (msgs (cdr (assoc 'messages (caar raw)))))
    (mapcar
     (lambda (msg)
       (let-alist msg
         (flycheck-error-new
          :line .line :column .column
          :buffer buffer :checker checker
          :filename fpath :message .message
          :level .type :id .rule :group .category
          :tags .severity)))
     msgs)))

(flycheck-define-checker yaml-dclint
  "A tool for validating and enforcing best practices in compose.yaml files.
See URL \\='https://github.com/zavoloklom/docker-compose-linter'."
  :command ("dclint" "--formatter=json" source-original)
  :predicate flycheck-buffer-saved-p
  :error-parser that1guycolin/flycheck-parse-dclint
  :modes yaml-ts-mode)

(add-to-list 'flycheck-checkers 'yaml-dclint)


(provide 'flycheck-custom-checkers)
;;; flycheck-custom-checkers.el ends here
