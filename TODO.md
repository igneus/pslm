# asap

* MAJOR GOAL: fully implement functionality of the [psalmpreprocessor](https://github.com/igneus/In-adiutorium/blob/master/nastroje/psalmpreprocessor.rb)

* handle strophes

* specify dependencies (normal usage / dev) in the gemspec; verify in a clean gemset

* the CLI
  - must do something useful even without any options (just point 2,2 accents?)
  - must provide shortcut options for a few most common setups
  - should detect presence/absence of a psalm title correctly and just warn if the options don't correspond
  	(but there must be an option to suppress this "clever" behaviour)
  - it should be possible to specify the pattern either numerically (x accents, y preparatories) or by a psalm tone code (I.g) +
  	optionally reference book (like --standard solesmes1933 --tone I.g3)

## output

## input
* psalm files with optional YAML front-matter instead of the title line (provide for more metadata)

* provide a library of psalm and canticle texts? as a part of the gem? standalone?
* similar library with psalm tones?



# later

## input
* for Latin: automatic hyphenation
* for Latin: automatic accent determination
* loading of the ["single-line verse" format adopted by jgabc](https://github.com/bbloomf/jgabc/tree/master/psalms)
* syntax for verse numbers

## output
* notated (single line of notes, text aligned beneath) - LilyPond
* html
* latex: easy (no command definitions necessary) and semantic (\accent instead of \underline etc.) mode
* notated first line - gregorio
