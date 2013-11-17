# -*- coding: utf-8 -*-

module Pslm

  # formats a psalm for LaTeX
  class LatexOutputter

    FORMATTER_ORDER = [
      :title,
      :pointing,
      :verses,
      :strophes,
      :lettrine,
      :prepend_text,
      :output_append_text,
      :line_break_last_line,
      :guillemets,
      :mark_short_verses
    ]

    # takes a Psalm, returns a String with the psalm formatted
    def process_psalm(psalm, opts={})
      formatters = get_formatters(opts)

      # build the output; on each step apply the appropriate method
      # of each formatter in the given order
      psalm_assembled = psalm.verses.collect do |verse|
        process_verse(verse, opts)
      end.join "\n"

      return psalm.header.title + "\n\n" + psalm_assembled
    end

    alias :process :process_psalm

    def process_verse(verse, opts)
      formatters = get_formatters(opts)

      verse_assembled = verse.parts.collect do |part|

        part_assembled = part.words.reverse.collect do |word|

          word_assembled = word.syllables.reverse.collect do |syll|
            Formatter.format(formatters, :syllable,
                              syll, part, word, syll)
          end.reverse.join ''

          Formatter.format(formatters, :word,
                            word_assembled, word)
        end.reverse.join ' '

        Formatter.format(formatters, :part,
                          part_assembled, part)
      end.join "\n"

      return Formatter.format(formatters, :verse,
                              verse_assembled, verse)
    end

    # takes a Hash of options,
    # returns a list of accordingly initialized Formatter instances
    def get_formatters(options)
      return FORMATTER_ORDER.collect do |f|
        next unless options.include? f

        get_formatter(f, options[f])
      end.compact!
    end

    # takes a Symbol - name of a configuration option, and option/s value;
    # returns an instance of a corresponding Formatter class or nil
    def get_formatter(sym, options)
      cls_name = sym.to_s.gsub(/_(\w)/) {|m| m[1].upcase }
      cls_name[0] = cls_name[0].upcase
      cls_name += 'Formatter'

      if self.class.const_defined? cls_name then
        return self.class.const_get(cls_name).new(options)
      else
        return nil
      end
    end

    # abstract superclass of the formatters providing dumb implementation
    # of all formatting methods
    class Formatter

      class << self
        # lets all the :formatters: subsequently format :text: assembled from :obj: on the assembly :level:
        def format(formatters, level, text, *args)
          formatters.each do |f|
            text = f.send("#{level}_format", text, *args)
          end
          return text
        end
      end

      def initialize(options)
        @options = options
        @syll_counter = 0
        @word_counter = 0
        @part_counter = 0
        @verse_counter = 0
      end

      def psalm_format(text, psalm)
        @syll_counter = 0
        @word_counter = 0
        @part_counter = 0
        @verse_counter = 0
        text
      end

      def verse_format(text, verse)
        @verse_counter += 1
        @syll_counter = 0
        @word_counter = 0
        @part_counter = 0
        text
      end

      def part_format(text, part)
        @part_counter += 1
        @syll_counter = 0
        @word_counter = 0
        text
      end

      def word_format(text, word)
        @word_counter += 1
        text
      end

      def syllable_format(text, part, word, syll)
        @syll_counter += 1
        text
      end
    end

    class PointingFormatter < Formatter
      def initialize(options)
        super(options)
        @accent_counter = 0
      end

      def part_format(text, part)
        super(text, part)
        @accent_counter = 0
        text
      end

      def syllable_format(text, part, word, syll)
        super(text, part, word, syll)
        if syll.accent? then
          @accent_counter += 1
          if (part.pos == :flex and @accent_counter == 1) or
              (part.pos == :first and @accent_counter <= @options[:accents][0]) or
              (part.pos == :second and @accent_counter <= @options[:accents][1]) then
            return "\\underline{#{text}}"
          end
        end

        return syll
      end
    end
  end
end