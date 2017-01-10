;;; moodle-destroyer-convert.el --- Convert a gradingfile.json into an org-mode file

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

;;; This library provides methods to convert a gradingfile.json to org-mode
;;; and back

;;; Code:

(require 'cl-lib)
(require 'json)
(require 'org-element)

;; Default name for the 'org-mode' gradingfile
(defconst moodle-destroyer-gradingfile-org-name "gradingfile.mdt.org")

;; Default name for the generated json grading file
(defconst moodle-destroyer-gradingfile-json-name "gradingfile-org-export.json")

;; Header-template
(defconst moodle-destroyer-header-template "# -*- mode: org; -*-
#+STARTUP: showeverything
# Local Variables:
# eval: (moodle-destroyer-mode)
# End:

#+ASSIGNMENT_ID: %s

#+BEGIN_NOTE

#+END_NOTE\n\n")

;; Template for a grade-section
(defconst moodle-destroyer-grade-template "* %s
  :PROPERTIES:
  :%s: %s
  :%s: %s
  :%s: %s
  :END:\n
  #+BEGIN_FEEDBACK
  %s
  #+END_FEEDBACK\n\n")


(defun moodle-destroyer-trim (str)
  "Remove whitespace at the begin, the end, and newlines at the end of the given STR."
  (replace-regexp-in-string
   "\n$" ""
   (replace-regexp-in-string
    " +$"  ""
    (replace-regexp-in-string
     "^ +"  "" str))))


(defun moodle-destroyer-property-list ()
  "Parse the buffer and return a cons list of (property . value)
from lines like:
#+PROPERTY: value"
  (org-element-map (org-element-parse-buffer 'element) 'keyword
    (lambda (keyword) (cons (org-element-property :key keyword)
                            (org-element-property :value keyword)))))


(defun moodle-destroyer-property-value (KEYWORD)
  "Get the value of a KEYWORD in the form of #+KEYWORD: value."
  (cdr (assoc KEYWORD (moodle-destroyer-property-list))))


(defun moodle-destroyer-org-parse-grade (grade)
  "Parse the given GRADE."
  (format moodle-destroyer-grade-template
          (cdr (assoc 'name grade))
          (car (assoc 'name grade)) (cdr (assoc 'name grade))
          (car (assoc 'id grade)) (cdr (assoc 'id grade))
          (car (assoc 'grade grade)) (cdr (assoc 'grade grade))
          (cdr (assoc 'feedback grade))))


(defun moodle-destroyer-parse-org-document-properties ()
  "Parse the document properties."
  (moodle-destroyer-property-value "ASSIGNMENT_ID"))


(defun moodle-destroyer-parse-org-grade-properties ()
  "Parse the grade properties."
  (org-element-map (org-element-parse-buffer) 'headline
    (lambda (hl)
      (cl-mapcar
       #'cons
       '(:name :id :grade)
       (list
        (org-element-property :NAME hl)
        (string-to-number (org-element-property :ID hl))
        (string-to-number (org-element-property :GRADE hl)))))))


(defun moodle-destroyer-parse-org-feedback ()
  "Parse feedback sections from document."
  (org-element-map (org-element-parse-buffer) 'special-block
    (lambda (sb)
      (cl-mapcar
       #'cons
       '(:feedback)
       ;; remove all nil elements from the list
       (delq nil
             (list
              ;; if the type of the special block is not FEEDBACK, return nil
              (if (string= (org-element-property :type sb) "FEEDBACK")
                  (moodle-destroyer-trim
                   ;; Read feedback content from BEGIN_FEEDBACK section
                   (buffer-substring-no-properties
                    (org-element-property :contents-begin sb)
                    (org-element-property :contents-end sb))))))))))


(defun moodle-destroyer-json-from-buffer ()
  "Convert the current buffer from 'org-mode' to json."

  (cl-mapcar
   #'cons
   '(:assignment_id :grades)
   (list
    ;; assignment_id
    (moodle-destroyer-parse-org-document-properties)
    ;; grades
    (cl-mapcar
     ;; Do a lambda here, because there is a list of lists
     '(lambda (a b) (append a b))
     (moodle-destroyer-parse-org-grade-properties)
     (moodle-destroyer-parse-org-feedback)))))


(defun moodle-destroyer-org-from-file (file)
  "Convert the given FILE to 'org-mode'."
  (get-buffer-create moodle-destroyer-gradingfile-org-name)
  (with-current-buffer moodle-destroyer-gradingfile-org-name
    ;; Insert assignment_id to output-file
    (insert
     (format moodle-destroyer-header-template
             (cdr (assoc 'assignment_id (json-read-file file)))))
    ;; Map grades
    (mapc
     (lambda (grade)
       (insert (moodle-destroyer-org-parse-grade grade)))
     (cdr (assoc 'grades
                 (json-read-file file)))))
  (switch-to-buffer moodle-destroyer-gradingfile-org-name)
  (org-mode))


(defun moodle-destroyer-json-to-file (json file)
  "Writes the generated JSON into a FILE."
  (get-buffer-create file)
  (switch-to-buffer file)
  (insert (format "%s" json)))


(provide 'moodle-destroyer-convert)

;;; moodle-destroyer-convert.el ends here
