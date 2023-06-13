(add-to-list 'image-types 'svg)

(defvar elpaca-installer-version 0.4)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (kill-buffer buffer)
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;; Don't install anything. Defer execution of BODY
(elpaca nil (message "deferred"))

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
  :init ;;for tweaking evil mode's configuraiton before loading it
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-vsplit-window-right t
        evil-split-window-below t)
  (evil-mode))

(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(use-package evil-tutor) ;;adding in a vim tutor equivalent for evil mode

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  (setq lsp-inlay-hints-enable t)
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
:after lsp)

(use-package lsp-ivy)

(use-package rustic
  ;; :mode "\\.rs\\"
  :config
    (require 'lsp-rust)
    (setq lsp-rust-analyzer-completion-add-call-parenthesis nil)
  :hook (rustic-mode . lsp-deferred))

(use-package general
  :config
  (general-evil-setup t)

  ;; setting up <SPACE> as global leader key
  (general-create-definer dt/leader-keys
    :states '(normal insert visual motion emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC") ;;Meta-<SPACE> to access leader in insert mode

(dt/leader-keys
  "b" '(:ignore t :wk "buffer")
  "bb" '(switch-to-buffer :wk "Switch buffer")
  "bk" '(kill-this-buffer :wk "Kill this buffer")
  "bn" '(next-buffer :wk "Next buffer")
  "bp" '(previous-buffer :wk "Previous buffer")
  "br" '(revert-buffer :wk "Reload buffer"))

(dt/leader-keys
    "f" '(:ignore t :wk "file")
    "fr" '(recentf-open-files :wk "Recent files")
 )

)

(use-package tree-sitter-langs)
(use-package tree-sitter
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(set-face-attribute 'default nil
  :font "Victor Mono"
  :height 180
  :weight 'medium)
(set-face-attribute 'variable-pitch nil ;;non-monospaced fonts
  :font "Helvetica"
  :height 200
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "Victor Mono"
  :height 180
  :weight 'medium)

;; Makes commented text and keywords italics.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "Victor Mono-18"))

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
(use-package command-log-mode)

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

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

(use-package rainbow-delimiters
:hook (prog-mode . rainbow-delimiters-mode))

(use-package evil-nerd-commenter
:bind ("M-/" . evilnc-comment-or-uncomment-lines))
