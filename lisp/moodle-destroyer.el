;;; moodle-destroyer.el --- Convert a gradingfile.json into an org-mode file

;; Copyright (C) 2017 manly-man

;; Author: Christian van Onzenoodt <onze@onze.io>
;; Maintainer: Christian van Onzenoodt <onze@onze.io>
;; URL: https://github.com/manly-man/moodle-destroyer.el
;; Version: 0.2.0
;; Keywords: emacs orgmode org export
;; Package-Requires: ((emacs "25") (cl-lib "2.1") (json "1.4") (org-element "*"))

;; This file is not part of GNU Emacs

;;; License:

;; MIT License
;;
;; Copyright (c) 2017 manly-man
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;;; News:

;;; 0.2.0 - Add note block for grading notes
;;; 0.1.1 - Fix printing of error code
;;; 0.1.0 - Converting gradingfile.json to org-mode and back to json

;;; Code:

(require 'moodle-destroyer-convert)

;; String for the mode line
(defconst moodle-destroyer-mode-lighter " MoodleDestroyer")


(defvar moodle-destroyer-mode-map
  (let ((map (make-sparse-keymap)))
    map))


(define-minor-mode moodle-destroyer-mode
  "Moodle-destroyer mode"
  :lighter moodle-destroyer-mode-lighter
  :keymap  moodle-destroyer-mode-map)


(defun moodle-destroyer-json-to-org (file-path)
  "Generate an 'org-mode' file from a file at the given FILE-PATH."
  (interactive "FPlease enter path to moodle-destroyer gradingfile.json: ")
  (moodle-destroyer-org-from-file file-path))


(defun moodle-destroyer-org-to-json ()
  "Generate a gradingfile.json from a 'org-mode' buffer."
  (interactive)
  (if (string= (buffer-local-value 'major-mode (current-buffer)) "org-mode")
      ;; if current-buffer is org-mode, read the buffer, convert to json and write to file
      (moodle-destroyer-json-to-file
       (json-encode (moodle-destroyer-json-from-buffer))
       moodle-destroyer-gradingfile-json-name)
    (print "The current buffer is NOT an org-mode buffer!")))


(provide 'moodle-destroyer)

;;; moodle-destroyer.el ends here
