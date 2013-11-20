# -*- coding: utf-8 -*-

module Pslm

  # Workhorse of the pslm CLI utility.
  class PsalmPointer

    def initialize(options)
      @options = options
      @reader = PslmReader.new
    end

    def process(psalm_files)
      if @options[:general][:output_file] != nil then
        outf = File.open @options[:general][:output_file], 'w'
      else
        outf = STDOUT
      end

      psalms = psalm_files.collect do |pf|
        @reader.load_psalm(open_psalm_file(pf))
      end

      if @options[:input][:join] then
        while p = psalms.slice!(1) do
          psalms[0] += p
        end
      end

      outputter = get_outputter @options[:general][:format]
      psalms.each do |ps|
        outf.puts outputter.process_psalm ps, @options[:output]
      end

      if outf != STDOUT then
        outf.close
      end
    end

    private

    def open_psalm_file(fname)
      if fname == '-' then
        return STDIN
      else
        return File.open fname
      end
    end

    def get_outputter(format)
      cls_name = format.to_s.gsub(/_(\w)/) {|m| m[1].upcase }
      cls_name[0] = cls_name[0].upcase
      cls_name += 'Outputter'

      if Pslm.const_defined? cls_name then
        return Pslm.const_get(cls_name).new
      else
        return nil
      end
    end
  end
end