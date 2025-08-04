;;; modern-icons-lsp.el --- Modern icons for lsp-mode -*- lexical-binding: t -*-

;; Copyright (C) 2025 Quang Trung Ta

;; Author: Quang Trung Ta <taquangtrungvn@gmail.com>
;; Version: 0.1.0
;; Created: June 14, 2025
;; Homepage: https://github.com/emacs-modern-icons/modern-icons-lsp.el
;; Package-Requires: ((emacs "28.1") (modern-icons "0.1") (lsp-mode "6.0"))
;; Keywords: lisp, icons, lsp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; To use this package, simply install and add this to your init.el
;;
;;   (require 'modern-icons-lsp)
;;   (modern-icons-lsp-enable)

;;; Code:

(require 'lsp-icons)
(require 'lsp-ui)
(require 'modern-icons)

(defun modern-icons-lsp-kind-name (kind-index)
  "Get lsp-item-kind name of an LSP KIND-INDEX."
  (cl-case kind-index
    (1 "document")
    (2  "namespace")
    (3  "namespace")
    (4  "namespace")
    (5  "class")
    (6  "method")
    (7  "property")
    (8  "field")
    (9  "method")
    (10 "enum")
    (11 "interface")
    (12 "method" )
    (13 "variable")
    (14 "constant")
    (15 "string")
    (16 "numeric")
    (17 "boolean")
    (18 "boolean")
    (19 "namespace")
    (20 "indexer")
    (21 "boolean")
    (22 "enum member")
    (23 "struct")
    (24 "event")
    (25 "operator")
    (26 "template")
    (t "misc")))

(defun modern-icons-lsp-file-icon-advisor (_func file-ext &optional feature &rest _args)
  "Advice function for LSP to display file icons.
FUNC is the `lsp-icons-get-by-file-ext' function."
  (when-let* ((_ file-ext)
              (_ (lsp-icons--enabled-for-feature feature))
              (icon (modern-icons-icon-for-file (concat "1." file-ext))))
    (propertize " " 'display icon)))

(defun modern-icons-lsp-symbol-icon-advisor (_func kind &optional feature &rest _args)
  "Advice function for LSP to display symbol icons.
FUNC is the `lsp-icons-get-by-symbol-kind' function."
  (when-let* ((_ kind)
              (_ (lsp-icons--enabled-for-feature feature))
              (item-kind (modern-icons-lsp-kind-name kind))
              (icon (modern-icons-icon-for-code-item item-kind)))
    (propertize " " 'display icon)))

(defun modern-icon-lsp-code-action-advisor (_func actions &rest args)
  "Advice function for LSP to display code action icons.
FUNC is the `lsp--select-action' function."
  (cond
   ((seq-empty-p actions) (signal 'lsp-no-code-actions nil))
   ((and (eq (seq-length actions) 1) lsp-auto-execute-action)
    (lsp-seq-first actions))
   (t (let ((completion-ignore-case t))
        (lsp--completing-read "Select code action: "
                              (seq-into actions 'list)
                              (lambda (action)
                                (let* ((kind (or (gethash "kind" action) ""))
                                       (kind (if (string= (string-trim kind) "") "other"
                                               kind))
                                       (icon (modern-icons-icon-for-code-action kind))
                                       (icon-str (propertize " " 'display icon)))
                                  (concat icon-str
                                          (propertize " " 'display '(space :width 0.5))
                                          (lsp:code-action-title action))))
                              nil t)))))

(defun modern-icon-lsp-ui-sideline-code-action-advisor (_func action &rest args)
  "Advice function for LSP UI sideline to display code action icons.
FUNC is the `lsp-ui-sideline--code-actions-image' function."
  (let* ((kind (or (gethash "kind" action) ""))
         (kind (if (string= (string-trim kind) "") "other" kind))
         (icon (modern-icons-icon-for-code-action kind))
         (icon-str (propertize " " 'display icon)))
    (concat icon-str
            (propertize " " 'display '(space :width 0.5)))))

;;;###autoload
(defun modern-icons-lsp-enable ()
  "Enable `modern-icons-lsp'."
  (interactive)
  (advice-add 'lsp-icons-get-by-file-ext :around #'modern-icons-lsp-file-icon-advisor)
  (advice-add 'lsp-icons-get-by-symbol-kind :around #'modern-icons-lsp-symbol-icon-advisor)
  (advice-add 'lsp--select-action :around #'modern-icon-lsp-code-action-advisor)
  (advice-add 'lsp-ui-sideline--code-actions-image
              :around #'modern-icon-lsp-ui-sideline-code-action-advisor)
  (when (called-interactively-p 'any)
    (message "Modern-icons-lsp is enabled!")))

;;;###autoload
(defun modern-icons-lsp-disable ()
  "Disable `modern-icons-lsp'."
  (interactive)
  (advice-remove 'lsp-icons-get-by-file-ext #'modern-icons-lsp-file-icon-advisor)
  (advice-remove 'lsp-icons-get-by-symbol-kind #'modern-icons-lsp-symbol-icon-advisor)
  (advice-remove 'lsp--select-action #'modern-icon-lsp-code-action-advisor)
  (advice-remove 'lsp-ui-sideline--code-actions-image
                 #'modern-icon-lsp-ui-sideline-code-action-advisor)
  (when (called-interactively-p 'any)
    (message "Modern-icons-lsp is disabled!")))

(provide 'modern-icons-lsp)
;;; modern-icons-lsp.el ends here
