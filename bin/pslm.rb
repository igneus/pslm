#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# pslm - psalm processing utility

require 'pslm'

setup, args = Pslm::OptionParser.parse ARGV

if args.empty? then
  raise "Program expects filenames as arguments."
end

Pslm::PsalmPointer.new(setup).process(args, setup[:general][:output_file])
