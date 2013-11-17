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
      options = opts
      
      formatters = []
      FORMATTER_ORDER.each do |f|
        next unless opts.include? f
        formatter = get_formatter(f, opts[f])
        next if formatter == nil
        
        formatters << formatter
      end
      
      # build the output; on each step apply the appropriate method
      # of each formatter in the given order
      psalm_assembled = psalm.verses.collect do |verse|
        
        verse_assembled = verse.parts.collect do |part|
          
          part_assembled = part.words.collect do |word|
            
            word_assembled = word.syllables.collect do |syll|              
              Formatter.format(formatters, :syllable, syll, syll)
            end.join ''
            
            #word_format word_assembled, word
            
          end.join ' '
          #part_format part_assembled, part
          
        end.join "\n"
        #verse_format verse_assembled, verse
        
      end.join "\n"
      
      return psalm.header.title + "\n\n" + psalm_assembled
    end
    
    alias :process :process_psalm
    
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
        def format(formatters, level, text, obj)
          formatters.each do |f|
            text = f.send("#{level}_format", text, obj)
          end
          return text
        end
      end
      
      def initialize(options)
        @options = options
      end
      
      def psalm_format(text, psalm)
        text
      end
      
      def verse_format(text, verse)
        text
      end
      
      def part_format(text, part)
        text
      end
      
      def word_format(text, word)
        text
      end
      
      def syllable_format(text, syll)
        text
      end
    end
    
    class PointingFormatter < Formatter
      def syllable_format(text, syll)
        syll.accent? ? "\\underline{#{text}}" : syll
      end
    end
  end
end