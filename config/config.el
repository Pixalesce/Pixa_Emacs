(add-to-list 'image-types 'svg)

(setq custom-file (concat user-emacs-directory "config/custom.el"))
(load custom-file 'noerror)

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(defun pix/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  erc-mode
                  sauron-mode
                  term-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :hook (evil-mode . pix/evil-hook)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
 j (evil-collection-init))

(use-package swiper :ensure t)
(use-package counsel :ensure t)
(use-package counsel
:bind (("M-x" . counsel-M-x)
       ("C-x b" . counsel-ibuffer)
       ("C-x C-f" . counsel-find-file)
       :map minibuffer-local-map
       ("C-r" . 'counsel-minibuffer-history))
:config
(setq ivy-initial-inputs-alist nil)) ;; Disable searches starting with ^
(use-package ivy
:diminish
:bind (("C-s" . swiper)
       :map ivy-minibuffer-map
       ("TAB" . ivy-alt-done)	
       ("C-h" . ivy-next-line)
       ("C-k" . ivy-previous-line)
       ("C-l" . ivy-alt-done)
       :map ivy-switch-buffer-map
       ("C-k" . ivy-previous-line)
       ("C-l" . ivy-done)
       ("C-d" . ivy-switch-buffer-kill)
       :map ivy-reverse-i-search-map
       ("C-k" . ivy-previous-line)
       ("C-d" . ivy-reverse-i-search-kill)))
(ivy-mode 1)

(use-package ivy-rich)
(ivy-rich-mode 1)

(use-package helpful
  :ensure t
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . 'counsel-describe-function)
  ([remap describe-command] . 'helpful-command)
  ([remap describe-variable] . 'counsel-describe-variable)
  ([remap describe-key] . 'helpful-key))











(use-package general
  :config
  (general-create-definer pix/leader-keys
    :keymaps '(normal insert visual motion emacs)
    :prefix "SPC"
    :global-prefix "C-SPC") ;;Cntrl-<SPACE> to access leader in insert mode

  (pix/leader-keys
    "t"  '(:ignore t :wk "toggles")
    "tt" '(counsel-load-theme :wk "choose theme")))

(general-define-key
  "C-M-h" 'counsel-switch-buffer)



(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ; Make ESC quit prompts

(use-package tree-sitter-langs)
(use-package tree-sitter
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(set-face-attribute 'default nil
  :font "Victor Mono"
  :height 160
  :weight 'medium)
(set-face-attribute 'variable-pitch nil ;;non-monospaced fonts
  :font "Helvetica"
  :height 180
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "Victor Mono"
  :height 160
  :weight 'medium)

;; Makes commented text and keywords italics.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic :weight 'light)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-function-name-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-variable-name-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "Victor Mono-16"))

(setq-default line-spacing 0.12)

(setq modus-themes-mode-line '(borderless) ;mode line
      modus-themes-region '(bg-only) ;highlighting
      modus-themes-completions '(moderate)) ;autocompletions

(setq modus-themes-bold-constructs t ;bold function names
      modus-themes-italic-constructs t ;bold comments and stuff
      modus-themes-paren-match '(bold intense) ;highlights parentheses
      modus-themes-syntax '(alt-syntax green-strings yellow-comments) ;syntax style
      modus-themes-fringes 'subtle
      modus-themes-accented t
      modus-themes-prompts '(bold intense))

(setq modus-themes-headings
     '((1 . (rainbow 1.2))
       (2 . (rainbow 1.15))
       (3 . (rainbow 1.1))
       (t . (rainbow semilight 1.05))) ;Headings settings
     modus-themes-scale-headings t) ;Turn on headings scale

(setq modus-themes-org-blocks 'tinted-background) ;;highlight source blocks



(load-theme 'modus-vivendi t)

(use-package all-the-icons
  :if (display-graphic-p)
  :commands all-the-icons-install-fonts
  :init
  (unless (find-font (font-spec :name "all-the-icons"))
    (all-the-icons-install-fonts t)))

(use-package all-the-icons-dired
  :if (display-graphic-p)
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 40))
  :config
 (setq doom-modeline-modal-icon t))

(setq inhibit-startup-message t
      visible-bell t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(icomplete-mode 1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)
(setq display-line-numbers-type 'relative)
;;(setq scroll-margin 12)

(global-hl-line-mode 1)
(add-hook 'org-agenda-finalize-hook #'hl-line-mode)
(blink-cursor-mode -1)

(setq org-directory '$HOME/Desktop/org_mode/)

(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(use-package which-key
  :init
    (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit t
        which-key-separator " → "
        ))

(setq history-length 25)
(savehist-mode 1)

(save-place-mode 1)

(setq use-dialog-box nil)

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

(recentf-mode 1)

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(pix/leader-keys
  "ts" '(hydra-text-scale/body :wk "scale text"))

(use-package rainbow-delimiters
:hook (prog-mode . rainbow-delimiters-mode))

(use-package evil-nerd-commenter
:bind ("M-/" . evilnc-comment-or-uncomment-lines))

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))
      mouse-wheel-progressive-speed nil
      scroll-setp 1
      scroll-margin 10
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)
(setq-default smooth-scroll-margin 0)
