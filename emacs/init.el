;;; init.el --- Main init -*- lexical-binding: t; -*-

(defconst my/modules-dir (expand-file-name "modules" user-emacs-directory))
(add-to-list 'load-path my/modules-dir)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; Configure package archives
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/packages/")))

(setq use-package-always-ensure t)
(setq straight-use-package-by-default t)

(setq inhibit-startup-screen t
      make-backup-files nil
      auto-save-default t
      create-lockfiles nil
      indent-tabs-mode nil
      tab-width 2
      visible-bell t
      display-line-numbers-type 'relative
      split-height-threshold nil
      split-width-threshold 120)

(set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 140)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(column-number-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(winner-mode 1)
(delete-selection-mode 1)

(global-set-key (kbd "C-x C-b") #'ibuffer)
(global-set-key (kbd "C-x O") #'previous-window-any-frame)

(use-package doom-themes
  :config
  (load-theme 'doom-one t))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1))

(use-package which-key
  :custom
  (which-key-idle-delay 0.4)
  :init
  (which-key-mode 1))

(use-package nerd-icons)

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

;; Vertico for vertical completion for the emacs minibuffer.
(use-package vertico
  :init
  (vertico-mode))

;; Emacs minibuffer configurations.
(use-package emacs
  :custom
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p))

;; A bunch of great search and navigation commands
(use-package consult
   :hook (completion-list-mode . consult-preview-at-point-mode)
   :custom
   (consult-preview-key nil)
   (consult-narrow-key nil)
   :config
   (consult-customize consult-theme consult-line consult-line-at-point :preview-key '(:debounce 0.2 any))
 )

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings)))

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Annotations in the minibuffer, i.e a description of the function next to the name in M-x
(use-package marginalia
  :init
  (marginalia-mode))

;; In buffer completions, think lsp completions
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-cycle t) ;; Enable cycling for `corfu-next/previous'
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)
        ("C-n" . corfu-next)
        ([tab] . corfu-next)
        ("C-p" . corfu-previous)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous))
  :init
  (global-corfu-mode))

;; Completion style and fuzzy matching
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt) ;; if a treesitter grammar can't be found for the language detected in the buffer, prompt me to install it
  :config
  (treesit-auto-add-to-auto-mode-alist 'all) ;; if a treesitter grammar is found for the language detected in the buffer, use the corresponding language-ts-mode
  (global-treesit-auto-mode))

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package projectile
  :custom
  (projectile-project-search-path '("~/code" "~/Developer" "~/dotfiles"))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (projectile-mode 1))

(use-package treemacs
  :custom
  (treemacs-width 32)
  (treemacs-follow-after-init t)
  (treemacs-is-never-other-window t)
  :bind
  (("C-c t t" . treemacs)
   ("C-c t f" . treemacs-find-file)
   ("C-c t p" . treemacs-add-and-display-current-project)))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package flycheck
  :init
  (global-flycheck-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'character))

(use-package apheleia
  :config
  (apheleia-global-mode 1))

(use-package vterm
  :bind ("C-c t v" . vterm))

(use-package eglot
  :straight nil
  :hook ((python-mode python-ts-mode js-mode js-ts-mode typescript-ts-mode
          go-mode go-ts-mode rust-mode rust-ts-mode nix-mode) . eglot-ensure)
  :bind
  (:map eglot-mode-map
        ("C-c e f" . eglot-format)
        ("C-c e r" . eglot-rename)
        ("C-c e a" . eglot-code-actions)))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package markdown-mode
  :mode "\\.md\\'")

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package json-mode
  :mode "\\.json\\'")

(use-package dockerfile-mode
  :mode "Dockerfile\\'")

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

(setq org-directory "~/Notes"
      org-default-notes-file (expand-file-name "inbox.org" org-directory)
      org-agenda-files (list org-directory)
      org-startup-indented t
      org-hide-emphasis-markers t
      org-log-done 'time)

(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c l") #'org-store-link)

(setq org-capture-templates
      '(("t" "Task" entry
         (file+headline "~/Notes/inbox.org" "Tasks")
         "* TODO %?\n  %U\n")
        ("n" "Note" entry
         (file+headline "~/Notes/inbox.org" "Notes")
         "* %?\n  %U\n")
        ("j" "Journal" entry
         (file+datetree "~/Notes/journal.org")
         "* %?\nEntered on %U\n")))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/Notes/roam"))
  (org-roam-completion-everywhere t)
  :bind
  (("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   ("C-c n g" . org-roam-graph)
   ("C-c n c" . org-roam-capture))
  :config
  (org-roam-db-autosync-mode 1))

(use-package helpful
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h x" . helpful-command)))

(defun my/open-keyboard-shortcuts ()
  "Open the dotfiles keyboard shortcut guide."
  (interactive)
  (find-file "~/.config/keyboard-shortcuts.md"))

(global-set-key (kbd "C-c ?") #'my/open-keyboard-shortcuts)
