# -*- coding: utf-8 -*-

require 'ostruct'

# parsed psalm data
class Pslm::Psalm

  def initialize
    @header = OpenStruct.new
    @verses = []
    @strophes = []
  end
  
  attr_reader :header, :verses
  
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
  end
  
  class Word
    def initialize(syllables)
      @syllables = syllables
    end
    
    attr_reader :syllables
  end
  
  class Syllable < String
    def initialize(chars, accent=false)
      super(chars)
      @accent = accent
    end
            
    def accent?
      @accent
    end
  end
end
