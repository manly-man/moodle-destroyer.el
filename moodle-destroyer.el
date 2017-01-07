;;; moodle-destroyer.el --- Convert a gradingfile.json into an org-mode file

;; Copyright (C) 2017 manly-man

;; Author: Christian van Onzenoodt <onze@onze.io>
;; Maintainer: Christian van Onzenoodt <onze@onze.io>
;; URL: https://github.com/manly-man/moodle-destroyer.el
;; Version: 0.0.1
;; Keywords: emacs orgmode org export
;; Package-Requires: ((emacs "24") (json "1.4"))

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

;;; Code:

(require 'json)

(defconst moodle-destroyer-header-template "* Assignment
:PROPERTIES:
:%s: %s
:END\n\n")

(defconst moodle-destroyer-grade-template "** %s
:PROPERTIES:
:%s: %s
:%s: %s
:%s: %s
:END\n
%s\n\n")

(defun moodle-destroyer-org-parse-grade (grade)
  "Parse the given GRADE."
  (princ (format moodle-destroyer-grade-template
                 (cdr (assoc 'name grade))
                 (car (assoc 'name grade)) (cdr (assoc 'name grade))
                 (car (assoc 'id grade)) (cdr (assoc 'id grade))
                 (car (assoc 'grade grade)) (cdr (assoc 'grade grade))
                 (cdr (assoc 'feedback grade)))))


(defun moodle-destroyer-org-from-file (file)
  "Convert the given FILE to 'org-mode'."
  (get-buffer-create "grading.org")
  (with-current-buffer "grading.org"
    ;; Insert assignment_id to output-file
    (insert
     (princ (format moodle-destroyer-header-template
                    (car (assoc 'assignment_id (json-read-file file)))
                    (cdr (assoc 'assignment_id (json-read-file file))))))
    ;; Map grades
    (mapc
     (lambda (grade)
       (insert (moodle-destroyer-org-parse-grade grade)))
     (cdr (assoc 'grades
                 (json-read-file file)))))
  (switch-to-buffer "grading.org")
  (org-mode))


(defun moodle-destroyer-json-to-org (file-path)
  "Generate an 'org-mode' file from a file at the given FILE-PATH."
  (interactive "FPlease enter path to moodle-destroyer gradingfile.json: ")
  (moodle-destroyer-org-from-file file-path))

(provide 'moodle-destroyer)

;;; moodle-destroyer.el ends here
