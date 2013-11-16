# -*- coding: utf-8 -*-

require 'spec_helper'

describe Pslm::PslmReader do
  before :each do
    @psalm_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
    @reader = Pslm::PslmReader.new()
    @psalm = @reader.read_str(@psalm_text)
  end
  
  describe "#read_str" do
    
    it 'returns a Psalm' do
      @reader.read_str(@psalm_text).should be_an_instance_of Pslm::Psalm
    end
    
    it 'loads a title for the psalm' do
      @psalm.header.title.should eq 'Psalmus 116.'
    end
    
    it 'loads verses for the psalm' do
      @psalm.verses.should be_an_instance_of Array
      @psalm.verses.size.should eq 2
    end
  end
end