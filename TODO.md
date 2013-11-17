# asap

* MAJOR GOAL: fully implement functionality of the [psalmpreprocessor](https://github.com/igneus/In-adiutorium/blob/master/nastroje/psalmpreprocessor.rb)
  important missing features:
  - append Gloria Patri
  - skip title
  - skip n verses at the beginning

* handle strophes

* specify dependencies (normal usage / dev) in the gemspec; verify in a clean gemset

* LatexOutputter: inefficient - creates short-term objects with the same configuration again and again

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
