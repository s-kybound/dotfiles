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

(dolist (hook '(emacs-lisp-mode-hook
                lisp-mode-hook
                lisp-interaction-mode-hook
                scheme-mode-hook))
  (add-hook hook #'paredit-mode))
