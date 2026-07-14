;;; font-test.el --- Test if a font is valid in Emacs -*- lexical-binding: t; -*-

;;; Commentary:
;; Define a function to test if a font family is usable in Emacs.  The function
;; can also modify font height in case the default 110 is too large or too
;; small.

;;; Code:
(defun user/font-test (font-family &optional height)
  "Test if FONT-FAMILY is valid by updating :family value of `face-attribute'.
You can also test different font sizes by setting HEIGHT (defaults to 110)."
  (interactive
   (list
    (read-string "Font family: ")
    (let ((s (read-string "Optional: Font size (RET for default): ")))
      (unless (string-empty-p s)
        (string-to-number s)))))
  (unless height
    (setq height 110))
  (set-face-attribute 'default nil
		      :family font-family
		      :height height
		      :weight 'regular))

(provide 'font-test)
;;; font-test.el ends here
