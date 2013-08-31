;;--------------------------------------
;; emacs.el: main configuration .......
;;                __,.__
;;               /  ||  \
;;        ::::::| .-'`-. |::::::
;;        :::::/.'  ||  `,\:::::
;;        ::::/ |`--'`--'| \::::
;;        :::/   \`/++\'/   \:::
;;--------------------------------------

;; EVIL --------------------------------
;;
(add-to-list 'load-path "~/.emacs.d/bundle/evil")
(require 'evil)
(setq evil-default-cursor (quote (t "Grey")))
(define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)

(evil-mode 1)

;; UI ----------------------------------
;;
(setq inhibit-startup-message t)
(setq confirm-kill-emacs nil)
(fset 'yes-or-no-p 'y-or-n-p)
(tool-bar-mode -1)
(menu-bar-mode -1)
(show-paren-mode t)

;; disable backup and auto-save
(setq backup-inhibited t)
(setq auto-save-default nil)

;; Themes ------------------------------
;;
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'desert t)
(set-default-font "Terminus-12")

;; Isabelle/PG -------------------------
;;
;; Source: http://git.necoro.eu/dotfiles.git/tree/.emacs

;; work around bugs in Isabelle/PG
;; we need to toggle options twice to make them work
(defun isabelle-repair (what part)
  (let*
    ((msg (format "Repairing %s" (capitalize what)))
     ; create the variable from `what` and `part`
     ; replace spaces by "-" in `what`
     (var (format "isar-%s:%s" part
                  (mapconcat 'identity (split-string (downcase what)) "-")))
     (vart (concat var "-toggle"))
     (repair `(lambda ()
                ; intern-soft also handles the case, that `var` is not existing
                ; (it returns nil then -- making `when` skip)
                (when (intern-soft ,var)
                  (message ,msg)
                  (funcall (intern ,vart) 0) ; toggle off
                  (funcall (intern ,vart) 1) ; toggle on
                ))))
    
    (add-hook 'proof-shell-init-hook repair)))

(isabelle-repair "auto solve direct" "tracing")
(isabelle-repair "auto quickcheck" "tracing")
(isabelle-repair "quick and dirty" "proof")

;; toggle three window mode
(defun toggle-three-panes ()
  (interactive)
  (proof-multiple-frames-toggle)
  (proof-three-window-toggle))

(defun isar-mode-keys ()
  (message "Loading isar keys")
  (local-set-key (kbd "C-c 3") 'toggle-three-panes)
  )

(add-hook 'isar-mode-hook 'isar-mode-keys)

;; Misc custom settings ----------------
;;
(custom-set-variables
  '(indent-tabs-mode nil)
  '(isar-display:show-main-goal t)
  '(isar-maths-menu-enable t)
  '(isar-proof:Sledgehammer:\ Time\ Limit 60)
  '(isar-tracing:auto-quickcheck t)
  '(isar-tracing:auto-try nil)
  '(isar-unicode-tokens-enable t)
  '(isar-unicode-tokens2-enable t)
  '(isar-use-find-theorems-form nil)
  '(isar-x-symbol-enable nil)
  '(proof-delete-empty-windows nil)
  '(proof-three-window-enable t)
  '(proof-imenu-enable t) ; without this somehow the options above don't seem to take effect
  )

(custom-set-faces
  '(isabelle-free-name-face ((((type x) (class color) (background dark)) (:foreground "lightblue"))))
  '(isabelle-quote-face ((t (:foreground "grey"))))
  '(isabelle-string-face ((((type x) (class color) (background dark)) (:foreground "cyan3"))))
  '(isabelle-var-name-face ((((type x) (class color) (background dark)) (:foreground "lightblue3"))))
  '(linum ((t (:inherit (shadow default) :foreground "gold"))))
  '(proof-boring-face ((((type x) (class color) (background dark)) (:foreground "cyan3"))))
  '(proof-highlight-dependency-face ((((type x) (class color) (background dark)) (:background "peru" :foreground "black"))))
  '(proof-highlight-dependent-face ((((type x) (class color) (background dark)) (:background "darkorange" :foreground "black"))))
  '(proof-region-mouse-highlight-face ((((type x) (class color) (background dark)) (:background "yellow3" :foreground "black"))))
  '(proof-warning-face ((((type x) (class color) (background dark)) (:background "orange2" :foreground "black"))))
  '(unicode-tokens-symbol-font-face ((t (:slant normal :weight normal :height 113 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
  )

