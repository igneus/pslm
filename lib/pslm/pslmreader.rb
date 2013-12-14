require 'stringio'
require 'delegate'

module Pslm
  # reads pslm files, provides their parsed data
  class PslmReader

    # public interface

    def read_str(str, has_title=true, autodetect=true)
      return load_psalm(CountingIStream.new(StringIO.new(str)), has_title, autodetect)
    end

    def read_file(fname, has_title=true, autodetect=true)
      return load_psalm(CountingIStream.new(File.open(str)), has_title, autodetect)
    end

    attr_reader :header

    # the following methods may be safely used, but aren't intended to

    # has_title - does the psalm text begin with a title line and an empty line?
    # autodetect - check if there really is a title to prevent wrong interpretation
    def load_psalm(istream, has_title=true, autodetect=true)
      ps = Pslm::Psalm.new

      ps.header.title = load_title(istream, has_title, autodetect)

      while v = load_verse(istream) do
        if v == '' then
          ps.add_strophe
        else
          ps.add_verse v
        end
      end

      return ps
    end

    # verse parts: order, names, distinguishing regexes
    VERSE_PARTS = [
      { :name => :flex, :method => :flex=, :regex => /\+\s*$/ },
      { :name => :first, :method => :first=, :regex => /\*\s*$/ },
      { :name => :second, :method => :second=, :regex => /[^\s\*\+]\s*$/ }
    ]

    def load_verse(istream)
      v = Psalm::Verse.new do |verse|
        part_loaded = gets_drop_comments istream
        VERSE_PARTS.each_with_index do |part, i|
          if part_loaded == nil then
            return part_loaded # eof
          end

          # empty line is strophe delimiter - return empty string to signal new strophe
          while part_loaded =~ /^\s*$/ do
            return ''
          end

          unless part_loaded =~ part[:regex]
            if part[:name] == :flex then
              next # probably a verse without flex - try to read the loaded line as a first half-verse
            end

            raise PslmSyntaxError.new("Unexpected verse part on line #{istream.lineno}: \"#{part_loaded}\" Expecting #{part[:name]}")
          end

          part_src = part_loaded.dup
          if [:flex, :first].include? part[:name] then
            part_loaded.sub!(/[\+\*]\s*$/, '') # there should be only one of these chars, at the very end of the line
            part_loaded.strip!
          end

          # split words, be aware of accents (space between accent parenthesis doesn't break word)
          words_raw = []
          in_accent = false
          word_start = 0
          part_loaded.chars.each_with_index do |c, ci|
            if c == '[' then
              in_accent = true
            elsif c == ']' then
              in_accent = false
            elsif in_accent == false && c == ' ' then
              words_raw << part_loaded[word_start .. ci-1]
              word_start = ci+1
            end
          end
          words_raw << part_loaded[word_start .. -1] # last word

          words = words_raw.collect do |w|
            sylls = []
            while w.size > 0 do
              i = w.index(/[\/\[\]]/)
              if i == nil then # last syllable
                sylls << Psalm::Syllable.new(syll_strip_special_chars(w))
                break
              end
              s = w.slice!(0..i)
              accent = (s[-1] == ']')
              s = s[0..-2] # discard the delimiter
              next if s == '' # delimiter at the beginning/end of the string
              sylls << Psalm::Syllable.new(syll_strip_special_chars(s), accent)
            end
            Psalm::Word.new(sylls)
          end
          versepart = Psalm::VersePart.new(words, part_src, part[:name])

          verse.send(part[:method], versepart)

          unless part[:name] == :second
            part_loaded = gets_drop_comments istream
          end
        end
      end

      return v
    end

    private

    # loads psalm title;
    # unless autodetect is false, a check is always done, if there is any title to load
    def load_title(istream, has_title, autodetect)
      if not autodetect and not has_title then
        return ''
      end

      title = gets_drop_comments istream
      after_title = gets_drop_comments istream

      unless autodetect then
        return title
      end

      # TODO real logging, not direct output to STDERR
      if after_title =~ /^\s*$/ then
        if not has_title then
          STDERR.puts "The psalm shouldn't have a title, but it has one."
        end
      else
        title = ''
        istream.rewind

        if has_title then
          STDERR.puts "The psalm should have a title, but none was found."
        end
      end

      return title
    end

    # gets next line from the input stream with comments dropped;
    # lines containing only whitespace+comment are thrown away
    def gets_drop_comments(istream)
      l = istream.gets
      if l == nil then
        return l # eof
      end

      l.strip!
      if l == '' then
        return l # strophe end
      end

      l = strip_comments(l)
      if l == '' then
        # line containing only a comment; try another one
        return gets_drop_comments(istream)
      end

      return l
    end

    # anything from # to the end of line is a comment
    def strip_comments(s)
      ci = s.index('#')
      if ci == 0 then
        return ''
      elsif ci != nil then
        return s[0..ci-1].strip
      else
        return s
      end
    end

    # removes special characters from a String before a Psalm Syllable
    # is created
    def syll_strip_special_chars(str)
      str.gsub('_', ' ') # underscore is "syllable-not-dividing space" mark
    end

    public

    class PslmSyntaxError < RuntimeError
    end
  end

  # wraps an input stream; counts lines read
  class CountingIStream < SimpleDelegator

    def initialize(stream)
      super(stream)
      @stream = stream
      @lineno = 0
    end

    attr_reader :lineno

    def gets
      l = @stream.gets
      @lineno += 1 if l != nil
      return l
    end

    def rewind
      @lineno = 0
      super
    end
  end

end