;; -*-emacs-lisp-*-

;;;
;;; Seong-Kook Shin's .emacs initialization file.
;;;

;;;
;;; You can download the latest version of this script at cinsk.org
;;;
;;; $ # make sure that you don't have .emacs.d/ nor .emacs file
;;; $ rm -r .emacs.d .emacs
;;; $ # Get the source file from my repository
;;; $ git clone http://www.cinsk.org/git/emacs-scripts .emacs.d
;;;

;;;
;;; emacs packages for my personal uses are placed in $HOME/.emacs.d
;;;
(setq user-emacs-directory "~/.emacs.d/")

(if (not (file-accessible-directory-p user-emacs-directory))
    (if (yes-or-no-p
         (format "create user directory(%s)? " user-emacs-directory))
        (make-directory user-emacs-directory t)))

(setq load-path (cons (expand-file-name user-emacs-directory) load-path))


(defvar cinsk/loaded-init-files nil
  "List of loaded snippets.")

(defvar cinsk/snippets-directory
  (concat (expand-file-name user-emacs-directory)
          "snippets")
  "Directory contains the init snippets.")

(defmacro cinsk/load-snippet (snippet &rest body)
  "If the last sexp of the BODY results non-nil, load the init script, SNIPPET.

\(fn SNIPPET BODY...)"
  (declare (indent 1) (debug t))
  (let ((sname (make-symbol "SNIPPET")))
    `(let* ((,sname ,snippet)
            (absname (if (file-name-absolute-p ,sname)
                         ,sname
                       (concat (expand-file-name ,cinsk/snippets-directory)
                               "/" ,sname))))
       (unless (member absname cinsk/loaded-init-files)
         (let ((pred (progn ,@body)))
           (when pred
             (condition-case err
                 (progn
                   (load absname)
                   (message "%s loaded" (file-name-nondirectory ,sname))
                   (add-to-list 'cinsk/loaded-init-files absname)
                   t)
               (error (lwarn 'dot-emacs :warning
                             (format "%s: %s: %S" ,sname
                                     (car err) (cdr err)))))))))))

(when (eq window-system 'x)
  ;; enable clipboard
  (setq x-select-enable-clipboard t))


;;; Although it is possible to set font faces in lisp code, I prefer
;;; to use X resource configuration.
;;;
(when nil
  ;; "NanumGothic_Coding-12"
  ;; (add-to-list 'default-frame-alist '(font . "DejaVu Sans Mono-12"))
  ;; (set-face-font 'default "fontset-default")
  ;; (set-fontset-font "fontset-default" '(#x1100. #xffdc)
  ;;                   '("NanumGothic_Coding" . "unicode-bmp"))
  ;; (set-fontset-font "fontset-default" 'ascii
  ;;                   '("NanumGothic_Coding" . "unicode-bmp"))
  ;; (set-fontset-font "fontset-default" 'latin-iso8859-1
  ;;                   '("NanumGothic_Coding" . "unicode-bmp"))
  ;; (set-fontset-font "fontset-default" 'hangul
  ;;                   '("NanumGothic_Coding" . "unicode-bmp"))
  ;; (set-fontset-font "fontset-default" '(#xe0bc. #xf66e)
  ;;                   '("NanumGothic_Coding" . "unicode-bmp"))
  ;; (set-fontset-font "fontset-default" 'kana
  ;;                   '("NanumGothic_Coding" . "unicode-bmp"))
  ;; (set-fontset-font "fontset-default" 'han
  ;;                   '("NanumGothic_Coding" . "unicode-bmp"))
  )



;;;
;;; package
;;;
(let ((pkgdir (concat (file-name-as-directory user-emacs-directory)
                      "package")))
  ;; PKGDIR will contains the last emacs-23 compatible package.el from
  ;; https://github.com/technomancy/package.el
  (when (and (file-readable-p pkgdir)
             (= emacs-major-version 23))
    (add-to-list 'load-path pkgdir))

  (when (and (>= emacs-major-version 23)
             (locate-library "package"))
    (require 'package)
    (add-to-list 'package-archives
                 '("marmalade" . "http://marmalade-repo.org/packages/"))
    ;; According to the package.el, if `package-enable-at-startup' is
    ;; t, it will load all the packages on start up.  But it didn't.
    ;; Perhaps it's a problem related to the version (currently Emacs
    ;; 23).  Thus, I'll force to load it here.
    (package-initialize)))

