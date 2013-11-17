# -*- coding: utf-8 -*-

require 'spec_helper'

describe Pslm::Psalm do

  describe "#+" do
    it 'concatenates two psalms' do
      reader = Pslm::PslmReader.new
      outputter = Pslm::PslmOutputter.new
      psalm_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
      gloria_text = "Gló/ri/a [Pat]ri et [Fí]lio, *
et Spi[rí]tu/i [San]cto.
Sicut erat in prin/cí/pio, et [nunc] et [sem]per, *
et in sǽ/cu/la sæ/cu[ló]rum. [A]men."
      psalm = reader.read_str psalm_text
      gloria = reader.read_str gloria_text, false

      psalm += gloria
      outputter.process(psalm).should eq 'Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num.
Gló/ri/a [Pat]ri et [Fí]lio, *
et Spi[rí]tu/i [San]cto.
Sicut erat in prin/cí/pio, et [nunc] et [sem]per, *
et in sǽ/cu/la sæ/cu[ló]rum. [A]men.'
    end
  end

  Syllable = Pslm::Psalm::Syllable

  describe Syllable do

    it 'compares with == as expected' do
      Syllable.new('hi').should == Syllable.new('hi')
    end
  end
end