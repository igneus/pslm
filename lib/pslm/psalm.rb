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
      @flex = flex,
      @first = first,
      @second = second
      if second.nil? then
        yield self
      end
    end
    
    attr_accessor :flex, :first, :second
  end
  
  class VersePart
    def initialize(words, src)
      @words = words
      @src = src
    end
    
    attr_reader :words, :src
  end
  
  class Word
    def initialize(syllables)
      @syllables = syllables
    end
    
    attr_reader :syllables
  end
  
  class Syllable
    def initialize(chars, accent=false)
      @chars = chars
      @accent = accent
    end
        
    def accent?
      @accent
    end
  end
end
