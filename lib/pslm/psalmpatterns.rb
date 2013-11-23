# -*- coding: utf-8 -*-

require 'yaml'

module Pslm

  # holds and provides information on a set of psalm tones:
  # how many accents and preparatory syllables does each tone
  # need in first and second half-verse.
  class PsalmPatterns

    # expects a well-formed data structure -
    # as an example see the yaml files in directory psalmtones
    def initialize(data)
      @data = data
    end

    class << self

      def from_yaml(str)
        new(YAML::load(str))
      end

      def from_file(fname)
        from_yaml(File.open(fname).read())
      end

      # loads and returns data of a default tone-set
      def default
        from_file(File.expand_path('psalmtones/solesmes196x.yml', File.dirname(__FILE__)))
      end
    end

    # returns an Array like [[1,2], [2,0]]
    # specifying number of accents and
    def tone_data(tone, difference='')
      unless @data.has_key? tone
        raise ToneError.new "Unknown tone '#{tone}'"
      end

      if @data[tone][1][1].is_a? Hash then
        unless @data[tone][1][1].has_key? difference
          raise DifferenceError.new "Unknown difference '#{difference}' for tone '#{tone}'"
        end

        return [ @data[tone][0].dup , [ @data[tone][1][0], @data[tone][1][1][difference] ] ]
      else
        return @data[tone]
      end
    end

    # returns tone data for a tone identified by a String like 'I.D'
    def tone_data_str(tonestr)
      tone_data(*normalize_tone_str(tonestr))
    end

    # returns [tone, difference]
    def normalize_tone_str(str)
      nil
    end

    # returns tone data in a data structure containing Hashes
    # with descriptive keys
    def tone_data_verbose(tone, difference='')
      describe_tone_data(tone, difference)
    end

    def describe_tone_data(data)
      return data[0..1].collect {|part| {:accents => part[0], :preparatory => part[1] } }
    end

    # tone unknown
    class ToneError < KeyError
    end

    # difference unknown
    class DifferenceError < KeyError
    end
  end
end