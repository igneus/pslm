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
    @outputter = Pslm::PslmOutputter.new
  end
  
  describe "#process" do
    it 'recomposes the input format' do
      @outputter.process(@psalm).should eq @psalm_text
    end
  end
end