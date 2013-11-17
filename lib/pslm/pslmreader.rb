require 'stringio'

module Pslm
  # reads pslm files, provides their parsed data
  class PslmReader
    
    # public interface
    
    def read_str(str)
      return load_psalm(CountingIStream.new(StringIO.new(str)))
    end
    
    def read_file(fname)
      return load_psalm(CountingIStream.new(File.open(str)))
    end
    
    attr_reader :header
    
    # the following methods may be safely used, but aren't intended to
        
    def load_psalm(istream)
      ps = Pslm::Psalm.new
      
      ps.header.title = gets_drop_comments istream
      gets_drop_comments istream # skip empty line
      
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
        part_loaded = gets_drop_comments istream
        VERSE_PARTS.each_with_index do |part, i|
          if part_loaded == nil then
            return part_loaded # eof
          end
          
          unless part_loaded =~ part[:regex]
            if part[:name] == :flex then
              next # probably a verse without flex - try to read the loaded line as a first half-verse
            end
            
            raise PslmSyntaxError.new("Unexpected verse part on line #{istream.lineno}: \"#{part_loaded}\" Expecting #{part[:name]}")
          end
          
          part_src = part_loaded.dup
          if [:flex, :first].include? part[:name] then
            part_loaded.sub!(/[\+\*]/, '') # there should be only one of these chars, at the very end of the line
            part_loaded.strip!
          end
          
          words = Psalm::VersePart.new(part_loaded.split(' ').collect {|w|
            sylls = []
            while w.size > 0 do
              i = w.index(/[\/\[\]]/)
              if i == nil then # last syllable
                sylls << Psalm::Syllable.new(w)
                break
              end
              s = w.slice!(0..i)
              accent = (s[-1] == ']')
              s = s[0..-2] # discard the delimiter
              next if s == '' # delimiter at the beginning/end of the string
              sylls << Psalm::Syllable.new(s, accent)
            end
            Psalm::Word.new(sylls)
          }, part_src, part[:name])
          
          verse.send(part[:method], words)
          
          unless part[:name] == :second
            part_loaded = gets_drop_comments istream
          end
        end
      end
      
      return v
    end
    
    private
    
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
    
    public
    
    class PslmSyntaxError < RuntimeError
    end
  end
  
  # wraps an input stream; counts lines read
  class CountingIStream
    
    def initialize(stream)
      @stream = stream
      @lineno = 0
    end
    
    attr_reader :lineno
    
    def gets
      l = @stream.gets
      @lineno += 1 if l != nil
      return l
    end
  end

end