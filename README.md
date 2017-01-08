# moodle-destroyer.el

Emacs plugin for [moodle-destroyer-tools](https://github.com/manly-man/moodle-destroyer-tools).

Converts a gradingfile.json into emacs [org-mode](http://orgmode.org) and back to json.

``` json
{"assignment_id": 1337, "grades": [
  {"name": "Gruppe A", "id": 42, "grade": 100.0, "feedback":"Great job!" },
  {"name": "Gruppe B", "id": 21, "grade": 0.0, "feedback":"" }
]}
```

``` org-mode
# -*- mode: org; -*-
#+STARTUP: showeverything

#+ASSIGNMENT_ID: 1337

* Gruppe C
:PROPERTIES:
:name: Gruppe A
:id: 42
:grade: 100.0
:END:

#+BEGIN_FEEDBACK
Great job!
#+END_FEEDBACK

* Gruppe S
:PROPERTIES:
:name: Gruppe B
:id: 21
:grade: 0.0
:END:

#+BEGIN_FEEDBACK
#+END_FEEDBACK
```

## Installation

Clone the repository and add the following to your init.el

``` elisp
(use-package moodle-destroyer
  :load-path "path/to/moodle-destroyer.el"
  :commands (moodle-destroyer-json-to-org
             moodle-destroyer-org-to-json))
```

## Usage

 - moodle-destroyer-json-to-org
 
 Interactive function to import a json-file.

 - moodle-destroyer-org-to-json
 
 Interactive function to export the org-mode file to a new json file

## Working with git-flow

This project uses git-flow as branching-model. Please make sure to always work on feature branches.
We recommend [`git-flow AVH Edition`](https://github.com/petervanderdoes/gitflow/).
For detailed installation instructions have a look at [https://github.com/petervanderdoes/gitflow/wiki](https://github.com/petervanderdoes/gitflow/wiki).

To setup the project follow these steps:

1. Clone the repository.

2. `cd` into the repository directory.

3. Run `git-flow init` accepting all default values.

If you like to add a new feature:

1. Start a new feature with `git-flow feature start <feature-name>`. This will create a new feature branch.

2. Hack your feature.

3. Finish your feature with `git-flow feature finish <feature-name>`. This will merge the branch into the develop branch.
