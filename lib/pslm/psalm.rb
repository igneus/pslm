# -*- coding: utf-8 -*-

require 'ostruct'

# parsed psalm data
module Pslm
  class Psalm

    def initialize
      @header = OpenStruct.new
      @header.title = ''
      @strophes = [ Strophe.new ]
    end

    attr_reader :header, :strophes

    def verses
      @strophes.collect {|s| s.verses }.flatten
    end

    def add_strophe(s=nil)
      if s != nil then
        @strophes << s
      else
        @strophes << Strophe.new
      end
    end

    def add_verse(v)
      @strophes.last.verses << v
    end

    def ==(ps2)
      ps2.is_a?(Psalm) && self.header == ps2.header && self.strophes == ps2.strophes
    end

    # returns a new Psalm containing verses of the second appended to the verses
    # of the first; everything else is copied from the first
    # (title etc. of the second Psalm get lost)
    def +(ps2)
      ps_res = self.dup
      ps_res.strophes.concat ps2.strophes
      return ps_res
    end

    class Strophe
      def initialize
        @verses = []
      end

      attr_reader :verses

      def ==(s2)
        s2.is_a?(Strophe) && self.verses == s2.verses
      end
    end

    class Verse
      def initialize(flex=nil, first=nil, second=nil)
        @flex = flex
        @first = first
        @second = second
        if second.nil? then
          yield self
        end
      end

      attr_accessor :flex, :first, :second

      def parts
        r = [@first, @second]
        r.unshift @flex if @flex
        return r
      end

      def ==(v2)
        unless v2.is_a? Verse
          return false
        end

        [:flex, :first, :second].each do |part|
          if self.send(part) != v2.send(part) then
            return false
          end
        end

        return true
      end
    end

    class VersePart
      def initialize(words, src, pos)
        @words = words
        @src = src
        @pos = pos
      end

      # Array of Words
      attr_reader :words

      # the source text before parsing
      attr_reader :src

      # position in the verse - one of :flex, :first, :second
      attr_reader :pos

      def ==(p2)
        p2.is_a?(VersePart) && self.words == p2.words
      end
    end

    class Word
      def initialize(syllables)
        @syllables = syllables
      end

      attr_reader :syllables

      def ==(w2)
        w2.is_a?(Word) && self.syllables == w2.syllables
      end
    end

    class Syllable < String
      def initialize(chars, accent=false)
        super(chars)
        @accent = accent
      end

      def accent?
        @accent
      end

      def ==(s2)
        s2.is_a? Syllable and (self.to_s == s2.to_s) and (self.accent? == s2.accent?)
      end

      def to_s
        String.new self
      end

      def inspect
        accent = @accent ? ' accent' : ''
        return '#' + "<#{self.class}:#{self.object_id} \"#{self}\"#{accent}>"
      end
    end
  end
end