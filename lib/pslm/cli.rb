module Pslm
  class CLI
    # main entrypoint of the executable
    def self.call(argv)
      setup, args = Pslm::OptionParser.parse argv

      if args.empty? then
        raise "Program expects filenames as arguments."
      end

      Pslm::PsalmPointer.new(setup).process(args, setup[:general][:output_file])
    end
  end
end
