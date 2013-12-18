# -*- coding: utf-8 -*-

module Pslm

  # formats a psalm for LaTeX
  class LatexOutputter < Outputter

    # each Formatter must have it's symbol in the order, otherwise it won't be used
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
      :quote,
      :mark_short_verses
    ]

    # takes a Psalm, returns a String with the psalm formatted
    def process_psalm(psalm, opts={})
      formatters = get_formatters(opts)

      # build the output; on each step apply the appropriate method
      # of each formatter in the given order
      psalm_assembled = psalm.strophes.collect do |strophe|
        process_strophe(strophe, opts, psalm, formatters)
      end.join "\n"

      return Formatter.format(formatters, :psalm,
                              psalm_assembled,
                              psalm)
    end

    alias :process :process_psalm

    def process_strophe(strophe, opts, psalm, formatters=nil)
      formatters = formatters || get_formatters(opts)

      strophe_assembled = strophe.verses.collect do |verse|
        process_verse(verse, opts, strophe, psalm, formatters)
      end.delete_if {|v| v == '' }.join "\n"

      return Formatter.format(formatters, :strophe,
                              strophe_assembled,
                              strophe,
                              psalm)
    end

    def process_verse(verse, opts, strophe=nil, psalm=nil, formatters=nil)
      formatters = formatters || get_formatters(opts)

      verse_assembled = verse.parts.collect do |part|

        part_assembled = part.words.reverse.collect do |word|

          word_assembled = word.syllables.reverse.collect do |syll|
            Formatter.format(formatters, :syllable,
                              syll, syll, word, part, verse, strophe, psalm)
          end.reverse.join ''

          Formatter.format(formatters, :word,
                            word_assembled, word, part, verse, strophe, psalm)
        end.reverse.join ' '

        Formatter.format(formatters, :part,
                          part_assembled, part, verse, strophe, psalm)
      end.join "\n"

      return Formatter.format(formatters, :verse,
                              verse_assembled, verse, strophe, psalm)
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
        #STDERR.puts "formatter #{cls_name} not found"
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

      def strophe_format(text, strophe, psalm)
        text
      end

      def verse_format(text, verse, strophe, psalm)
        @verse_counter += 1
        @syll_counter = 0
        @word_counter = 0
        @part_counter = 0
        text
      end

      def part_format(text, part, verse, strophe, psalm)
        @part_counter += 1
        @syll_counter = 0
        @word_counter = 0
        text
      end

      def word_format(text, word, part, verse, strophe, psalm)
        @word_counter += 1
        text
      end

      def syllable_format(text, syll, word, part, verse, strophe, psalm)
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

        # validate options
        if @options.has_key? :tone and
            (@options.has_key? :accents or @options.has_key? :preparatory) then
          raise RuntimeError.new('Overconfigured: both accents/preparatories number and psalm tone specified.')
        elsif @options.has_key? :accents then
          # ok, nothing to do
        elsif @options.has_key? :tone
          # convert psalm tone identifier to numbers
          tone = PsalmPatterns.default.tone_data_str(@options[:tone])
          @options[:accents] = tone.collect {|part| part[0] }
          @options[:preparatory] = tone.collect {|part| part[1] }
        end
      end

      def part_format(text, part, verse, strophe, psalm)
        super(text, part, verse, strophe, psalm)
        @accent_counter = 0
        @preparatories_counter = 0
        text
      end

      MARKS = {
        :underline => 'underline',
        :bold => 'textbf',
        :semantic => 'accent'
      }

      def syllable_format(text, syll, word, part, verse, strophe, psalm)
        super(text, syll, word, part, verse, strophe, psalm)
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
      def syllable_format(text, syll, word, part, verse, strophe, psalm)
        unless syll == word.syllables.last or
            (word.syllables.size >= 2 and syll == word.syllables[-2] and word.syllables[-1] =~ /^[\.,!?]+$/)
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

      def part_format(text, part, verse, strophe, psalm)
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

    class StrophesFormatter < Formatter

      END_MARKS = {
        :semantic => '\psalmStrophe',
        :simple => '\hspace*{0pt}\hfill--'
      }

      def initialize(options)
        super
        @options[:paragraph_space] ||= false
        @options[:end_marks] ||= false
        @options[:mark_last_strophe] ||= false
      end

      def strophe_format(text, strophe, psalm)
        if strophe == psalm.strophes.last and not @options[:mark_last_strophe] then
          return text
        end

        if @options[:end_marks] then
          text += END_MARKS[@options[:end_marks]]
        end
        if @options[:paragraph_space] then
          text += '\\'
        end
        return text
      end
    end

    # inserts a newline between verses
    class VersesFormatter < Formatter
      def verse_format(text, verse, strophe, psalm)
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

      def verse_format(text, verse, strophe, psalm)
        #super(text, psalm, verse)
        @verse_counter += 1
        if @verse_counter <= @skip_verses then
          return ""
        end

        return text
      end
    end

    # formats the first word of the first verse as a lettrine
    class LettrineFormatter < Formatter
      def initialize(options)
        super(options)
        @digraphs = []
        if @options and @options[:digraphs] then
          @digraphs = @options[:digraphs]
        end
        @done = false
      end

      def verse_format(text, verse, strophe, psalm)
        return text if @done

        @done = true
        return text.sub(/^([^\s]+)/) {
          initial_size = 1
          digraph = @digraphs.find {|d| text.downcase.start_with? d }
          if digraph then
            initial_size = digraph.size
          end
          '\lettrine{'+$1[0...initial_size].upcase+'}{'+$1[initial_size..-1]+'}'
        }
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

    # replaces dumb quotation marks "" by smarter ones
    class QuoteFormatter < Formatter

      STYLES = {
        :double => ["``", "''"],
        :single => ["'", "'"],
        :guillemets => ['\guillemotright ', '\guillemotleft '],
        :delete => ['', '']
      }

      def initialize(options)
        super(options)
        @style = @options
        unless STYLES.has_key? @style
          raise "Quotation marks style '#{@style}' unknown."
        end
        @quote_counter = 0
        puts "hey ho"
      end

      def psalm_format(text, psalm)
        super(text, psalm)
        @quote_counter = 0
        text
      end

      def verse_format(text, verse, strophe, psalm)
        return text.gsub('"') do
          @quote_counter += 1
          if @quote_counter % 2 == 1 then
            STYLES[@style].first
          else
            STYLES[@style].last
          end
        end
      end
    end
  end
end