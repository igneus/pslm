# pslm

Tool for automatic pointing of psalm texts for the traditional
formulae of Gregorian chant psalmody.

# Problem and its solutions

When preparing booklets for chanted Divine Office, you probably have
to - unless your schola is *extremely* skilled in Latin and psalmody -
deal with pointing of the psalm texts.

* You can do so manually, which is a boring, tedious, error-prone task.
* You can use Benjamin Bloomfields online [Psalm Tone Tool](https://bbloomf.github.io/jgabc/psalmtone.html), which will also generate notated first verse for you
* or you can use pslm

# installation

`gem install pslm`

# Basic usage

## Take prepared psalm texts

* [Latin texts prepared by me](https://github.com/igneus/Editio-Sti-Wolfgangi/tree/master/psalmi)
* [Latin texts further extended by Jakub Jelínek](https://github.com/jakubjelinek/Editio-Sti-Wolfgangi/tree/master/psalmi)
* [Czech texts](https://github.com/igneus/In-adiutorium/tree/master/antifonar/zalmy) (from *Denní modlitba církve*)

## Or prepare your own

**TODO**

## `pslm` executable and its invocation

* simplest -
  `pslm path/to/ps109.pslm`
  By default pslm formats the psalm for LaTeX and prints the output
  to standard output. You can redirect the output to a file using
  your shell's capabilities or by means of the `-o` option:
  `pslm -o ps109.tex path/to/ps109.pslm`

* LaTeX output -
  is default

* pointing for a given tone -
  `pslm -t VII.a path/to/ps109.pslm`
  Pslm knows a basic set of psalm tones (based on 196x books) by name.

* pointing for custom tone
  `pslm -a 2:2 -p 0:0 path/to/ps109.pslm`
  If your favourite tone isn't supported or you don't like the default
  psalm tone set, you can specify number of accentuated (`-a`)
  and preparatory (`-p`) syllables in each half-verse.

* pointing style
  `pslm -s underline path/to/ps109.pslm` to underline accentuated
  syllables,
  `pslm -s bold path/to/ps109.pslm` to make them bold

* print to console with highlighting
  `pslm -f console path/to/ps109.pslm`
  (for geeks who prefer to chant psalms from the terminal :) )

* print all available options
  `pslm -h`

# Use pslm when programming your own build tool

Especially if you use build scripts written in Ruby it may be
more convenient to gain better control over `pslm` by using
the underlying Ruby library directly instead of invoking
the executable.

**TODO** add examples

## History

I once wrote [psalmpreprocessor](https://github.com/igneus/In-adiutorium/commits/524658a5b40a9fc47d2d7fd21304d1a77118ae4b/nastroje/psalmpreprocessor.rb)
as a relatively simple ad-hoc sollution; then I extended it step by step.
It was ugly and dirty at the beginning and got only dirtier.
Then I restructured it, but it didn't get much cleaner. Then I needed it for another, quite different typesetting
project. ...

Years later I decided to make a standalone gem with the same (and some additional) functionality.
(Hey, there is a bug in psalmpreprocessor.rb. I want to fix it. In a few weeks I should deliver that book
for which the bug should be fixed. It means I don't want to break anything. It means I want to be secured by
automatic tests. But psalmpreprocessor isn't easily unit-testable. ...)
