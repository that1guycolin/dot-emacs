#!/usr/bin/env -S emacs --batch --eval (load\ user-init-file) -l
;; -*- lexical-binding: t; -*-

(declare-function profiler-stop "profiler")
(declare-function profiler-report "profiler")
(setq debug-on-error t)
(profiler-start 'cpu)
(require 'profiler)
(run-with-idle-timer 30 nil
                     (lambda ()
                       (profiler-stop)
                       (with-eval-after-load 'profiler
                         (profiler-report))))

;; Local Variables:
;; flycheck-disabled-checkers: (emacs-lisp-checkdoc)
;; End:
