(require 'mozc)
;; or (load-file "/path/to/mozc.el")
(set-language-environment "Japanese")
(setq default-input-method "japanese-mozc")
;;(setq mozc-candidate-style 'overlay)
(setq mozc-candidate-style 'echo-area)
(setq mozc-color "blue")
(defun mozc-change-cursor-color ()
  (if mozc-mode
	  (set-buffer-local-cursor-color mozc-color)
	(set-buffer-local-cursor-color nil)))
(add-hook 'input-method-activate-hook
		  (lambda () (mozc-change-cursor-color)))


(global-set-key
 [henkan]
 (lambda () (interactive)
   (when (null current-input-method) (toggle-input-method))))
(global-set-key
 [muhenkan]
 (lambda () (interactive)
   (inactivate-input-method)))
(defadvice mozc-handle-event (around intercept-keys (event))
  "Intercept keys muhenkan and zenkaku-hankaku, before passing keys to mozc-server (which the function mozc-handle-event does), to properly disable mozc-mode."
  (if (member event (list 'zenkaku-hankaku 'muhenkan))
	  (progn (mozc-clean-up-session)
			 (toggle-input-method))
	(progn ;(message "%s" event) ;debug
	  ad-do-it)))
(ad-activate 'mozc-handle-event)
