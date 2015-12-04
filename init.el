;;; package --- Nathan's Emacs
;;; Commentary:
;;; Extensive use of `use-package`

;;; Code:

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
(add-to-list 'load-path "~/.emacs.d/vendor/use-package")
(require 'use-package)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
  '(custom-safe-themes
     (quote
       ("c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default)))

 '(safe-local-variable-values (quote ((c-file-offsets (innamespace . 0))))))

(use-package dash :ensure t)
(use-package exec-path-from-shell :ensure t :init (exec-path-from-shell-initialize))

(defun print-point () (interactive) (message "%d" (point)))

;; Theme.
;; ================================================================================

(use-package hc-zenburn-theme
  :load-path "vendor/hc-zenburn-theme"
  :commands (load-theme)
  :init (require 'hc-zenburn-theme))

(use-package smart-mode-line
  :ensure t
  :commands (sml/setup sml/apply-theme)
  :config (progn
          (setq sml/shorten-directory t)
          (setq sml/shorten-modes t)
          (setq sml/name-width 30)
          (setq sml/numbers-separator "")
          (setq sml/show-trailing-N nil)
          (setq sml/show-frame-identification nil)
          (setq sml/mule-info nil)
          (setq sml/show-client nil)
          (setq sml/show-remote nil)
          (setq sml/position-percentage-format nil)))


;; EVIL
;; ================================================================================

(use-package evil
  :ensure t
  :commands (evil-mode
              evil-define-key
              evil-set-initial-state
              evil-add-hjkl-bindings
              evil-leader/set-key
              evil-leader/set-key-for-mode)
  :init (progn
          (setq evil-want-C-u-scroll t
                evil-overriding-maps nil
                evil-intercept-maps nil
                evil-esc-delay 0 ; Prevent esc from translating to meta key in terminal mode
                ; Cursor
                evil-emacs-state-cursor  '("red" box)
                evil-normal-state-cursor '("gray" box)
                evil-visual-state-cursor '("gray" box)
                evil-insert-state-cursor '("gray" bar)
                evil-motion-state-cursor '("gray" box))

          (use-package evil-leader
            :ensure t
            :commands (global-evil-leader-mode)
            :config (evil-leader/set-leader ","))

          (use-package evil-search-highlight-persist
            :ensure t
            :commands (global-evil-search-highlight-persist))

          (use-package evil-commentary
            :ensure t
            :commands evil-commentary-mode)

          (use-package evil-snipe
            :ensure t
            :commands (evil-snipe-mode evil-snipe-override-mode))

          (use-package evil-surround
            :ensure t
            :commands (global-evil-surround-mode evil-surround-mode))

          (use-package evil-matchit
            :ensure t
            :commands (global-evil-matchit-mode evil-matchit-mode))

          (use-package evil-jumper
            :ensure t
            :commands (global-evil-jumper-mode evil-jumper-mode)))

  :config (progn
            (global-evil-leader-mode)
            (evil-snipe-mode 1)
            (global-evil-search-highlight-persist)
            (evil-commentary-mode)
            (evil-snipe-override-mode 1)
            (global-evil-surround-mode 1)
            (global-evil-matchit-mode 1)
            (global-evil-jumper-mode)

            ;; Window management
            (global-set-key (kbd "C-q") 'delete-window)
            (global-set-key (kbd "C-j") 'evil-window-next)
            (global-set-key (kbd "C-k") 'evil-window-prev)
            (define-key evil-normal-state-map (kbd "C-q") 'delete-window)
            (define-key evil-normal-state-map (kbd "C-j") 'evil-window-next)
            (define-key evil-normal-state-map (kbd "C-k") 'evil-window-prev)
            (define-key evil-normal-state-map (kbd "C-l") 'evil-window-increase-width)
            (define-key evil-normal-state-map (kbd "C-h") 'evil-window-decrease-width)
            (define-key evil-insert-state-map (kbd "C-j") 'comment-indent-new-line)

            (define-key evil-normal-state-map (kbd "-")
              (lambda ()
                (interactive)
                (split-window-vertically)
                (other-window 1)))

            (define-key evil-normal-state-map (kbd "|")
              (lambda ()
                (interactive)
                (split-window-horizontally)
                    (other-window 1)))

            (evil-leader/set-key "w" 'save-buffer)
            (evil-leader/set-key "i" 'evil-window-move-far-left)
            (evil-leader/set-key "a" 'align-regexp)
            (evil-leader/set-key "SPC" 'evil-search-highlight-persist-remove-all)
            (evil-leader/set-key "m i" (lambda () (interactive) (shell-make "install")))
            (evil-leader/set-key "m r" (lambda () (interactive) (shell-make "run")))
            (evil-leader/set-key "m b" (lambda () (interactive) (shel-make "build")))
            (evil-leader/set-key "m c" (lambda () (interactive) (shel-make "clean")))
            (evil-leader/set-key "m s" (lambda () (interactive) (shel-make "setup")))
            (evil-leader/set-key "m t" (lambda () (interactive) (shell-make "test")))

            ;; Buffer Management
            (define-key evil-visual-state-map (kbd "SPC") 'evil-search-forward)
            (define-key evil-normal-state-map (kbd "SPC") 'evil-search-forward)
            (define-key evil-visual-state-map (kbd "C-i") 'indent-region)

            ;; Default keys for emacs state
            (defun apply-emacs-defaults-to-mode (mode)
              (let ((keymap-symbol (intern (concat (symbol-name mode) "-map"))))
                (evil-delay
                  `(and (boundp ',keymap-symbol) (keymapp (symbol-value ',keymap-symbol)))
                  `(let ((map (symbol-value ',keymap-symbol)))
                     (dolist (k '("h" "j" "k" "l" "v"))
                       (-when-let (def (lookup-key map k))
                         (define-key map (upcase k) def)
                         (define-key map k nil)))
                     (evil-add-hjkl-bindings map 'emacs
                       "v" 'evil-visual-char))
                  'after-load-functions t nil
                  (format "evil-define-emacs-defaults-in-%s" (symbol-name keymap-symbol)))))

            (dolist (mode evil-emacs-state-modes) (apply-emacs-defaults-to-mode mode))
            (add-function :after (symbol-function 'evil-set-initial-state)
              (lambda (mode state) (when (eq state 'emacs) (apply-emacs-defaults-to-mode mode))))))


;; Utilities
;; ================================================================================

(use-package linum-relative
  :load-path "vendor/linum-relative"
  :commands linum-relative-on
  :init (setq linum-relative-format "%3s   "))

(use-package popwin
  :ensure t
  :commands popwin-mode
  :init (setq popwin:special-display-config  '(("^\\*magit:.*\\*$" :regexp t :position top :height 20)
                                                   ("^\\*helm.*\\*$" :regexp t :position bottom)
                                                   ("^\\*shell:.*\\*$" :regexp t :position bottom :noselect t :tail t :stick t)
                                                   (help-mode :position bottom :noselect t :stick t)
                                                   (completion-list-mode :noselect t)
                                                   (grep-mode :noselect t)
                                                   (occur-mode :noselect t)
                                                   ("*Warnings*" :noselect t)
                                                   ("*GHC Error*" :noselect t)
                                                   ("*Miniedit Help*" :noselect t)
                                                   ("*undo-tree*" :width 60 :position right)))
  :config (progn
            (evil-define-key 'normal popwin:keymap (kbd "q") 'popwin:close-popup-window)))

(use-package smartparens
  :ensure t
  :commands (smartparens-global-mode show-smartparens-global-mode)
  :init (use-package smartparens-config)
  :config
  (sp-local-pair 'makefile-mode "$(" ")")
  (sp-local-pair 'makefile-bsdmake-mode "$(" ")")
  (evil-define-key 'insert smartparens-mode-map
            (kbd "C-l") 'sp-forward-sexp
            (kbd "C-h") 'sp-backward-sexp
            (kbd "C-e") 'sp-down-sexp
            (kbd "C-y") 'sp-up-sexp
            (kbd "C-k") 'sp-splice-sexp-killing-backward
            (kbd "C-j") 'sp-rewrap-sexp
            (kbd "C-c") 'sp-convolute-sexp
            (kbd "M-i") 'sp-forward-slurp-sexp
            (kbd "M-o") 'sp-forward-barf-sexp))

(use-package writeroom-mode
  :ensure t
  :commands writeroom-mode
  :init (progn
          (use-package focus
            :commands focus-mode
            :ensure t)
          (setq writeroom-restore-window-config t)
          (setq writeroom-width 120)
          (evil-leader/set-key "," 'writeroom-mode))
  :config (progn
            (add-to-list 'writeroom-global-effects
              (lambda (arg)
                (interactive)
                (linum-mode (* -1 arg))
                ;; (focus-mode arg)
                (flycheck-mode (* -1 arg))))))

(use-package undo-tree
  :diminish undo-tree-mode)

(use-package editorconfig
  :ensure t
  :commands editorconfig-mode
  :config (progn
            (add-to-list 'edconf-indentation-alist '(swift-mode swift-indent-offset))
            (add-to-list 'edconf-indentation-alist '(haskell-mode haskell-indent-spaces))
            (add-to-list 'edconf-indentation-alist '(evil-mode evil-shift-width))))

(use-package smex
  :ensure t
  :commands smex
  :bind (("M-x" . smex)
         ("≈" . smex)))

(use-package shell
  :functions shell-make
  :init (progn
          (evil-set-initial-state 'shell-mode 'normal)
          (add-hook 'shell-mode-hook 'read-only-mode)
          (defun shell-make (command)
            "Call `make *command*` in the projectile root directory under a buffer named '*shell:make*'"
           (interactive)
            (projectile-with-default-dir (projectile-project-root)
              (async-shell-command (format "make %s" command) (format "*shell:make %s*" command)))))
  :config (progn
            (evil-define-key 'normal shell-mode-map (kbd "q") 'delete-window)
            (define-key shell-mode-map (kbd "C-c C-c") (lambda () (interactive) (delete-process (buffer-name))))))

(use-package projectile
  :ensure t
  :diminish projectile-mode
  :commands projectile-global-mode
  :init (progn
          (setq projectile-require-project-root nil)
          (setq projectile-enable-caching t)
          (setq projectile-completion-system 'ido)
          (setq projectile-indexing-method 'alien))
  :config (progn
            (add-to-list 'projectile-project-root-files ".projectile")
            (add-to-list 'projectile-project-root-files ".git")
            (add-to-list 'projectile-globally-ignored-directories ".cache")
            (add-to-list 'projectile-globally-ignored-directories ".tmp")
            (add-to-list 'projectile-globally-ignored-directories "tmp")
            (add-to-list 'projectile-globally-ignored-directories "node_modules")
            (add-to-list 'projectile-globally-ignored-directories "bower_components")))

(use-package perspective
  :ensure t
  :commands persp-mode
  :init (progn
          (use-package persp-projectile
            :ensure t)))

(use-package dired
  :init (progn
          (setq dired-use-ls-dired nil))
  :config (progn
            (define-key evil-normal-state-map (kbd "C-@") 'persp-switch)
            (define-key evil-normal-state-map (kbd ")") 'persp-next)
            (define-key evil-normal-state-map (kbd "(") 'persp-prev)
            (evil-leader/set-key "p k" 'persp-kill)
            (evil-define-key 'normal dired-mode-map
              (kbd "m") nil
              (kbd "r") 'revert-buffer
              (kbd "md") 'dired-do-delete
              (kbd "mc") 'dired-do-copy
              (kbd "mm") 'dired-do-rename
              (kbd "mad") 'dired-create-directory
              (kbd "maf") 'find-file)
            (evil-leader/set-key "kr" 'dired)))

(use-package git-gutter
  :ensure t
  :diminish git-gutter-mode
  :commands global-git-gutter-mode
  :config (progn
            (git-gutter:linum-setup)
            (define-key evil-normal-state-map (kbd "] c") 'git-gutter:next-hunk)
            (define-key evil-normal-state-map (kbd "[ c") 'git-gutter:previous-hunk)
            (evil-leader/set-key "g a" 'git-gutter:stage-hunk)
            (evil-leader/set-key "g r" 'git-gutter:revert-hunk)))

(use-package magit
  :ensure t
  :init (progn
          (evil-set-initial-state 'git-rebase-mode 'emacs)
          (evil-set-initial-state 'text-mode 'insert)
          (evil-set-initial-state 'git-commit-major-mode 'insert)

          (evil-leader/set-key
            "g l" 'magit-log
            "g c" 'magit-commit
            "g C" 'magit-commit-amend
            "g s" 'magit-status
            "g d" 'magit-diff-unstaged
            "g D" 'magit-diff-staged
            "g b" 'magit-blame
            "g w" 'magit-stage-file))

  :config (progn
            (evil-define-key 'emacs git-rebase-mode-map
              (kbd "s") 'git-rebase-squash
              (kbd "p") 'git-rebase-pick
              (kbd "r") 'git-rebase-reword
              (kbd "e") 'git-rebase-edit)))

(use-package flycheck
  :ensure t
  :diminish (flycheck-mode . " f")
  :commands global-flycheck-mode
  :init (progn
          (setq flycheck-idle-change-delay 6)
          (setq flycheck-check-syntax-automatically '(mode-enabled idle-change)))
  :config (progn
            (define-key evil-normal-state-map (kbd "] e") 'next-error)
            (define-key evil-normal-state-map (kbd "[ e") 'previous-error)))

(use-package yasnippet
  :ensure t
  :commands yas-global-mode
  :diminish (yas-minor-mode . " y")
  :init (progn
          (setq yas-snippet-dirs '("~/.emacs.d/.snippets/yasnippet-snippets"
                                    "~/.emacs.d/.snippets/personal")))
  :config (progn
            (evil-define-key 'insert yas-minor-mode-map (kbd "C-e") 'yas-expand)
            (define-key yas-keymap (kbd "C-e") 'yas-next-field-or-maybe-expand)))

(use-package helm
  :ensure t
  :commands helm-mode
  :init (progn
          (require 'helm-config)

          (use-package helm-projectile
            :ensure t
            :config (progn
                      (global-set-key (kbd "C-p") 'helm-projectile)
                      (define-key evil-normal-state-map (kbd "C-p") 'helm-projectile)
                      (define-key evil-normal-state-map (kbd "C-b") 'helm-projectile-switch-to-buffer)
                      (evil-leader/set-key "kb" 'helm-projectile-find-dir)
                      (define-key helm-map (kbd "C-l") 'projectile-invalidate-cache)))

          (use-package helm-ag
            :ensure t
            :init (progn (use-package grep))
            :config (progn (define-key evil-normal-state-map (kbd "C-s") 'helm-projectile-ag)))

          (use-package helm-dash
            :ensure t
            :init (progn
                    (setq helm-dash-docsets-path "~/.docset")
                    (setq helm-dash-common-docsets '("HTML" "CSS")))
            :config (progn
                      (evil-leader/set-key "f" 'helm-dash-at-point)
                      (define-key evil-normal-state-map (kbd "C-f") 'helm-dash)
                      (add-hook 'prog-mode-hook
                        (lambda ()
                          (interactive)
                          (setq helm-current-buffer (current-buffer))))))

          (use-package helm-swoop
            :ensure t
            :config (progn
                        (evil-leader/set-key "sb" 'helm-swoop)
                        (evil-leader/set-key "sa" 'helm-multi-swoop-all)))

          (use-package helm-flycheck
            :ensure t
            :config (evil-leader/set-key "e l" 'helm-flycheck)))

  :config (progn
            (helm-autoresize-mode 1)
            (define-key helm-map (kbd "C-b") 'helm-keyboard-quit)
            (define-key helm-map (kbd "C-p") 'helm-keyboard-quit)
            (define-key helm-map (kbd "C-j") 'helm-next-line)
            (define-key helm-map (kbd "C-k") 'helm-previous-line)
            ; Helm buffers
            (define-key helm-buffer-map (kbd "C-d") 'helm-buffer-run-kill-buffers)))

(use-package company
  :ensure t
  :diminish " c"
  :commands global-company-mode
  :defines company-dabbrev-downcase
  :init (progn
          (setq company-dabbrev-downcase nil)
          (setq company-tooltip-align-annotations t))
  :config (progn
            ; Swap some keybindings
            (define-key company-active-map (kbd "<backtab>") 'company-select-previous)
            (define-key company-active-map (kbd "C-j") 'company-select-next)
            (define-key company-active-map (kbd "C-k") 'company-select-previous)
            (define-key company-active-map (kbd "C-i") 'company-select-next)
            (define-key company-active-map (kbd "C-o") 'company-select-previous)
            ; Okay lets setup company backends the way we want it, in a single place.
            (setq company-backends
              '( company-css
                 company-elisp
                 company-clang
                 ( company-capf
                   company-dabbrev-code
                   company-keywords
                   company-files
                   company-dabbrev
                   :with company-yasnippet)))))


;; LANGUAGE PACKS
;; ================================================================================

(use-package text-mode
  :preface (provide 'text-mode)
  :no-require t
  :init (progn
          (add-hook 'text-mode-hook 'turn-on-auto-fill)
          (setq-default fill-column 80)))

(use-package js2-mode
  :ensure t
  :diminish js2-minor-mode
  :commands (js2-mode js-mode js2-minor-mode)
  :defines helm-dash-docsets
  :init (progn
          (use-package tern
            :diminish " T"
            :commands (tern-mode)
            :ensure t
            :init (progn
                    (add-hook 'js-mode-hook 'tern-mode)))
          (use-package company-tern
            :ensure t
            :config (progn
                      (add-to-list 'company-backends 'company-tern)))
          (setq js2-highlight-level 3)
          (setq js2-mode-show-parse-errors nil)
          (setq js2-mode-show-strict-warnings nil)
                                        ; Use js2-mode as a minor mode (preferred way)
          (add-hook 'js-mode-hook 'js2-minor-mode)
          (add-to-list 'interpreter-mode-alist '("node" . js-mode)))
  :config (progn
            (add-hook 'js2-minor-mode-hook
              (lambda ()
                (interactive)
                (setq-local helm-dash-docsets
                  '("Javascript" "NodeJS"))))))

(use-package web-mode
  :ensure t
  :preface (progn
             (defun jsxhint-predicate ()
               (and (executable-find "jsxhint")
                 (buffer-file-name)
                 (string-match ".*\.jsx?$" (buffer-file-name)))))
  :commands web-mode
  :init (progn
          (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.liquid\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.tag\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.html.twig\\'" . web-mode))
          (add-to-list 'auto-mode-alist '("\\.html.jsx\\'" . web-mode))
          (add-to-list 'magic-mode-alist '("\/\*\*.*@jsx" . web-mode))

          (flycheck-define-checker jsxhint
            "A JSX syntax and style checker based on JSXHint."
            :command ("jsxhint" source)
            :error-patterns ((error line-start (1+ nonl) ": line " line ", col " column ", " (message) line-end))
            :predicate jsxhint-predicate
            :modes (web-mode))

          (add-to-list 'flycheck-checkers 'jsxhint)

          (use-package emmet-mode
            ;; Can't diminish this, because the logic relies on
            ;; reading the mode-line.
            ;; :diminish " e"
            :ensure t
            :commands emmet-mode
            :init (progn
                    (add-hook 'sgml-mode-hook 'emmet-mode)
                    (add-hook 'css-mode-hook  'emmet-mode)
                    (add-hook 'web-mode-hook 'emmet-mode))
            :config (progn
                    (evil-define-key 'insert emmet-mode-keymap
                      (kbd "C-j") 'emmet-expand-line))))
  :config (progn
            (add-hook 'web-mode-hook
              (lambda ()
                (interactive)
                (setq-local helm-dash-docsets '("Javascript" "HTML" "CSS"))))
            (add-hook 'web-mode-hook (lambda () (yas-activate-extra-mode 'js-mode)))
            (add-hook 'web-mode-hook 'rainbow-mode)
            (define-key prog-mode-map (kbd "C-x /") 'web-mode-element-close)))

(use-package fish-mode
  :ensure t
  :commands fish-mode)

(use-package less-css-mode
  :ensure t
  :commands less-css-mode
  :init (progn
          (add-to-list 'auto-mode-alist '("\\.less\\'" . less-css-mode))))

(use-package stylus-mode
  :ensure t
  :commands stylus-mode
  :init (progn
          (add-to-list 'auto-mode-alist '("\\.stylus\\'" . stylus-mode))))

(use-package scss-mode
  :ensure t
  :init (progn
          (add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))
          (setq scss-compile-at-save nil)))

(use-package php-mode
  :ensure t
  :commands php-mode)

(use-package markdown-mode
  :ensure t
  :commands markdown-mode)

(use-package lua-mode
  :ensure t
  :commands lua-mode)

(use-package swift-mode
  :load-path "vendor/swift-mode"
  :commands swift-mode
  :init (progn
          (add-to-list 'auto-mode-alist '("\\.swift\\'" . swift-mode))
          (use-package company-sourcekit
            :load-path "vendor/company-sourcekit"
            :config (progn
                      (add-to-list 'company-backends 'company-sourcekit)))))

(use-package dockerfile-mode
  :ensure t
  :commands dockerfile-mode
  :init (progn
          (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))))

(use-package puppet-mode
  :ensure t
  :commands puppet-mode)

(use-package yaml-mode
  :ensure t
  :commands yaml-mode)


(use-package haskell-mode
  :ensure t
  :commands (haskell-mode haskell-interactive-mode)
  :init (use-package stack-mode
          :load-path "vendor/stack-ide/stack-mode"
          :commands stack-mode
          :init (add-hook 'haskell-mode-hook 'stack-mode)
          :config (evil-define-key 'normal
                    stack-mode-map (kbd "M-i") 'stack-mode-info)
          (evil-leader/set-key-for-mode 'haskell-mode
            "t" 'stack-mode-type))

  (setq haskell-hoogle-url "https://www.stackage.org/lts/hoogle?q=%s")
  (setq haskell-process-type 'stack-ghci)
  (add-hook 'haskell-mode-hook (lambda () (turn-on-haskell-indentation)))

  :config (evil-define-key 'normal
            haskell-mode-map (kbd "?") 'hoogle))

(use-package rainbow-mode
  :ensure t
  :diminish rainbow-mode
  :commands (rainbow-mode)
  :init (progn
          (add-hook 'css-mode-hook 'rainbow-mode)
          (add-hook 'emacs-lisp-mode-hook 'rainbow-mode)))

(use-package rainbow-delimiters
  :ensure t
  :commands rainbow-delimiters-mode
  :init (progn
         (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode)))

(use-package ledger-mode
  :ensure t
  :commands ledger-mode
  :init (progn
          (add-to-list 'auto-mode-alist '("\\.ledger\\'" . ledger-mode))
          (use-package flycheck-ledger
            :ensure t))
  :config (progn
            (evil-define-key 'normal ledger-mode-map
              (kbd "Y") 'ledger-copy-transaction-at-point
              (kbd "C") 'ledger-post-edit-amount
              (kbd "!") 'ledger-post-align-postings)

            (evil-leader/set-key-for-mode 'ledger-mode
              "n" 'ledger-add-transaction
              "r" 'ledger-reconcile
              "d" 'ledger-delete-current-transaction
              "?" 'ledger-display-balance-at-point)))


;; PROGRAMS
;; ================================================================================

(use-package org-mode
  :init (progn
          (use-package evil-org :ensure t)

          (setq org-directory "~/.org/")
          (setq orglog-done 'time)
          (setq org-hide-leading-stars nil)
          (setq org-alphabetical-lists t)
          (setq org-src-fontify-natively t)  ;; you want this to activate coloring in blocks
          (setq org-src-tab-acts-natively t) ;; you want this to have completion in blocks
          (setq org-hide-emphasis-markers t) ;; to hide the *,=, or / markers
          (setq org-pretty-entities t)       ;; to have \alpha, \to and others display as utf8 http://orgmode.org/manual/Special-symbols.html
          (setq org-agenda-files (list "~/.org/home.org" "~/.org/work.org" "~/.org/notes.org"))
          (setq org-default-notes-file (concat org-directory "/notes.org"))
          (setq org-enforce-todo-checkbox-dependencies t)
          (setq org-enforce-todo-dependencies t)
          (setq org-todo-keywords '((sequence "TODO" "DOING" "|" "DONE" "CANCELED" "DELEGATED")))
          (setq org-agenda-files (quote ("~/.org/home.org" "~/.org/work.org" "~/.org/notes.org")))
          (setq org-todo-keyword-faces
            '(("TODO" . org-warning)
               ("DOING" . "white")
               ("DONE" . "green")
               ("DELEGATED" . "purple")
               ("CANCELED" . "red")))

          (add-hook 'org-mode-hook 'org-indent-mode)
          (add-hook 'org-agenda-mode-hook
            (lambda ()
              (local-unset-key (kbd ",")) ;; Don't shadow the <leader>
              ;; Autosave:
              (add-hook 'auto-save-hook 'org-save-all-org-buffers nil t)
              (auto-save-mode))))
  :config (progn
            (evil-leader/set-key "o b"
              (lambda ()
                (interactive)
                (let ((persp (gethash "org" perspectives-hash)))
                  (when (null persp) ; When perspective doesn't exist
                    (persp-switch "org")
                    (when (file-exists-p "~/.org/home.org")
                      (find-file "~/.org/home.org"))
                    (when (file-exists-p "~/.org/work.org")
                      (split-window-right)
                      (find-file "~/.org/work.org")) ; Or when it already exists
                    (persp-activate persp)))))

            (evil-leader/set-key
              "o c" 'org-capture
              "o a" 'org-agenda-list
              "o t" 'org-todo-list)

            (evil-leader/set-key-for-mode 'org-mode
              "d" 'org-deadline
              "s" 'org-schedule
              "c" 'org-toggle-checkbox
              "o" (lambda ()
                    (interactive)
                    (evil-org-eol-call (quote org-insert-heading-respect-content))))

            (evil-define-key 'normal org-mode-map
              (kbd "m") 'org-set-tags
              (kbd "+") 'org-priority-up
              (kbd "-") 'org-priority-down)

            (evil-define-key 'emacs org-agenda-mode-map
              (kbd "d") 'org-agenda-deadline
              (kbd "s") 'org-agenda-schedule
              (kbd "+") 'org-priority-up
              (kbd "-") 'org-priority-down
              (kbd "q") 'org-agenda-quit
              (kbd "w") 'org-save-all-org-buffers)

            (evil-leader/set-key-for-mode 'org-agenda-mode-map
              (kbd "w") 'org-save-all-org-buffers)

            (if (file-exists-p (expand-file-name "README.org"))
              (add-to-list 'org-agenda-files (expand-file-name "README.org")))

            (if (file-exists-p (expand-file-name "project.org"))
              (add-to-list 'org-agenda-files (expand-file-name "project.org")))))

(use-package sx
  :ensure t
  :commands (sx-tab-newest sx-search sx-authenticate sx-ask
              sx-inbox sx-tab-month sx-tab-starred sx-tab-featured
              sx-tab-topvoted sx-tab-frontpage sx-tab-unanswered
              sx-tab-unanswered-my-tags))

;; Bootloader
;; ================================================================================
(when (eq system-type 'darwin)
  (setq interprogram-cut-function
    (lambda (text &optional push)
      (let ((process-connection-type nil))
        (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
          (process-send-string proc text)
          (process-send-eof proc)))))
  (defun pbpaste ()
    "Call pbpaste and insert the results"
    (interactive)
    (insert (shell-command-to-string "pbpaste"))))

(setq debug-on-error nil)
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq current-language-environment "UTF-8")
(setenv "LC_CTYPE" "UTF-8")
(setq inhibit-startup-screen t)
(setq-default tab-width 2 indent-tabs-mode nil) ;; Spaces
(setq standard-indent 2)
(setq make-backup-files nil)
(setq backup-inhibited t)
(setq auto-save-default nil)
(setq scroll-margin 5 scroll-conservatively 9999 scroll-step 1) ;; Smooth scrolling
(setq gc-cons-threshold 20000000) ;; Increase garbage collection limit
(setq visible-bell 1)
(setq ring-bell-function 'ignore)
(setq blink-matching-paren nil)
(setq initial-scratch-message ";; Hello.")
(fset 'yes-or-no-p 'y-or-n-p)
(setq large-file-warning-threshold 100000000)

(load-theme 'hc-zenburn t)
(sml/setup)
(sml/apply-theme 'respectful)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(menu-bar-mode -1) ;; Disable menu bar
(auto-save-mode nil) ;; Disable autosaving
(show-paren-mode t) ;; Show matching parens
(global-auto-revert-mode 1)
(column-number-mode 1)
(global-undo-tree-mode 1)
(global-linum-mode)
(linum-relative-on)
(popwin-mode 1)
(smartparens-global-mode t)
(show-smartparens-global-mode t)
(editorconfig-mode 1)
(projectile-global-mode +1)
(persp-mode)
(global-git-gutter-mode +1)
(global-flycheck-mode)
(global-company-mode)
(yas-global-mode 1)
(helm-mode 1)
(evil-mode 1)

;; Load any local configuration if it exists
(and
  (file-exists-p (expand-file-name ".emacs.el"))
  (load (expand-file-name ".emacs.el")))

(provide 'init)
;;; init.el ends here
