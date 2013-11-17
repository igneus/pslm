# -*- coding: utf-8 -*-

require 'ostruct'

# parsed psalm data
class Pslm::Psalm

  def initialize
    @header = OpenStruct.new
    @header.title = ''
    @verses = []
    @strophes = []
  end

  attr_reader :header, :verses

  def ==(ps2)
    self.header == ps2.header && self.verses == ps2.verses
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
      self.words == p2.words
    end
  end

  class Word
    def initialize(syllables)
      @syllables = syllables
    end

    attr_reader :syllables

    def ==(w2)
      self.syllables == w2.syllables
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
      (self.to_s == s2.to_s) and (self.accent? == s2.accent?)
    end

    def inspect
      accent = @accent ? ' accent' : ''
      return '#' + "<#{self.class}:#{self.object_id} \"#{self}\"#{accent}>"
    end
  end
end
