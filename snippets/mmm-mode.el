;; -*-emacs-lisp-*-

;;;
;;; MMM mode configuration
;;;
(eval-after-load "mmm-mode"
  ;; It seems that mmm-mode 0.4.8 will reset the mmm-related face
  ;; attributes after loading mmm-mode.el.  To prevent resetting,
  ;; set the background of the faces AFTER loading mmm-mode.el 
  '(progn
     ;; By default, mmm-mode uses faces with bright background for
     ;; the submodes.   I don't like the bright background for most faces.
     (set-face-background 'mmm-code-submode-face "black")
     (set-face-background 'mmm-declaration-submode-face "black")
     (set-face-background 'mmm-default-submode-face "black")))

(require 'mmm-auto)

;; DO NOT SET `mmm-global-mode' to t!!!  If you do in mmm-mode
;; 0.4.8, some mysterious bugs will happen.  Particularly, on ediff
;; control panel will not listen to your key input on ediff-patch-*
;; command.
(setq mmm-global-mode 'maybe)

;; `mmm-submode-decoration-level' can be 0, 1, or 2. (0: no color)
(setq mmm-submode-decoration-level 2)

(setq mmm-mode-ext-classes-alist 
      '((xhtml-mode nil html-js)
        (xhtml-mode nil embedded-css)
        (html-mode nil html-js)
        (html-mode nil embedded-css)
        (nxml-mode nil html-js)
        (nxml-mode nil embedded-css)
        ))

