# -*- coding: utf-8 -*-

module Pslm

  # formats a psalm for LaTeX
  class LatexOutputter < Outputter

    FORMATTER_ORDER = [
      :pointing,
      :break_hints,
      :parts,
      :verses,
      :skip_verses,
      :title,
      :strophes,
      :lettrine,
      :wrapper,
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
        process_verse(verse, opts, psalm, formatters)
      end.delete_if {|v| v == '' }.join "\n"

      return Formatter.format(formatters, :psalm,
                              psalm_assembled,
                              psalm)
    end

    alias :process :process_psalm

    def process_verse(verse, opts, psalm=nil, formatters=nil)
      formatters = formatters || get_formatters(opts)

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
                              verse_assembled, psalm, verse)
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

      def verse_format(text, psalm, verse)
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

    # marks accentuated and preparatory syllables
    class PointingFormatter < Formatter
      def initialize(options)
        super(options)
        @accent_counter = 0
        @preparatories_counter = 0
      end

      def part_format(text, part)
        super(text, part)
        @accent_counter = 0
        @preparatories_counter = 0
        text
      end

      MARKS = {
        :underline => 'underline',
        :bold => 'textbf',
        :semantic => 'accent'
      }

      def syllable_format(text, part, word, syll)
        super(text, part, word, syll)
        r = text
        if syll.accent? then
          @accent_counter += 1
          if @accent_counter <= num_accents_for(part) then
            r = "\\#{MARKS[@options[:accent_style]]}{#{r}}"
          end
        end

        if num_preparatory_syllables_for(part) > 0 and
            @accent_counter >= num_accents_for(part) then

          if @accent_counter == num_accents_for(part) and
              @preparatories_counter == 1 then
            r = r + "}"
          end
          if @preparatories_counter == num_preparatory_syllables_for(part) then
            r = '\textit{' + r
          end

          @preparatories_counter += 1
        end

        return r
      end

      private

      # how many accents to mark in this verse-part?
      def num_accents_for(part)
        case part.pos
        when :flex
          1
        when :first
          @options[:accents][0]
        when :second
          @options[:accents][1]
        end
      end

      # how many preparatory syllables to mark in this verse-part?
      def num_preparatory_syllables_for(part)
        case part.pos
        when :flex
          0
        when :first
          @options[:preparatory][0]
        when :second
          @options[:preparatory][1]
        end
      end
    end

    # inserts break hints between syllables
    class BreakHintsFormatter < Formatter
      def syllable_format(text, part, word, syll)
        if syll != word.syllables.last then
          return text + '\-'
        else
          return text
        end
      end
    end

    # formatting of verse parts -
    # adds part dividing marks (flex, asterisk),
    # eventually inserts newlines
    class PartsFormatter < Formatter

      MARKS = {
        :simple => { :flex => '~\dag\mbox{}', :first => '~*', :second => '' },
        :semantic => { :flex => '\flex', :first => '\asterisk', :second => '' },
        :no => { :flex => '', :first => '', :second => '' }
      }

      def part_format(text, part)
        text +
          MARKS[@options[:marks_type]][part.pos] +
          ((@options[:novydvur_newlines] && part.pos != :second) ? "\\\\" : '') # insert two backslashes
      end
    end

    # wraps the whole psalm in a LaTeX environment
    class WrapperFormatter < Formatter
      def psalm_format(text, psalm)
        "\\begin{#{@options[:environment_name]}}\n" + text + "\n\\end{#{@options[:environment_name]}}\n"
      end
    end

    # inserts a newline between verses
    class VersesFormatter < Formatter
      def verse_format(text, psalm, verse)
        if verse != psalm.verses.last and text != '' then
          return text + "\n"
        else
          return text
        end
      end
    end

    # skips verses at the beginning
    class SkipVersesFormatter < Formatter
      def initialize(options)
        super(options)
        @skip_verses = @options # takes just one number as a parameter
      end

      def verse_format(text, psalm, verse)
        #super(text, psalm, verse)
        @verse_counter += 1
        if @verse_counter <= @skip_verses then
          return ""
        end

        return text
      end
    end

    # formats title
    class TitleFormatter < Formatter
      TEMPLATE = {
        :no => "", # "" % anything => ""
        :plain => "%s\n\n",
        :semantic => "\\titulusPsalmi{%s}\n\n"
      }

      def psalm_format(text, psalm)
        TEMPLATE[@options[:template]] % psalm.header.title +
          text
      end
    end
  end
end