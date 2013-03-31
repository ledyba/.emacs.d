;; emacs directory
(when load-file-name
(setq user-emacs-directory (file-name-directory load-file-name)))

(set-language-environment  'utf-8)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8)

(kill-buffer "*scratch*")
(add-to-list 'load-path "~/.emacs.d")

;; package management
(require 'package)
(add-to-list 'package-archives
		 '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
		 '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

(defun package-install-with-refresh (package)
(unless (assq package package-alist)
(package-refresh-contents))
(unless (package-installed-p package)
(package-install package)))

;; install evil

(when
(eq system-type 'gnu/linux)
(load "~/.emacs.d/mozc.el"))

(when
(eq system-type 'windows-nt)
(set-face-font 'default "Consolas-13")
(set-default-font "Consolas-13"))

;;auto complete
(require 'auto-complete)
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d//ac-dict")
(ac-config-default)
(global-auto-complete-mode t)
(global-set-key (kbd "C-SPC") 'auto-complete)


;; globalな設定
(require 'linum)
(global-linum-mode)

;;
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq inhibit-startup-message t)
(setq line-number-mode t)

;; タブサイズ
(setq-default indent-tabs-mode t)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)
(add-hook 'c-mode-common-hook '(lambda () (local-set-key (kbd "RET") 'newline-and-indent)))
(global-set-key [backspace] 'backward-delete-char) ;;こうしないとタブが消えない！
(add-hook 'c-mode-hook
	  (lambda () (c-set-style "stroustrup")))
(setq-default c-basic-offset 4     ;;基本インデント量4
		  tab-width 4          ;;タブ幅4
		  indent-tabs-mode t)  ;;インデントをタブでするかスペースでするか
(setq-default c-tab-always-indent nil) ;;tabを押したらタブを入力。

(if window-system (set-frame-size (selected-frame) 120 36))

;;クリップボード
(setq x-select-enable-clipboard t)
(global-set-key (kbd "\C-c") 'clipboard-kill-ring-save)
(global-set-key (kbd "\C-v") 'clipboard-yank)

;; ;;セーブ
(global-set-key (kbd "\C-s") 'save-buffer)

;; tab
(load "~/.emacs.d/tab.el")

;; color
(load-theme 'tango-dark t)

;; ;; 括弧の対応をハイライト
(show-paren-mode t)
(setq indicate-buffer-boundaries 'left) ;;終端を明示
(setq require-final-newline t) ;;最後で必ず改行

;; white space
(require 'whitespace)
(setq whitespace-style
  '(face
	tabs
	spaces
	;trailing
	lines
	space-before-tab
	;newline
	indentation::tab
	;empty
	space-after-tab
	tab-mark
	newline-mark))
(setq-default whitespace-line-column 120)
(global-whitespace-mode 1)

;; arduino
(add-to-list 'load-path "~/.emacs.d/vendor/arduino")
(add-to-list 'auto-mode-alist '("\\.\\(pde\\|ino\\)$" . arduino-mode))
(autoload 'arduino-mode "arduino-mode" "Arduino editing mode." t)
(add-to-list 'ac-modes 'arduino-mode)
(add-hook 'arduino-mode-hook '(lambda () (auto-complete-mode t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; evil
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; escをすぐに反映
(setq evil-esc-delay 0)
;; enable evil
(require 'evil)
(evil-mode 1)

;; gj, gk
(defun evil-swap-key (map key1 key2)
;; MAP中のKEY1とKEY2を入れ替え
"Swap KEY1 and KEY2 in MAP."
(let ((def1 (lookup-key map key1))
	(def2 (lookup-key map key2)))
(define-key map key1 def2)
(define-key map key2 def1)))
(evil-swap-key evil-motion-state-map "j" "gj")
(evil-swap-key evil-motion-state-map "k" "gk")
(defun evil-mark-on-lines (beg end lines)
(let ((beg-marker (save-excursion (goto-char beg) (point-marker)))
	(end-marker (save-excursion (goto-char end) (point-marker))))
(set-marker-insertion-type end-marker t)
(setcdr lines (cons (cons beg-marker end-marker) (cdr lines)))))

(defun evil-apply-on-block-markers (func beg end &rest args)
"Like `evil-apply-on-block' but first mark all lines and then
call functions on the marked ranges."
(let ((lines (list nil)))
(evil-apply-on-block #'evil-mark-on-lines beg end lines)
(dolist (range (nreverse (cdr lines)))
  (let ((beg (car range)) (end (cdr range)))
	(apply func beg end args)
	(set-marker beg nil)
	(set-marker end nil)))))

(evil-define-operator evil-comment-or-uncomment-region (beg end type)
"Comment out text from BEG to END with TYPE."
(interactive "<R>")
  (if (eq type 'block)
	  (evil-apply-on-block-markers #'comment-or-uncomment-region beg end)
	(comment-or-uncomment-region beg end)))

(define-key evil-visual-state-map "/" 'evil-comment-or-uncomment-region)
(define-key evil-visual-state-map "f" 'indent-region)

(define-key evil-insert-state-map  (kbd "C-z") 'undo)
(define-key evil-normal-state-map  (kbd "C-z") 'undo)
(define-key evil-replace-state-map (kbd "C-z") 'undo)
(define-key evil-visual-state-map  (kbd "C-z") 'undo)
(define-key evil-motion-state-map  (kbd "C-z") 'undo)

(define-key evil-insert-state-map  (kbd "C-S-z") 'redo)
(define-key evil-normal-state-map  (kbd "C-S-z") 'redo)
(define-key evil-replace-state-map (kbd "C-S-z") 'redo)
(define-key evil-visual-state-map  (kbd "C-S-z") 'redo)
(define-key evil-motion-state-map  (kbd "C-S-z") 'redo)
(define-key evil-insert-state-map  (kbd "C-y") 'redo)
(define-key evil-normal-state-map  (kbd "C-y") 'redo)
(define-key evil-replace-state-map (kbd "C-y") 'redo)
(define-key evil-visual-state-map  (kbd "C-y") 'redo)
(define-key evil-motion-state-map  (kbd "C-y") 'redo)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; マウスのホイールスクロールスピードを調節
;; (連続して回しているととんでもない早さになってしまう。特にLogicoolのマウス)
(setq scroll-step 1)
(setq scroll-conservatively 35)
(setq scroll-margin 0)
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-scroll-amount '(3 ((shift) . 10) ((control) . nil)))
(global-set-key (kbd "<C-up>") '(lambda () "" (interactive) (forward-line -3)))
(global-set-key (kbd "<C-down>") '(lambda () "" (interactive) (forward-line 3)))

(defun comment-or-uncomment-region-or-line ()
  "Comments or uncomments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
	(if (region-active-p)
		(setq beg (region-beginning) end (region-end))
		  (setq beg (line-beginning-position) end (line-end-position)))
	(comment-or-uncomment-region beg end)))

;;最近使ったファイル
(require 'recentf)
(recentf-mode 1)
