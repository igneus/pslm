# -*- coding: utf-8 -*-

module Pslm

  # reconstructs the input format
  #
  # an easier implementation would make use of VersePart#src, but
  # this should be a simple example of full-depth output preparation
  class PslmOutputter < Outputter

    # doesn't respect any options; accepts them only because of a common
    # outputter interface
    def process(psalm, options={})
      psalm_assembled = psalm.verses.collect do |verse|

        verse_assembled = verse.parts.collect do |part|

          part_assembled = part.words.collect do |word|

            word_assembled = ''
            word.syllables.each_with_index do |syll, si|

              if word_assembled.size > 0 and
                  not word.syllables[si-1].accent? and
                  not syll.accent? then
                word_assembled += '/'
              end
              word_assembled += syllable_format(syll)
            end

            word_format word_assembled, word

          end.join ' '
          part_format part_assembled, part

        end.join "\n"
        verse_format verse_assembled, verse

      end.join "\n"

      return psalm.header.title + "\n\n" + psalm_assembled
    end

    def syllable_format(syll)
      if syll.accent? then
        return '[' + syll + ']'
      end

      return syll
    end

    def word_format(text, word)
      text
    end

    def part_format(text, part)
      case part.pos
      when :flex
        return text + ' +'
      when :first
        return text + ' *'
      else
        return text
      end
    end

    def verse_format(text, verse)
      text
    end
  end
end