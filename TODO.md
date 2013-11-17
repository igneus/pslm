# asap

* MAJOR GOAL: fully implement functionality of the [psalmpreprocessor](https://github.com/igneus/In-adiutorium/blob/master/nastroje/psalmpreprocessor.rb)
* handle strophes

* specify dependencies (normal usage / dev) in the gemspec; verify in a clean gemset

## output

## input
* psalm files with optional YAML front-matter instead of the title line (provide for more metadata)

* provide a library of psalm and canticle texts? as a part of the gem? standalone?



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
