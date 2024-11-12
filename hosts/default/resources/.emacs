;; makes C-n create new lines if EOF
(setq next-line-add-newlines t)
;; Enables line number
(global-display-line-numbers-mode)
;; Sets the relatives modes
(setq display-line-numbers-type 'relative)
;; disable tabs
(setq-default indent-tabs-mode nil)

;; my keybindings
(global-set-key [?\e C-f] 'forward-sexp)
(global-set-key [?\e C-b] 'backward-sexp)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(clipetty fzf obsidian ## gnu-elpa-keyring-update)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
