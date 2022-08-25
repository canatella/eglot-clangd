;;; eglot-clangd.el --- clangd LSP extensions support -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Damien Merenne <dam@cosinux.org>

;; This program is free software: you can redistribute it and/or modify
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

;; Clangd supports some extensions to the LSP protocol

;;; Code:

(require 'eglot)

;;;###autoload
(defun eglot-clangd-switch-source-header ()
  "Try to toggle between source file and header file."
  (interactive)
  (let ((buf (current-buffer)))
    (jsonrpc-async-request (eglot--current-server-or-lose)
                           :textDocument/switchSourceHeader (eglot--TextDocumentIdentifier)
                           :success-fn (lambda (file-uri)
                                         (unless (string-blank-p file-uri)
                                           (find-file (eglot--uri-to-path file-uri)))))))

(defun eglot-clangd-completion-candidate-score (candidate)
  "Returns the score for a comnpletion candidate."
  (let ((lsp-item (get-text-property 0 'eglot--lsp-item candidate)))
    (if lsp-item (plist-get lsp-item
                            :score) 0)))

(defun eglot-clangd-sort-completion (candidates)
  "Sort completions CANDIDATES."
  (if (eglot-current-server)
      (seq-sort (lambda (a b)
                  (> (eglot-clangd-completion-candidate-score a)
                     (eglot-clangd-completion-candidate-score b))) candidates) candidates))

(with-eval-after-load 'company (add-hook 'company-transformers 'eglot-clangd-sort-completion))

(provide 'eglot-clangd)

;;; eglot-clangd.el ends here
