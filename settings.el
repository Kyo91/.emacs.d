
(setq my-emacsd (file-name-as-directory "~/.emacs.d"))
(add-to-list 'load-path "/usr/share/emacs24/site-lisp/mu4e")
(setq inhibit-startup-message t)
(column-number-mode 1)
(setq sentence-end-double-space nil)
(setq enable-recursive-minibuffers)
(setq lexical-binding t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)
(global-visual-line-mode)
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq gc-cons-threshold (* 20 1024 1024))
(require 'cl)

;; No tabs
(setq-default indent-tabs-mode nil)

(setq scroll-margin 1
      scroll-conservatively 10000
      scroll-up-aggressively 0.01
      scroll-down-aggressively 0.01
      auto-window-vscroll nil)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(set-register ?i '(file . "~/.emacs.d/settings.org"))
(set-register ?s '(file . "~/Dropbox/Notes & HW/schedule.org"))

;;; Sets 'p' key to act as a register for a macro to produce category tags for org captures
(set-register ?p [registerv
                  [tab tab 58 80 82 79 company-dummy-event 80 69 82 84 73 69 83 58 10 34 67 65 backspace backspace backspace 58 67 65 84 69 71 79 82 89 58 return tab 58 69 78 68 company-dummy-event 58 16 5 32]
                  #[(k)
                    "\301\302\303\304!\"!\207"
                    [k princ format "a keyboard macro:\n   %s" format-kbd-macro]
                    5]
                  kmacro-execute-from-register
                  #[(k)
                    "\301!c\207"
                    [k format-kbd-macro]
                    2]])

(require 'server)
(unless (server-running-p)
  (server-start))

;; Help, source commands
(define-key 'help-command (kbd "C-l") 'find-library)
(define-key 'help-command (kbd "C-f") 'find-function)
(define-key 'help-command (kbd "C-k") 'find-function-on-key)
(define-key 'help-command (kbd "C-v") 'find-variable)

(global-subword-mode 1)

(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (expand-file-name ".places" user-emacs-directory))

(recentf-mode)
(setq
 recentf-max-menu-items 30
 recentf-max-saved-items 5000
 )

;; Backup Management
(setq backup-directory-alist '((".*" . "~/.emacs.d/tmp/"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control 1)

;; Autosave Management
(defvar my-auto-save-folder "~/.emacs.d/tmp/")
(add-to-list 'auto-save-file-name-transforms
             (list "\\(.+/\\)*\\(.*?\\)" (expand-file-name "\\2" my-auto-save-folder))
             t)

(load "~/.private.el")

;; Renaming Buffer/File Snippet
(defun rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

(global-set-key (kbd "C-x C-r") 'rename-current-buffer-file)

(defun smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

(global-set-key [remap move-beginning-of-line]
                'smarter-move-beginning-of-line)

(defun python-docstring ()
  (interactive)
  (dotimes (x 6)
    (insert "\'"))
  (backward-char 3))
;; (add-hook 'python-mode-hook '(global-set-key (kbd "C-x \'") 'python-docstring))
(global-set-key (kbd "C-x \'") 'python-docstring)

(defun sudo-edit (&optional arg)
  "Edit currently visited file as root.

With a prefix ARG prompt for a file to visit.
Will also prompt for a file to visit if current
buffer is not visiting a file."
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
                         (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(set-fringe-mode '(nil . 0))

;; Enabled commands
(put 'set-goal-column 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(require 'uniquify)

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

(require 'frame)
(add-to-list 'default-frame-alist '(cursor-color . "#c6c6c6" ))

(blink-cursor-mode 1)
(setq blink-cursor-blinks 5)

(electric-indent-mode -1)

(when window-system
  (set-frame-size (selected-frame) 160 80)
  (set-face-attribute 'default nil :height 130))

;; ELPA/Marmalade
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("elpy" . "http://jorgenschaefer.github.io/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package hydra
   :ensure t
   :config
   (defhydra hydra-zoom (global-map "<f2>")
     "zoom"
     ("g" text-scale-increase "in")
     ("l" text-scale-decrease "out"))

   (defhydra hydra-text (global-map "C-c t")
     "text"
     ("a" align-regexp "align")
     ("f" toggle-text-mode-auto-fill "auto-fill")
     ("s" sort-lines "sort")))

;;  (require 'moe-theme)
;;  (moe-theme-set-color 'black)
;;  (load-theme 'moe-dark)
(use-package monokai-theme
  :config (load-theme 'monokai))

(use-package smart-mode-line
    :ensure t
    :init (setq sml/theme 'dark)
    :config
    (add-to-list 'sml/replacer-regexp-list '("^~/Dropbox/Notes & HW/" ":N&H:"))
    (add-to-list 'sml/replacer-regexp-list '("^~/Dropbox/Notes & HW/System/" ":2110:"))
    (sml/setup))

(use-package yasnippet
  :ensure t
  :init (setq yas-snippet-dirs '("~/.emacs.d/yasnippet-snippets"))
  :config
  (define-key yas-minor-mode-map (kbd "M-/") 'yas-expand)
  (define-key yas-minor-mode-map (kbd "TAB") nil)
  (yas/initialize)
  (yas-global-mode 1)
  )

(use-package company
  :ensure t
  :config
  (global-company-mode 1)

  (setq company-backends (remove 'company-eclim company-backends)))

(use-package flx-ido
  :ensure t
  :config (flx-ido-mode 1))

(use-package ido-vertical-mode
  :ensure t
  :init (setq ido-vertical-define-keys 'C-n-and-C-p-only)
  :config (ido-vertical-mode))

(use-package ido
  :ensure smex
  :init
  (setq ido-enable-flex-matching t
        ido-enable-prefix nil
        ido-case-fold nil
        ido-create-new-buffer 'always
        ido-max-prospects 10
        ido-use-faces nil)
  :config
  (global-set-key (kbd "M-X") 'smex-major-mode-commands))

(use-package helm
    :ensure t
    :config
    (helm-mode 1)
    (setq helm-quick-update t
          helm-idle-delay 0.01
          helm-input-idle-delay 0.01)
    (add-to-list 'helm-completing-read-handlers-alist '(find-file . ido))

    (global-set-key (kbd "C-x C-m") 'helm-command-prefix)
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
    (define-key helm-map (kbd "C-z") 'helm-select-action)
    (define-key helm-map (kbd "C-M-i") 'helm-select-action)
    (global-set-key (kbd "C-x b") 'helm-mini)

    (global-set-key (kbd "C-h a") 'helm-apropos)

    (global-set-key (kbd "M-y") 'helm-show-kill-ring)
    (global-set-key (kbd "<menu>") 'helm-M-x)
    (global-set-key (kbd "M-x") 'helm-M-x)
    (global-set-key (kbd "C-x i") 'helm-semantic-or-imenu)

;;; Fancy Dislay settings
    (setq helm-display-header-line nil)
    (set-face-attribute 'helm-source-header nil :height 1.0)
    (helm-autoresize-mode 1)
    (setq helm-autoresize-max-height 30)
    (setq helm-autoresize-min-height 30)
    (setq helm-split-window-in-side-p t))

(use-package helm-descbinds
    :ensure t
    :config
    (helm-descbinds-mode))

(use-package helm-swoop
    :ensure t
    :config
    (global-set-key (kbd "C-x j") 'helm-swoop)
    (global-set-key (kbd "M-i") 'helm-multi-swoop)

    ;; When doing isearch, hand the word over to helm-swoop
    (define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
    ;; From helm-swoop to helm-multi-swoop-all
    (define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)
    (setq helm-swoop-split-direction 'split-window-vertically))

;; (setq
;;  helm-gtags-ignore-case t
;;  helm-gtags-auto-update t
;;  helm-gtags-use-input-at-cursor t
;;  helm-gtags-pulse-at-cursor t
;;  helm-gtags-prefix-key "\C-cg"
;;  helm-gtags-suggested-key-mapping t
;;  )

;; (require 'helm-gtags)
;; ;; Enable helm-gtags-mode
;; (add-hook 'dired-mode-hook 'helm-gtags-mode)
;; (add-hook 'eshell-mode-hook 'helm-gtags-mode)
;; (add-hook 'c-mode-hook 'helm-gtags-mode)
;; (add-hook 'c++-mode-hook 'helm-gtags-mode)
;; (add-hook 'asm-mode-hook 'helm-gtags-mode)

;; (define-key helm-gtags-mode-map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
;; (define-key helm-gtags-mode-map (kbd "C-j") 'helm-gtags-select)
;; (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
;; (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
;; (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
;; (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)

(use-package projectile
    :ensure t
    :config
(projectile-global-mode)
(global-set-key (kbd "C-c h") 'helm-projectile))

;; Keybindings
(global-set-key "\C-x\C-b" 'electric-buffer-list)
(global-set-key "\M-g" 'goto-line)
(global-set-key (kbd "M-<f4>") 'save-buffers-kill-terminal) ;; Old binding for C-x C-c
(global-set-key (kbd "C-x C-c") 'delete-frame)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "RET") 'newline-and-indent)

(global-set-key (kbd "<f7>") 'eshell)

(use-package helm-flycheck)

(use-package flycheck
    :ensure t
    :config
    (custom-set-variables
     '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages))
    (define-key flycheck-mode-map (kbd "C-c ! h") 'helm-flycheck)
    (global-flycheck-mode)
    (add-hook 'emacs-lisp-mode-hook (lambda () (flycheck-mode -1)))
    (add-hook 'ess-mode-hook (lambda () (flycheck-mode -1))))

(use-package magit
    :ensure t
    :bind ("C-c C-c g" . magit-status)
    :config
    (setq magit-last-seen-setup-instructions "1.4.0"))

(use-package eyebrowse
  :ensure t
  :init
  (setq eyebrowse-keymap-prefix (kbd "C-z"))
  :config
  (eyebrowse-mode))

(use-package smartparens
  :ensure t
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  (show-smartparens-global-mode t)
  (sp-use-paredit-bindings)
  (smartparens-global-strict-mode)
  (sp-with-modes '(c-mode c++-mode java-mode)
    (sp-local-pair "{" nil :post-handlers '(("||\n[i]" "RET")))
    (sp-local-pair "/*" "*/" :post-handlers '((" | " "SPC")
                                              ("* ||\n[i]" "RET")))))

(use-package ggtags
    :ensure t
    :config
    (add-hook 'c-mode-common-hook
              (lambda ()
                (when (derived-mode-p 'c-mode 'java-mode 'asm-mode)
                  (ggtags-mode 1))))
    (define-key ggtags-mode-map (kbd "M-,") 'pop-tag-mark))

;; GDB Many Windows
(setq
 ;; use gdb-many-windows by default
 gdb-many-windows t

 ;; Non-nil means display source file containing the main routine at startup
 gdb-show-main t)

(use-package jedi
  :ensure t
  :config
  (add-hook 'python-mode-hook 'jedi:setup)
  (setq jedi:complete-on-dot 't)
  (setq jedi:tooltip-method nil)
  (setq jedi:use-shortcuts 't)
  (setq jedi:environment-virtualenv
        (list "virtualenv3" "--system-site-packages")))

(defun use-paredit-mode ()
  (enable-paredit-mode)
  (smartparens-mode -1))

(use-package paredit
    :ensure t
    :config
    (add-hook 'slime-mode-hook 'use-paredit-mode)
    (add-hook 'slime-repl-mode-hook 'use-paredit-mode)
    (add-hook 'slime-hook 'use-paredit-mode)
    (add-hook 'scheme-mode-hook 'use-paredit-mode)
    (add-hook 'emacs-lisp-mode-hook 'use-paredit-mode)
    (add-hook 'geiser-mode-hook 'use-paredit-mode)
    (add-hook 'geiser-repl-mode-hook 'use-paredit-mode)
    (add-hook 'clojure-mode-hook 'enable-paredit-mode)
    (add-hook 'cider-repl-mode-hook 'enable-paredit-mode))

(defun paredit-commands-sheet ()
  (interactive)
  (elscreen-create)
  (elscreen-screen-nickname "Paredit Cheat Sheet")
  (find-file "~/PareditCheatsheet.png"))

(use-package aggressive-indent
    :ensure t
    :config
    (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
    (add-hook 'lisp-mode-hook #'aggressive-indent-mode)
    (add-hook 'clojure-mode-hook #'aggressive-indent-mode))

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)

(use-package pretty-symbols
  :ensure t
  :init
  (add-hook 'emacs-lisp-mode 'lisp-prettify)
  (add-hook 'slime-mode-hook 'lisp-prettify)
  (add-hook 'slime-repl-mode-hook 'lisp-prettify)
  (add-hook 'clojure-mode-hook 'lisp-prettify)
  (add-hook 'cider-mode-hook 'lisp-prettify))

(defun lisp-prettify ()
  (setf pretty-symbol-categories '(lambda))
  (pretty-symbols-mode))

(put 'unless-let 'clojure-indent-function 2)
(put 'facts 'clojure-indent-function 1)

(use-package cider
    :ensure t
    :config
    (add-hook 'cider-repl-mode-hook 'rainbow-delimiters-mode)
    (setq cider-repl-use-pretty-printing t))

(defun clj-ref-setup ()
  (clj-refactor-mode 1)
  (cljr-add-keybindings-with-prefix "C-c C-c"))

(use-package clj-refactor
    :ensure t
    :config
    (add-hook 'clojure-mode-hook 'clj-ref-setup))

(put 'fresh 'scheme-indent-function 1)
(put 'run 'scheme-indent-function 2)
(put 'run* 'scheme-indent-function 1)

(add-hook 'geiser-repl-mode-hook 'rainbow-delimiters-mode)
(add-hook 'geiser-mode-hook 'rainbow-delimiters-mode)

(use-package paxedit
    :ensure t
    :init
    (add-hook 'lisp-mode-hook 'paxedit-mode)
    (add-hook 'emacs-lisp-mode-hook 'paxedit-mode)
    (add-hook 'cider-repl-mode-hook 'paxedit-mode)
    (add-hook 'geiser-mode-hook 'paxedit-mode)
    (add-hook 'geiser-repl-mode-hook 'paxedit-mode)
    (add-hook 'clojure-mode-hook 'paxedit-mode)
    :config
    (define-key paxedit-mode-map (kbd "M-<right>") 'paxedit-transpose-forward)
    (define-key paxedit-mode-map (kbd "M-<left>") 'paxedit-transpose-backward)
    (define-key paxedit-mode-map (kbd "M-<up>") 'paxedit-backward-up)
    (define-key paxedit-mode-map (kbd "M-<down>") 'paxedit-backward-end)
    (define-key paxedit-mode-map (kbd "M-b") 'paxedit-previous-symbol)
    (define-key paxedit-mode-map (kbd "M-f") 'paxedit-next-symbol)
    (define-key paxedit-mode-map (kbd "C-%") 'paxedit-copy)
    (define-key paxedit-mode-map (kbd "C-S-k") 'paxedit-kill)
    (define-key paxedit-mode-map (kbd "C-*") 'paxedit-delete)
    (define-key paxedit-mode-map (kbd "C-^") 'paxedit-sexp-raise)
    (define-key paxedit-mode-map (kbd "M-u") 'paxedit-symbol-change-case)
    (define-key paxedit-mode-map (kbd "C-@") 'paxedit-symbol-copy)
    (define-key paxedit-mode-map (kbd "C-#") 'paxedit-symbol-kill))

;; (use-package lispy
;;   :ensure t
;;   :init
;;   (add-hook 'emacs-lisp-mode-hook 'lispy-mode)
;;   (add-hook 'clojure-mode-hook 'lispy-mode))

(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))

(use-package irony
  :ensure t
  :init
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)

  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  (add-to-list 'company-backends 'company-irony))

(use-package cc-mode
  :ensure t
  :config (setq c-default-style "linux")
  )

(add-hook 'c++-mode-hook (lambda () (setq flycheck-clang-language-standard "c++11")))
(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11")))
(define-key c++-mode-map (kbd "<f5>") #'cmake-ide-compile)

(use-package company-c-headers
  :ensure t
  :config
  (add-to-list 'company-c-headers-path-system "/usr/include/c++/4.8/")
  (add-to-list 'company-backends 'company-c-headers))

(use-package rtags
  :ensure t
  :config
  (rtags-enable-standard-keybindings)
  )

(use-package cmake-ide
  :ensure t
  :init (require 'rtags)
  :config (cmake-ide-setup))

(use-package tex
  :ensure nil
  :init
  :config
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-save-query nil)
  (TeX-global-PDF-mode t)
  (setq-default TeX-engine 'xetex)
  ;; (add-to-list 'TeX-output-view-style
  ;;              '("^pdf$" "." "mupdf %o %(outpage)"))
  )

(add-hook 'latex-mode-hook 'flyspell-mode)

;; Javadoc Lookup
(global-set-key (kbd "C-h j") 'javadoc-lookup)

(require 'cedet)
(require 'semantic)
;; (load "semantic/loaddefs.el")
(setq semantic-default-submodes '(global-semantic-idle-scheduler-mode
                                  global-semanticdb-minor-mode
                                  global-semantic-idle-summary-mode
                                  global-semantic-mru-bookmark-mode))
(semantic-mode 1)
;; (require 'malabar-mode)
;; (add-to-list 'auto-mode-alist '("\\.java\\'" . malabar-mode))

;; (require 'eclim)
;; (require 'eclimd)
;; (global-eclim-mode)
;; (require 'company-emacs-eclim)
;; (company-emacs-eclim-setup)
;; (defun my-eclim-keys ()
;;   (local-set-key (kbd "C-c C-e p r") 'eclim-run-class))
;; (add-hook 'java-mode-hook 'my-eclim-keys)

(use-package ess-site
  :ensure nil)
(use-package ess-utils
  :ensure nil)

;; TODO: Figure out why below doesn't work.
;; (defvar evil-p nil)

;; (defun my-evil-init ()
;;   (interactive)
;;   (progn
;;     (if evil-p
;;         (progn
;;           (message "Evil Mode Enabled")
;;           (setq evil-p t))
;;       (progn
;;         (message "Evil Mode Disabled")
;;         (setq evil-p nil)))
;;     (evil-mode)))

(use-package evil-leader
  :config (evil-leader/set-leader ",")
  )

(use-package evil
  :ensure evil-leader
  :defer t
  :init (setq evil-toggle-key "C-`")
  (global-evil-leader-mode 1)
  :config (evil-mode 1))


(use-package evil-matchit
  :ensure evil
  :config (global-evil-matchit-mode 1))


(use-package evil-surround
  :ensure evil
  :config (global-evil-surround-mode 1))


(use-package evil-smartparens
  :ensure evil
  :config (add-hook 'smartparens-enabled-hook #'evil-smartparens-mode))


(use-package evil-nerd-commenter
  :config (evilnc-default-hotkeys))

(use-package org
  :ensure t
  :init
  (setq org-directory "~/Dropbox/org")
  (setq org-default-notes-file (concat org-directory "/notes.org"))
  (setq org-agenda-files  '("~/Dropbox/org"))

  (setq org-todo-keywords
        '((sequence "TODO" "|" "DONE")
          (sequence "|" "CANCELED")))

  (add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode))

  (setq org-pretty-entities 't)
  (setq org-pretty-entities-include-sub-superscripts nil)
  (setq org-agenda-span 'week)
  (setq org-agenda-start-on-weekday nil)
  (setq org-agenda-start-day "-2d")
  :config
  (run-at-time "12:55" 3600 'org-save-all-org-buffers)
  (define-key org-mode-map (kbd "C-x -") #'org-cycle-list-bullet))

(use-package cdlatex
    :ensure t
    :init (add-hook 'org-mode-hook 'turn-on-org-cdlatex))

(global-set-key (kbd "<f12>") 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(define-key global-map (kbd "<f6>") 'org-capture)

;; Enable MobileOrg
(setq org-mobile-inbox-for-pull "~/Dropbox/org/flagged.org")
(setq org-mobile-directory "~/Dropbox/Apps/MobileOrg")

(defun cap-temp (key name id)
  "A simple function to create new capture templates."
  (list key name 'entry (list 'file+headline "~/Dropbox/org/todo.org" id)
        "* TODO %?\n"))

(defun add-capture-template (capture-template)
  "Simple function to facilitate adding capture-templates"
  (add-to-list 'org-capture-templates capture-template))

(setq org-capture-templates
      (list (cap-temp "u" "Unsorted" "Unsorted")
            (cap-temp "t" "TA" "CS 2050")))

;;; Projects
(add-capture-template (cap-temp "e" "Evolution" "EvolutionSim"))
(add-capture-template (cap-temp "b" "BakaParser" "BakaParser"))

;;; Classes
(add-capture-template (cap-temp "a" "Artificial Intelligence" "CS 3600"))
(add-capture-template (cap-temp "m" "Machine Learning" "CS 4640"))
(add-capture-template (cap-temp "p" "Probability Statistics" "MATH 3215"))
(add-capture-template (cap-temp "c" "Advanced Combinatorics" "CS 3012"))
(add-capture-template (cap-temp "s" "Systems and Networks" "CS 2200"))

(use-package ox-latex
  :ensure nil
  :init
  (unless (boundp 'org-latex-classes)
    (setq org-latex-classes nil))
  :config
  (setq 'org-export-with-toc nil)
  (add-to-list 'org-latex-packages-alist
               '("margin=0.5in" "geometry"))
  (add-to-list 'org-latex-classes
               '("article"
                 "\\documentclass{article}"
                 ("\\section{%s}" . "\\section*{%s}"))))

;; savehist mode
(savehist-mode 1)
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

(use-package avy
  :ensure t
  :bind (("C-:" . avy-goto-char-2)
         ("M-:" . avy-goto-word-or-subword-1)))

(use-package ace-window
    :ensure t
    :bind (("C-x o" . other-window)
           ("C-x p" . ace-window))
    :init
    (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package clean-aindent-mode
    :ensure t
    :init
    (add-hook 'prog-mode-hook 'clean-aindent-mode))

(use-package rainbow-delimiters
    :ensure t
    :init
    (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package guide-key
    :ensure t
    :init
    (setq guide-key/guide-key-sequence '("C-x r" "C-x 4" "C-x v" "C-x 8" "C-c" "C-x c" "C-c p" "C-h"))
    (setq guide-key/recursive-key-sequence-flag t)
    (setq guide-key/popup-window-position 'bottom)
    :config
    (guide-key-mode 1))

(use-package multiple-cursors
    :ensure t
    :bind (("C-S-c C-S-c" . mc/edit-lines)
           ("C-S-c C-e" . mc/edit-ends-of-lines)
           ("C-S-c C-a" . mc/edit.beginnings-of-lines)
           ("C->" . mc/mark-next-like-this)
           ("C-<" . mc/mark-previous-like-this)))

(use-package visual-regexp
  :ensure visual-regexp-steroids
  :bind (("C-c C-s" . vr/query-replace)
         ("C-c s" . vr/replace)
         ("C-c m" . vr/mc-mark)
         ("C-r" . vr/isearch-backward)
         ("C-s" . vr/isearch-forward)))

(use-package anzu
    :ensure t
    :config
    (global-anzu-mode 1))

(use-package undo-tree
    :ensure t
    :config
(global-undo-tree-mode 1))

(use-package volatile-highlights
    :ensure t
    :config (volatile-highlights-mode t))

(message "Emacs is ready to go!")
