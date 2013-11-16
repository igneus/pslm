# pslm

A Ruby gem providing a commandline tool 'pslm' for dealing with
"plain text psalm files" and an underlying library.

## Status

Under development, not useful at all.

## Who might be (later) interested

Catholic typesetters dealing with Divine Office and gregorian chant.

## History

I once wrote [psalmpreprocessor](https://github.com/igneus/In-adiutorium/blob/master/nastroje/psalmpreprocessor.rb)
as a relatively simple ad-hoc sollution; then I extended it step by step. 
It was ugly and dirty at the beginning and got only dirtier.
Then I restructured it, but it didn't get much cleaner. Then I needed it for another, quite different typesetting
project. ... Years later I decided to make a standalone gem with the same (and some additional) functionality.

## Psalm text files

### Purpose

Have psalm texts in a simple plain text format and easily render
various output formats with pointint for effortless correct chanting
according to the traditional psalmody formulas.
