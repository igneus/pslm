require 'stringio'

module Pslm
  # reads pslm files, provides their parsed data
  class PslmReader
    
    def read_str(str)
      return load(CountingIStream.new(StringIO.new(str)))
    end
    
    def read_file(fname)
      return load(CountingIStream.new(File.open(str)))
    end
    
    attr_reader :header
    
    private
    
    def load(istream)
      ps = Pslm::Psalm.new
      
      ps.header.title = istream.gets.strip
      istream.gets # skip empty line
      
      while v = load_verse(istream) do
        ps.verses << v
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
        part_loaded = load_verse_part istream
        VERSE_PARTS.each_with_index do |part, i|
          if part_loaded == nil then
            return part_loaded # eof
          end
          
          unless part_loaded =~ part[:regex]
            if part[:name] == :flex then
              next
            end
            
            raise PslmSyntaxError.new("Unexpected verse part on line #{istream.lineno}.")
          end
          
          verse.send(part[:method], part_loaded)
          
          unless part[:name] == :second
            part_loaded = load_verse_part istream
          end
        end
      end
      
      return v
    end
    
    def load_verse_part(istream)
      l = istream.gets
      if l == nil then
        return l # eof
      end
      
      l.strip!
      if l == '' then
        return l # strophe end
      end
      
      return strip_comments(l)
    end
    
    def strip_comments(s)
      ci = s.index('#')
      if ci != nil then
        return s[0..ci-1].strip
      else
        return s
      end
    end
  end
  
  class PslmSyntaxError < RuntimeError
  end
  
  # wraps an input stream; counts lines read
  class CountingIStream
    
    def initialize(stream)
      @stream = stream
      @lineno = 0
    end
    
    attr_reader :lineno
    
    def gets
      @lineno += 1
      return @stream.gets
    end
  end

end