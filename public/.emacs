;;; package -- summary
;;; Commentary:
;;;

;;; Code:
;; Themes path
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;; Set the load path
(setq load-path (cons "~/.emacs.d/elisp" load-path))
;; Vendor load path
(defvar efo/vendor-dir (expand-file-name "vendor" user-emacs-directory))
(unless (file-exists-p efo/vendor-dir)
        (make-directory efo/vendor-dir))
(add-to-list 'load-path efo/vendor-dir)

;; Something
(eval-when-compile
  (defvar package-archive-enable-alist)
  (defvar c-syntactic-element))

;; Load some common lisp features
(eval-when-compile (require 'cl))

;; Load and initialise package manager
(load "package")
(package-initialize)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(setq package-archive-enable-alist '(("melpa" deft magit)))


;; Define list of default packages
(defvar efo/packages '(ac-slime
                          auto-complete
                          autopair
                          cperl-mode
                          dash
                          deft
			  flycheck
                          gist
                          htmlize
                          markdown-mode
                          marmalade
                          nginx-mode
			  pde
                          puppet-mode
                          rainbow-delimiters
                          smex
                          sml-mode
                          yaml-mode)
  "Default packages")

;; Create list of default packages not installed
(defun efo/packages-installed-p ()
  (loop for pkg in efo/packages
        when (not (package-installed-p pkg)) do (return nil)
        finally (return t)))

;; Install them
(unless (efo/packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg efo/packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))


;; Something wrt vendor dir
(dolist (project (directory-files efo/vendor-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

;; Don't make me type out 'yes' and 'no'. Silly emacs
(defalias 'yes-or-no-p 'y-or-n-p)
;; Remove toolbar and menubar. Silly emacs
;; turn off toolbar
(if window-system
    (tool-bar-mode -1))

(menu-bar-mode -1)

;; Color the code
(require 'font-lock)
(global-font-lock-mode t)

;; Smexy! (Remember last used M-x commands)
(setq smex-save-file (expand-file-name ".smex-items" user-emacs-directory))
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

;; Define smartness?
(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

(defun cleanup-region (beg end)
  "Remove tmux artifacts from region."
  (interactive "r")
  (dolist (re '("\\\\│\·*\n" "\W*│\·*"))
    (replace-regexp re "" nil beg end)))

(global-set-key (kbd "C-x M-t") 'cleanup-region)
(global-set-key (kbd "C-c n") 'cleanup-buffer)

;; Change backup behavior to save in a directory, not in a miscellany
;; of files all over the place.
(setq backup-by-copying t      ; don't clobber symlinks
      backup-directory-alist
      '(("." . "~/.local/share/emacs-saves"))    ; don't litter my fs tree
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)       ; use versioned backups

;; Fix? tab
(setq tab-width 4
      indent-tabs-mode nil)
;;colume number
(column-number-mode 1)

;; 120 columns (78 is stupid)
(setq fill-column 120)
(setq auto-fill-mode t)

;; "I always compile my .emacs, saves me about two seconds
;; startuptime. But that only helps if the .emacs.elc is newer
;; than the .emacs. So compile .emacs if it's not."
(defun autocompile   nil
  "compile itself if ~/.emacs"
  (interactive)
  (require 'bytecomp)
  (if (string= (buffer-file-name) (expand-file-name (concat
                                                     default-directory ".emacs")))
      (byte-compile-file (buffer-file-name))))

(add-hook 'after-save-hook 'autocompile)


;; UTF stuff
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(setq inhibit-splash-screen t
            initial-scratch-message nil)


;; Date in modeline
(display-time)
(setq display-time-24hr-format  t
      display-time-day-and-date t
      )

;; Undo limit (640k isnt enough)
(setq undo-limit 90000
      undo-strong-limit 100000
      )

; Org-mode settings
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)


;; perltidy (reloads the file)
;; (autoload 'perltidy "perltidy-mode" nil t) 
;; (autoload 'perltidy-mode "perltidy-mode" nil t)
(global-set-key (kbd "C-c t") 'perltidy)
(global-set-key (kbd "M-g") 'goto-line)

;;Custom configuration
(set-background-color "Black")
(set-foreground-color "White")
(set-cursor-color "White")
(set-frame-font "-adobe-courier-medium-r-normal--12-120-75-75-m-70-iso8859-1")
(autoload 'ldap-mode "ldap-mode")

;; Autoload modes
(setq auto-mode-alist
      (append '(
                ("\\.emacs$" . emacs-lisp-mode)
                ("\\.\\([pP][Llm]\\|al\\)$" . cperl-mode)
                ("\\.cgi$"   . cperl-mode)
                ("\\.ph$"    . cperl-mode)
                ("Build\\.DAM$" . cperl-mode)
                ("\\.pl$"    . cperl-mode)
                ("\\.t$"     . cperl-mode)
                ("\\.tt$"    . tt-mode)
                ("\\.php$"   . html-helper-mode)
                ("\\.schema$" . ldap-mode)
                ("\\.yml$" . yaml-mode)
                ("\\.yaml$" . yaml-mode)
                ("\\.md$" . markdown-mode)
                ("\\.mdown$" . markdown-mode)
                ("\\.pp$" . puppet-mode)
                ) auto-mode-alist))


(setq auto-mode-alist (append auto-mode-alist interpreter-mode-alist))

;; Markdown
(setq markdown-command "pandoc --smart -f markdown -t html")
(setq markdown-css-path (expand-file-name "markdown.css" efo/vendor-dir))

;; C style https://www.kernel.org/doc/Documentation/CodingStyle
(setq c-default-style "linux"
      c-basic-offset 4)

;; Kill whole lines instead of.. something else
(setq kill-whole-line t)

;; Load some extra PERL stuff
(add-to-list 'load-path "~/.emacs.d/elisp/pde/")
(require 'cperl-mode)
(require 'rainbow-delimiters)
(require 'perltidy-mode)

;; Perl magic
(setq cperl-highlight-variables-indiscriminately t)
(setq cperl-invalid-face (quote off))
(setq cperl-font-lock t)
(setq cperl-auto-newline nil)

(defun perltidy-region ()
  "Run perltidy on the current region."
  (interactive)
  (save-excursion
    (shell-command-on-region (point) (mark) "perltidy -q -pro=/home/efo/cvs.local/DAM/Devel/perltidyrc" nil t)))

(defun perltidy-defun ()
  "Run perltidy on the current defun."
  (interactive)
  (save-excursion (mark-defun)
                  (perltidy-region)))


;; Start server
(when (and (daemonp) (locate-library "edit-server"))
  (require 'edit-server)
  (edit-server-start))

(when (locate-library "edit-server")
  (require 'edit-server)
  (setq edit-server-new-frame nil)
  (edit-server-start))

;; Some more C stuff
(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
         (column (c-langelem-2nd-pos c-syntactic-element))
         (offset (- (1+ column) anchor))
         (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Add kernel style
            (c-add-style
             "linux-tabs-only"
             '("linux" (c-offsets-alist
                        (arglist-cont-nonempty
                         c-lineup-gcc-asm-reg
                         c-lineup-arglist-tabs-only))))))

(add-hook 'c-mode-hook
          (lambda ()
            (let ((filename (buffer-file-name)))
              ;; Enable kernel mode for the appropriate files
              (setq indent-tabs-mode t)
              (c-set-style "linux-tabs-only"))))

;; nxml/html stuff
(defvar nxml-bind-meta-tab-to-complete-flag)
(defvar nxml-slash-auto-complete-flag)

(add-to-list 'auto-mode-alist
             '("\.\(html\|htm\|xml\|svg\|wsdl\|xslt\|wsdd\|xsl\|rng\|xhtml\)\'" . nxml-mode) nil)
;; Javascript modes
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))


;; Solarized theme
(load-theme 'solarized-dark t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;#############################################
;To load python templates

(add-hook 'find-file-hooks 'maybe-load-template)
(defun maybe-load-template ()
  (interactive)
  (when (and
         (string-match "\\.py$" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file "~/.emacs.d/templates/template.py")))

(add-hook 'after-init-hook #'global-flycheck-mode)
(defface flymake-message-face
  '((((class color) (background light)) (:foreground "#b2dfff"))
    (((class color) (background dark))  (:foreground "#b2dfff")))
  "Flymake message face")
(allout-mode)

(setq-default save-place t)
