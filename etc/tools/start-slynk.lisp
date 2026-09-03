;;; start-slynk.lisp - For use in Termux on Android.
;; Allows the Android Emacs GUI app to access sbcl & connect to sly/slynk.
;; Run with `sbcl --load /path/to/start-slynk.lisp'

(load #p"~/quicklisp/setup.lisp")
(push #p"~/.config/emacs/var/elpaca/builds/sly/slynk/"
      ql:*local-project-directories*)
(ql:quickload :slynk)
(slynk:create-server :port 4005 :dont-close t)
