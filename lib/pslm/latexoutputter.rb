# -*- coding: utf-8 -*-

module Pslm
  
  # formats a psalm for LaTeX
  class LatexOutputter
    
    # takes a Psalm, returns a String with the psalm formatted
    def process(psalm, opts={})
      options = Pslm::Outputter::DEFAULT_OPTIONS.dup
      options.update opts
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
    
    # abstract superclass of the formatters
    class Formatter
      def initialize(options)
        @options = options
      end
    end
    
    class PointingFormatter < Formatter
      
    end
  end
end