;;; My init.el file.
;;; Used as a loader for all org file containing all my actual customizations: settings.org

;;; Increases GC threshold to help improve speeds
;; (set gc-cons-threshold 100000000)    


(require 'org)
(org-babel-load-file
 (expand-file-name "settings.org"
                   user-emacs-directory))
