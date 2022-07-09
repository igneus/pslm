# -*- coding: utf-8 -*-

require 'spec_helper'

describe Pslm::PslmOutputter do
  before :each do
    @psalm_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
    @reader = Pslm::PslmReader.new()
    @psalm = @reader.read_str(@psalm_text)
  end
  
  describe "#process" do
    it 'recomposes the input format' do
      subject.process(@psalm).should eq @psalm_text
    end
    
    it 'doesn\'t, however, preserve comments' do
      psalm_text_with_comments = "Psalmus 116.
# The shortest psalm of the Psalter.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: * # Praise the Lord, all nations
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
      subject.process(@reader.read_str(psalm_text_with_comments)).should eq @psalm_text
    end
  end
end
