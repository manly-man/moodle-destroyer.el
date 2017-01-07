# moodle-destroyer.el

Emacs plugin for [moodle-destroyer-tools](https://github.com/manly-man/moodle-destroyer-tools).

Converts an gradingfile.json into emacs [org-mode](http://orgmode.org) and back to json.

```json
{"assignment_id": 1337, "grades": [
  {"name": "Gruppe A", "id": 42, "grade": 100.0, "feedback":"Great job!" },
  {"name": "Gruppe B", "id": 21, "grade": 0.0, "feedback":"" }
]}
```

```org-mode
* Assignment: 1337

** Gruppe C
:PROPERTIES:
:name: Gruppe A
:id: 42
:grade: 100.0
:END 

Great job!
 
** Gruppe S
:PROPERTIES:
:name: Gruppe B
:id: 21
:grade: 0.0
:END 
```