;; I will install packages that is not managed by packages.el in
;; "$HOME/.emacs.d/site-lisp".
;;
;; Note that packages in this directory has higher priority than others.
(defvar user-site-lisp-directory
  (concat (file-name-as-directory user-emacs-directory) "site-lisp")
  "a directory name that contains packages which are not managed
by package.el")

(defun add-site-lisp-packages (dir)
  "Add the subdirectories of DIR into `load-path'."
  (when (file-accessible-directory-p dir)
    (dolist (elem (directory-files-and-attributes dir))
      (let* ((fname (car elem))
             (attrs (cdr elem))
             (path (expand-file-name
                    (concat (file-name-as-directory dir)
                            fname))))
        (when (and (not (string-equal fname "."))
                   (not (string-equal fname ".."))
                   (eq t (car attrs)))
          ;; Add directories in $HOME/.emacs.d/site-lisp/ to the `load-path'
          (message "load-path: adding %s" path)
          (add-to-list 'load-path path))))))

(add-site-lisp-packages "/usr/local/share/emacs/site-lisp")
(add-site-lisp-packages user-site-lisp-directory)


(defun accessible-directories (&rest dirs)
  "Return the list of directories that are accessible."
  (let ((result nil))
    (mapc (lambda (path)
            (if (and (file-accessible-directory-p path)
                     (not (member (file-name-as-directory path) result)))
                (setq result (cons (file-name-as-directory path) result))))
          dirs)
    result))


(cinsk/load-snippet "darwin"
  (eq system-type 'darwin))


(cinsk/load-snippet "X"
  (eq window-system 'x))


(cinsk/load-snippet "ediff"
  ;; Note that some external packages loads 'ediff by themselves, such
  ;; as magit and color-theme.  Since
  ;; `ediff-make-wide-display-function' should be set before loading
  ;; `ediff, ediff customization should be placed in the first
  ;; place. -- cinsk
  'ediff)


;;;
;;; Due to my preference, I configure fonts of Emacs using X
;;; resources.  If you are not sure, insert following configuration in
;;; your $HOME/.Xdefaults-hostname where hostname is the name of the
;;; host, or the file specified in $XENVIRONMENT.  See X(7) for more.
;;;
;;; Emacs.Fontset-0:-*-DejaVu Sans Mono-*-*-*-*-14-*-*-*-*-*-fontset-dejavu,\
;;;           latin:-*-DejaVu Sans Mono-*-*-*-*-14-*-*-*-*-*-*-*, \
;;;          hangul:-*-NanumGothic_Coding-*-*-*-*-*-*-*-*-*-*-*-*
;;;
;;; Emacs*Fontset-2:-*-Consolas-*-*-*-*-14-*-*-*-*-*-fontset-consolas,\
;;;           latin:-*-Consolas-*-*-*-*-14-*-*-*-*-*-*,\
;;;         hangul:-*-NanumGothic_Coding-*-*-*-*-*-*-*-*-*-*-*
;;;
;;; Emacs.Font: fontset-dejavu
;;;

(cinsk/load-snippet "fonts"
  'fonts)


;;; Sometimes, Emacs asks for the confirmation of a command such as
;;; killing a buffer.  In that case, user should type "yes" or "no"
;;; directly.
;;;
;;; Below configuration let the user uses "y" or "n" instead of using
;;; longer version.
(defalias 'yes-or-no-p 'y-or-n-p)

(defmacro setq-if-equal (symbol old-value new-value &optional nowarn)
  "setq-if-equal set SYMBOL to NEW-VALUE iff it has OLD-VALUE.
It compare the old value with OLD-VALUE using `equal' then
set it to NEW-VALUE if the old value matched.
If NOWARN is nil, and the old value is not matched with the
supplied one, a warning message is generated."
  `(progn
     (if (equal ,symbol ,old-value)
         (setq ,symbol ,new-value)
       (if (not ,nowarn)
           (progn (message "%s has unexpected value `%S'"
                           (symbol-name ',symbol) ,symbol)
                  ,old-value)))))

(defun move-key (keymap old-key new-key)
  "Move the key definition from OLD-KEY to NEW-KEY in KEYMAP."
  (let ((def (lookup-key keymap old-key))
        (alt (lookup-key keymap new-key)))
    (define-key keymap new-key def)
    (define-key keymap old-key nil)
    alt))


;;; Helpers for TAGS manipulation
(setq tags-add-tables 't)               ; do not ask to add new tags table.

(defun safe-visit-tags-table (file &optional local)
  "Call `visit-tags-table' iff FILE is readable"
  (and (file-readable-p file)
       (visit-tags-table file local)))


;;; Set up the keyboard so the delete key on both the regular keyboard
;;; and the keypad delete the character under the cursor and to the right
;;; under X, instead of the default, backspace behavior.
;;;
;; (global-set-key [delete] 'delete-char)
;; (global-set-key [kp-delete] 'delete-char)



(cinsk/load-snippet "cc-mode"
                    'cc-mode)



;;; Emacs generates a backup file (filename plus "~") whenever a file
;;; the first time it is saved.  Uncomment below line to prevents it.
;;;
;; (setq-default make-backup-files nil)

;;;
;;; Window-less system Configuration
;;;
(when window-system
  (menu-bar-mode 1)                    ; -1 to hide, 1 to show
  (tool-bar-mode -1)                   ; -1 to hide, 1 to show
  )

(cinsk/load-snippet "korean"
  enable-multibyte-characters)


;;;
;;; Search and replace related configuration
;;;
(defalias 'qr 'query-replace)
(defalias 'qrr 'query-replace-regexp)

(progn
  ;; The default key binding M-% and C-M-% are too difficult to type.
  ;; Since M-# and C-M-# are not used by official bindings, I'll use them.
  (global-set-key [(meta ?#)] 'query-replace)
  (global-set-key [(control meta ?#)] 'query-replace-regexp)

  ;; During isearch, M-% and C-M-% will also launching replace job
  ;; with the last search string.  Thus, I'll add M-% and C-M-% for
  ;; the consistence.
  (define-key isearch-mode-map [(meta ?#)] 'isearch-query-replace)
  (define-key isearch-mode-map [(control meta ?#)]
    'isearch-query-replace-regexp)

  ;; During isearch, `M-s w' will toggle word search, which is
  ;; difficult to remember, so use `M-W' instead.
  ;;
  ;; Note that `M-w' works as original, `kill-ring-save'.
  (define-key isearch-mode-map [(meta ?W)] 'isearch-toggle-word)
  )



(cinsk/load-snippet "shell"
  'shell)

(cinsk/load-snippet "buffer-menu"
  'buffer-menu)


;;; When a user paste clipboard content in Emacs using mouse button 2,
;;; the content will be pasted in the place at mouse click.  Comment
;;; below line for the default behavior (at mouse click).
(setq mouse-yank-at-point t)


;;;
;;; If you are intended BS (backspace) key to work
;;; correctly on some terminals, uncomment one of below s-exp.
;;;                                                 -- cinsk
;;(global-set-key [C-?] 'backward-delete-char)
;;(global-set-key [C-h] 'backward-delete-char)


(global-set-key "\C-cc" 'compile)
(global-set-key [(control ?c) (control ?c)] 'comment-region)

(global-set-key [?\C-.] 'find-tag-other-window) ; C-x o


(global-set-key [(control c) ?i] 'indent-region)

(global-set-key [(f11)] 'toggle-case-fold-search)

;;;
;;; ICE setup
;;;
(add-to-list 'auto-mode-alist '(".*\\.ice$" . java-mode))

;;;
;;; Abbrev mode, skeletons, and autoload settings
;;;
(when (locate-library "xskel")
  (load-library "xskel"))

(let ((abb_default "~/.abbrev_defs")
      (abb_correct (concat (file-name-as-directory user-emacs-directory)
                           "abbrev_defs")))
  ;; Prefer "~/.emacs.d/abbrev_defs" to "~/.abbrev_defs"
  (setq abbrev-file-name
        (if (file-readable-p abb_correct)
            abb_correct
          (if (file-readable-p abb_default)
              abb_default
            abb_correct))))

(require 'autoinsert)

(let ((aid_correct (concat (file-name-as-directory user-emacs-directory)
                           "insert"))
      (aid_default (if (boundp 'auto-insert-directory)
                       auto-insert-directory
                     "~/insert")))
  (setq auto-insert-directory
        (if (file-accessible-directory-p aid_correct)
            aid_correct
          aid_default)))

(add-hook 'find-file-hook 'auto-insert)

;; navigation


;;;
;;; Use hippie expansion for dynamic abbreviation
;;;
(when (locate-library "hippie-exp")
  (global-set-key [(meta ?/)] 'hippie-expand))


;;;
;;; Switching between buffers using iswitchb
;;;
(iswitchb-mode 1)                       ; smart buffer switching mode
(setq iswitchb-default-method 'maybe-frame) ; ask to use another frame.

;;
;; Normally, switching buffer commands (e.g. `switch-to-buffer' or
;; `iswitchb-buffer') ignore buffer that matched "^ ".
;;
;; When I develop some lisp package, I need to switch to buffers that
;; begins with "^ ".  Thus, I don't use "^ " as the value of
;; `iswitchb-buffer-ignore'.
;;
;; The problem is, sometimes " *Minibuf-1*" buffer will be in the buffer
;; list, which makes me annoying.  Thus, I'll explicitly ignore minibuffer-like
;; names in `iswitchb-buffer-ignore'. -- cinsk
;;
;; (setq iswitchb-buffer-ignore '("^ \\*Minibuf[^*]*\\*"))


;;;

;;;
;;; Minor Mode configuration
;;;

;; imenu mode
;;(add-hook 'c-mode-hook (function (lambda nil (imenu-add-to-menubar))))
;;(add-hook 'c++-mode-hook (function (lambda nil (imenu-add-to-menubar))))

;;(add-hook 'c-mode-hook (function (lambda nil (which-function-mode))))
;;(add-hook 'c++-mode-hook (function (lambda nil (which-function-mode))))

;;(when window-system
;;  (which-function-mode 1))          ; display function names in mode-line

(global-font-lock-mode 1)           ; every buffer uses font-lock-mode
(line-number-mode 1)                ; show line number in mode-line
(column-number-mode 1)              ; show column number in mode-line

(setq resize-minibuffer-mode t)         ; ensure all contents of mini
                                        ; buffer visible

(ffap-bindings)                         ; context-sensitive find-file

;;;
;;; TAB & space setting
;;;
(setq-default indent-tabs-mode nil)     ; do not insert tab character.

(defun source-untabify ()
  "Stealed from Jamie Zawinski's homepage,
http://www.jwz.org/doc/tabs-vs-spaces.html
Remove any right trailing whitespaces and convert any tab
character to the spaces"
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "[ \t]+$" nil t)
      (delete-region (match-beginning 0) (match-end 0)))
    (goto-char (point-min))
    (if (search-forward "\t" nil t)
        (untabify (1- (point)) (point-max))))
  nil)

;; These hook configuration ensures that all tab characters in C, C++
;; source files are automatically converted to spaces on saving.
(defvar untabify-remove-trailing-spaces-on-write-modes
  '(c-mode c++-mode java-mode emacs-lisp-mode lisp-mode nxml-mode)
  "List of major mode that needs to convert tab characters into spaces,
and to remove trailing whitespaces")

(defun untabify-remove-trailing-spaces-on-write ()
  "Utility function that removes tabs and trailing whitespaces"
  (when (memq major-mode untabify-remove-trailing-spaces-on-write-modes)
    (untabify (point-min) (point-max))
    (delete-trailing-whitespace))
  ;; Should return nil so that if this function is registered into
  ;; `write-contents-functions', and if we need to propagate the control
  ;; to the other functions in `write-contents-functions'.
  ;;
  ;; Personally, this function should be registered into
  ;; `before-save-hook' anyway.
  nil)

(add-hook 'before-save-hook 'untabify-remove-trailing-spaces-on-write)

;; As suggested in
;;  http://stackoverflow.com/questions/935723/find-tab-characters-in-emacs,
;;
;; Following sexp visualize tab character.
(add-hook 'font-lock-mode-hook
          '(lambda ()
             (when (memq major-mode
                         untabify-remove-trailing-spaces-on-write-modes)
               (font-lock-add-keywords nil
                                       '(("\t" 0
                                          'trailing-whitespace prepend))))))


(when nil
  (add-hook 'c-mode-hook '(lambda ()
                            (make-local-variable 'write-contents-hooks)
                            (add-hook 'write-contents-hooks 'source-untabify)))
  (add-hook 'c++-mode-hook '(lambda ()
                              (make-local-variable 'write-contents-hooks)
                              (add-hook 'write-contents-hooks 'source-untabify))))


(cinsk/load-snippet "delete"
                    'delete)


(when nil
  ;; Support for GNU global, the source code tag system
  (load-library "gtags")
  (add-hook 'c-mode-hook '(lambda () (gtags-mode 1)))
  (add-hook 'c++-mode-hook '(lambda () (gtags-mode 1))))

;;;
;;; Colors
;;;
;;(set-background-color "rgb:0000/1500/8000")
;;(set-foreground-color "white")
;;(set-cursor-color "")
;;(set-mouse-color "")
;;(set-face-foreground 'highlight "white")
;;(set-face-background 'highlight "slate blue")
;;(set-face-background 'region "slate blue")
;;(set-face-background 'secondary-selection "turquoise")

;;;
;;; emacs server
;;;
;;(server-start)

;;;
;;; I prefer case-sensitive search & replace
;;;
(setq-default case-fold-search nil)
(setq-default tags-case-fold-search nil)

(fset 'find-next-tag "\C-u\256")        ; macro for C-u M-.
(fset 'find-prev-tag "\C-u-\256")       ; macro for C-u - M-.

(global-set-key "\M-]" 'find-next-tag)
(global-set-key "\M-[" 'find-prev-tag)

;;(global-set-key [up]   '(lambda () (interactive) (scroll-down 1)))
;;(global-set-key [down] '(lambda () (interactive) (scroll-up 1)))

(fset 'scroll-other-frame "\C-xo\C-v\C-xo")      ; C-x o C-v C-x o
(fset 'scroll-other-frame-down "\C-xo\366\C-xo") ; C-x o M-v C-x o

(global-set-key [(meta shift prior)] 'scroll-other-frame-down)
(global-set-key [(meta shift next)] 'scroll-other-frame)



(global-set-key [(control meta ?\])] #'forward-page)
(global-set-key [(control meta ?\[)] #'backward-page)



(cinsk/load-snippet "window-frame"
                    'window-frame)

;;;
;;; Markdown mode
;;;
(when (locate-library "markdown-mode")
  (autoload 'markdown-mode "markdown-mode"
    "Major mode for editing Markdown files" t)
  (add-to-list 'auto-mode-alist
               '("\\.md" . markdown-mode)))


;;;
;;; vim-modeline
;;;
(let ((vim-modeline-path (expand-file-name
                          (concat (file-name-as-directory user-emacs-directory)
                                  "vim-modeline"))))
  (when (file-accessible-directory-p vim-modeline-path)
    (add-to-list 'load-path vim-modeline-path)
    (when (locate-library "vim-modeline")
      (require 'vim-modeline)
      (add-hook 'find-file-hook 'vim-modeline/do))))


(cinsk/load-snippet "vcs"
  'version-control-system)


(when (locate-library "winner")
  ;; A history manager for window configuration.
  ;; `C-c left' for undo, `C-c right' for redo
  (require 'winner)
  (winner-mode 1))

(when (locate-library "windmove")
  ;; Select a window by pressing arrow keys.
  (require 'windmove)
  ;; The default modifier is 'shift which is not suitable for me since
  ;; I use `shift-left' and `shift-right' bindings in org-mode.
  ;;
  ;; Since my keyboard (HHK) has separate Alt key (apart from Meta
  ;; key), I use the 'alt instead of 'shift -- cinsk
  (windmove-default-keybindings 'alt))




(defun import-buffer-region (&optional after-import)
  "Copy region from the current buffer to the previous buffer.

Once called, Emacs enters in recursive edit mode.  Marking a region
in some buffer then press \\[exit-recursive-edit] will copy the region
into the buffer at the invocation time.

If the function AFTER-IMPORT is non-nil, this function will call
AFTER-IMPORT with the buffer where the user press
\\[exit-recursive-edit].  In the AFTER-IMPORT, the mark is set to
the beginning of the inserted text, and the point is set to the
end of the inserted text.

This function uses `recursive-edit' internally."
  (interactive)
  (let* ((map (current-global-map))
         (old-binding (lookup-key map [(control meta ?c)])))
    (substitute-key-definition
     'exit-recursive-edit
     'exit-import-buffer-region map)
    ;; (define-key map [(control meta ?c)] 'exit-import-buffer-region)

    (let ((old-buffer (current-buffer))
          (src-buffer (unwind-protect
                          (catch 'exit-from-import
                            (message "Use `%s' when done, or use `%s' to abort."
                                     (substitute-command-keys "\\[exit-import-buffer-region]")
                                     (substitute-command-keys "\\[abort-recursive-edit]"))
                            (recursive-edit))
                        ;; (define-key map [(control meta ?c)] old-binding))))
                        (substitute-key-definition
                         'exit-import-buffer-region
                         'exit-recursive-edit
                         map))))
      (when (buffer-live-p old-buffer)
        (let ((display-buffer-reuse-frames t)
              start end)
          (pop-to-buffer old-buffer)
          (with-current-buffer src-buffer
            (when (and mark-active
                       (or (and transient-mark-mode
                                (use-region-p))
                           (not transient-mark-mode)))
              (setq start (region-beginning)
                    end (region-end))))
          (when (and start end)
            (push-mark)
            (insert-buffer-substring src-buffer start end)
            (and after-import
                 (funcall after-import src-buffer))
            (pop-mark)))))))

(defun exit-import-buffer-region ()
  (interactive)
  (throw 'exit-from-import (current-buffer)))

(defun line-numbers-on-region (begin end &optional start)
  "Insert line numbers on the region.

When called interactively, it insert the line number starting
from 1, in the region.  A numeric prefix argument specifies the
starting number."
  (interactive (list
                (region-beginning)
                (region-end)
                (if current-prefix-arg
                    (prefix-numeric-value current-prefix-arg)
                  1)))
  (unless start (setq start 1))
  (let ((begin (region-beginning))
        (end (region-end)))
    (save-restriction
      (let* ((lines (count-lines begin end))
             (width (length (format "%d" (1- (+ lines start)))))
             (fmt (format "%%%dd: " width)))
        (goto-char begin)
        (beginning-of-line)
        (dotimes (i lines)
          (insert (format fmt (+ start i)))
          (forward-line))))))

(global-set-key [(control ?c) ?n] #'line-numbers-on-region)


;;(require 'autofit-frame)
;;(add-hook 'after-make-frame-functions 'fit-frame)
;;
;;(add-hook 'temp-buffer-show-hook
;;          'fit-frame-if-one-window 'append)

(cinsk/load-snippet "lisp"
  'lisp)


(cinsk/load-snippet "latex"
  'latex-mode)


(defun fill-text-line-paragraph (begin end)
  "Convert each line in the region to a filled-paragraph"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region begin end)

      (let ((begin (set-marker (make-marker) begin))
            (end (set-marker (make-marker) end)))
        (set-marker-insertion-type end t)
        (beginning-of-line)
        (goto-char begin)
        (while (eq (forward-line) 0)
          (newline))

        (goto-char begin)
        (while (progn
                 (fill-paragraph nil)
                 (eq (forward-line) 0)))))))

(global-set-key [(control ?c) ?q] 'fill-text-line-paragraph)



(cinsk/load-snippet "mmm-mode"
  (let ((mmm-dir (expand-file-name
                  (concat (file-name-as-directory user-emacs-directory)
                          "mmm-mode"))))
    ;; If MMM mode is installed in $HOME/.emacs.d/mmm-mode/
    (when (file-accessible-directory-p mmm-dir)
      (add-to-list 'load-path mmm-dir)
      (add-to-list 'Info-directory-list mmm-dir))
    (locate-library "mmm-auto")))



(cinsk/load-snippet "nxml"
  (or (locate-library "nxml-mode")
      ;; For legacy nxml-mode which does not use `provide' for nxml-mode.
      (locate-library "rng-auto")))


(cinsk/load-snippet "dired"
  'dired)


;;;
;;; Launch view-mode when visiting other's file.
;;;
(defun file-uid (filename)
  (caddr (file-attributes (expand-file-name filename))))

(defun smart-view-mode ()
  (let ((file buffer-file-name))
    (if (not (null file))                 ; if buffer has file name,
        (let ((fuid (file-uid file)))     ;
          (and (not (null fuid))          ; if file exists,
               (not (eq fuid (user-uid))) ; if the user/owner differs,
               (not (eq (user-uid) 0))    ; if not root,
               (view-mode 1))))))         ; enable `view-mode'.

(add-hook 'find-file-hook 'smart-view-mode)



;;;
;;; cscope binding
;;;
;;; You need to install cscope(1) and xcscope.el to use below bindings
;;; Read xcscope.el packaged in cscope source tarball. It can be obtained
;;; from http://cscope.sourceforge.net/
;;;
(when (locate-library "xcscope")
  (require 'xcscope))

;;;
;;; Version Control
;;;
(global-set-key [(control x) (control q)] 'vc-toggle-read-only)


;;(split-window-horizontally)

(cinsk/load-snippet "mail"
  'mail-news-gnus)


(defmacro time-loop (n &rest body)
  "Return time before and after N iteration of BODY.

DO NOT USE THIS MACRO.  INSTEAD, USE `benchmark'."
  (declare (indent 1) (debug t))
  `(let ((t1 (current-time)))
     (dotimes (i ,n)
       ,@body)
     (time-subtract (current-time) t1)))

(defmacro save-font-excursion (face &rest body)
  "Save the :font property of given FACE during the execution of BODY."
  (declare (indent 1) (debug t))
  `(let ((oldfont (face-attribute ,face :font)) ret)
     (setq ret (progn ,@body))
     (or (string= oldfont (face-attribute ,face :font))
         (set-face-attribute ,face nil :font oldfont))
     ret))


(cinsk/load-snippet "color" 'color-theme)



;;;
;;; YAML mode
;;;
(when (locate-library "yaml-mode")
  (require 'yaml-mode)
  (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode)))


;;;
;;; CSS mode
;;;
(eval-after-load "css-mode"
  '(setq cssm-indent-function #'cssm-c-style-indenter))
(autoload 'css-mode "css-mode" "CSS editing major mode" t)
(add-to-list 'auto-mode-alist '("\\.css\\'" . css-mode))


;;;
;;; htmlize
;;;
(when (locate-library "htmlize")
  (require 'htmlize)
  (setq htmlize-convert-nonascii-to-entities nil))


;;;
;;; Calender
;;;
(require 'calendar)

(global-set-key [(control f12)] 'calendar)

(let ((my-diary-file (concat (file-name-as-directory user-emacs-directory)
                             "diary")))
  (if (file-readable-p my-diary-file)
      (setq diary-file my-diary-file)))

(setq mark-holidays-in-calendar t)

(when (and (boundp 'diary-file)
           (file-readable-p diary-file))
  (setq mark-diary-entries-in-calendar t))

(add-hook 'diary-display-hook 'fancy-diary-display)

(setq local-holidays
      '((holiday-fixed 11 1 "삼성전자 창립일")))

(let ((cal-korea-path (expand-file-name
                       (concat (file-name-as-directory user-emacs-directory)
                               "cal-korea-x"))))
  (when (file-accessible-directory-p cal-korea-path)
    (add-to-list 'load-path cal-korea-path)
    (when (locate-library "cal-korea-x")
      (require 'cal-korea-x)
      (setq holiday-general-holidays cal-korea-x-korean-holidays))))


(cinsk/load-snippet "org" (locate-library "org"))


;;;
;;; Emacs-wiki support
;;;
;; (require 'emacs-wiki)


;;;
;;; ispell(aspell) configuration
;;;
;;; Currently neither of them provides Korean dictionary.
;;; Currently, ispell complained that it does not have proper dictionary in
;;; Korean language environment.
(eval-after-load "ispell"
  '(progn
     (setq ispell-dictionary "english")))



;;;
;;; Do not display splash screen on startup
;;;

;; Show the `*scratch*' buffer (even in the presence of command-line
;; arguments for files)
;;
;; (setq initial-buffer-choice t)

;; Disable the startup screen
(setq inhibit-splash-screen t)



;;;
;;; ERC (IRC client) settings
;;;

(when (locate-library "erc")
  (eval-after-load "erc"
    '(progn
       (setq erc-default-coding-system '(cp949 . undecided))
       (setq erc-nick '("cinsk" "cinsky" "cinsk_" "cinsk__"))
       (setq erc-user-full-name "Seong-Kook Shin")
       (setq erc-server "localhost:8668"))))


;;;
;;; erlang configuration
;;;



(when (locate-library "erlang-start")
  (setq erlang-cinsk-init nil)  ; for one time init
  ;; Note on key-binding of erlang-mode.
  ;;
  ;; `erlang-mode-map' is initialized inside of `erlang-mode'.  This
  ;; means that we cannot use `erlang-mode-map' in any of
  ;; `erlang-load-hook', nor `eval-after-load'.
  ;;
  ;; It may be possible that call `erlang-mode-commands' directly,
  ;; but I don't want to do that, in case of future modification.
  (add-hook 'erlang-mode-hook
            (lambda ()
              (unless erlang-cinsk-init
                (define-key erlang-mode-map [(control ?c) ?b]
                  'erlang-compile)
                (define-key erlang-mode-map [(control ?c) ?\!]
                  'erlang-shell-display)
                (setq erlang-cinsk-init t))))
  (require 'erlang-start))



(cinsk/load-snippet "ruby"
  (locate-library "ruby-mode"))

(cinsk/load-snippet "python"
  (locate-library "python-mode"))


(cinsk/load-snippet "maven" 'maven)


;;;
;;; w3m
;;;
(when (locate-library "w3m")
  (setq w3m-use-cookies t)
  (require 'w3m-load))




;;;
;;; browse-url configuration
;;;
(require 'browse-url)

(defun browse-url-w3m (url &optional new-window)
  (interactive (browse-url-interactive-org "W3M URL: "))
  (w3m url))

(cond ((memq system-type '(windows-nt ms-dos cygwin))
       ;; Use system default configuration
       nil)

      ((or (display-graphic-p)
           (= (call-process-shell-command "xset q") 0))
       ;; Even if (display-graphic-p) returns nil,
       ;; it may be possible to launch X application.
       (cond ((executable-find "chromium")
              (setq browse-url-browser-function 'browse-url-generic
                    browse-url-generic-program (executable-find "chromium")))
             ((executable-find browse-url-firefox-program)
              (setq browse-url-browser-function 'browse-url-firefox))))

      ((fboundp 'w3m)
       (setq browse-url-browser-function 'browse-url-w3m)))

(add-to-list 'browse-url-filename-alist
             '("\\`/home/\\([^/]+\\)/public_html/\\(.*\\)\\'" .
               "http://localhost/~\\1/\\2"))

;; gentoo: /var/www/localhost/htdocs
;; ubuntu: /var/www/
;; centos: /var/www/html/  /var/www/cgi-bin/
(add-to-list 'browse-url-filename-alist
             '("\\'/var/www/localhost/htdocs/\\(.*\\)\\'" .
               "http://localhost/\\1"))


;;;
;;; gnuplot
;;;
(when (locate-library "gnuplot")
  (autoload 'gnuplot-mode "gnuplot" "gnuplot major mode" t)
  (autoload 'gnuplot-make-buffer "gnuplot" "open a buffer in gnuplot-mode" t)

  (setq auto-mode-alist (append '(("\\.gp$" . gnuplot-mode))
                                auto-mode-alist)))


;;;
;;; go lang
;;;
(let* ((godir "/usr/local/go")
       (gldir (concat (file-name-as-directory godir) "misc/emacs")))
  (when (file-accessible-directory-p gldir)
    (add-to-list 'load-path gldir 'append)
    (when (locate-library "go-mode-load")
      (require 'go-mode-load))))



;;;
;;; lua
;;;
(when (locate-library "lua-mode")
   (autoload 'lua-mode "lua-mode" "Major mode for lua script")
   (add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-mode)))

;;;
;;; YASnippet -- http://code.google.com/p/yasnippet/
;;;
(when (locate-library "yasnippet")
  ;; tested with yasnippet 0.8.0 (beta)
  (require 'yasnippet)

  ;; The official document describes the snippets directory in
  ;; "~/.emacs.d/plugins/yasnippet-x.y.z/snippets", whereas Gentoo
  ;; yasnippet package installed them in
  ;; "/usr/share/emacs/etc/yasnippet/snippets".
  (setq yas-snippet-dirs (accessible-directories
                          "/usr/share/emacs/etc/yasnippet/snippets"
                          "~/.emacs.d/plugins/yasnippet/snippets"
                          (concat (file-name-directory
                                   (locate-library "yasnippet"))
                                  "snippets")
                          "~/.emacs.d/yasnippets"))

  ;; While old version (e.g. 0.6.1b) uses `yas/root-directory', and
  ;; provides `yas/reload-all', new version uses `yas-snippets-dirs'
  ;; and provides `yas-reload-all'.
  (if (not (fboundp 'yas-reload-all))
      (progn
        (setq yas/root-directory yas-snippet-dirs)
        (and (fboundp 'yas/reload-all)
             (yas/reload-all)))
    ;; Otherwise, use the new interface.
    (and (fboundp 'yas-reload-all)
         (yas-reload-all))))


(cinsk/load-snippet "scala"
  ;; Currently, Scala 2.8.x is not provided by gentoo portage. Thus, I
  ;; will use the binary distribution from the Scala repository in
  ;; /opt/scala
  (when (not (locate-library "scala-mode-auto"))
    (let* ((scala-mode-path "/opt/scala/misc/scala-tool-support/emacs")
           (scala-file (concat (file-name-as-directory scala-mode-path)
                               "scala-mode-auto.el")))
      (if (file-exists-p scala-file)
          (add-to-list 'load-path scala-mode-path))))
  (locate-library "scala-mode-auto"))



;;;
;;; ESS(Emacs Speaks Statistics) setting for R.
;;;
(when (locate-library "ess-site")
  (require 'ess-site))


;;; To save & load Emacs session, following lines should be the last
;;; line in this file.
;;;
;;; The first time you save the state of the Emacs session, you must
;;; do it manually, with the command `M-x desktop-save'. Once you have
;;; done that, exiting Emacs will save the state again--not only the
;;; present Emacs session, but also subsequent sessions. You can also
;;; save the state at any time, without exiting Emacs, by typing `M-x
;;; desktop-save' again.
;;;
;;; In order for Emacs to recover the state from a previous session,
;;; you must start it with the same current directory as you used when
;;; you started the previous session.  This is because `desktop-read'
;;; looks in the current directory for the file to read.  This means
;;; that you can have separate saved sessions in different
;;; directories; the directory in which you start Emacs will control
;;; which saved session to use.

;;(desktop-load-default)
;;(desktop-read)


;;; I frequently uses `narrow-to-region', which is disabled by default
;;; because it confuse users who do not understand it.  If you do not
;;; use it or do not understand it, comment below lines.
(put 'narrow-to-region 'disabled nil)


;;;
;;; GNU Emacs Calculator Configuration
;;;
(autoload 'calc "calc" "The Emacs Calculator" t)
(global-set-key [f10] 'calc)
(global-set-key [(control f10)] 'quick-calc)



;;(global-set-key [f2] 'ff-find-other-file)
;;(global-set-key [f3] 'dired-jump)




;;; Local Variables:
;;; coding: utf-8
;;; End:
