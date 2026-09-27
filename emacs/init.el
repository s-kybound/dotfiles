;; -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil)
(setq evil-want-keybinding nil)

(require 'evil)
(require 'evil-collection)
(require 'magit)
(require 'paredit)
(require 'treemacs)
(require 'evil-tutor)

(evil-mode 1)
(evil-collection-init)

(setq treemacs-width 30)
(define-key evil-normal-state-map (kbd "C-\\") 'treemacs)

;; for nifty line numbers
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(setq display-line-numbers-widen t)

(global-hl-line-mode 1)
(setq hl-line-sticky-flag nil)

(dolist (hook '(emacs-lisp-mode-hook
                lisp-mode-hook
                lisp-interaction-mode-hook
                scheme-mode-hook))
  (add-hook hook #'paredit-mode))
