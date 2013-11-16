# -*- coding: utf-8 -*-

require 'spec_helper'

describe Pslm::LatexOutputter do
  before :each do
    @psalm_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
    @reader = Pslm::PslmReader.new()
    @psalm = @reader.read_str(@psalm_text)
    @outputter = Pslm::LatexOutputter.new
  end
  
  describe "#read_str" do
  end
  
  describe "#get_outputter" do
    
    it 'returns an instance of a defined formatter class' do
      @outputter.get_formatter(:pointing, {}).should be_an_instance_of Pslm::LatexOutputter::PointingFormatter
    end
    
    it 'returns nil if there is no such formatter class' do
      @outputter.get_formatter(:cursing, {}).should eq nil
    end
  end
end