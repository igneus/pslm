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

    it 'leaves flex nil if not found' do
      @psalm.verses[0].flex.should eq nil
    end

    it 'sets verse parts the appropriate position' do
      @psalm.verses[0].first.pos.should eq :first
      @psalm.verses[0].second.pos.should eq :second
    end

    it 'parses words' do
      @psalm.verses[0].first.words.size.should eq 4
    end

    it 'parses even syllables' do
      first_verse = @psalm.verses[0]
      first_part = first_verse.first
      first_part.words[0].syllables.size.should eq 3
      first_part.words[1].syllables.size.should eq 3
      first_part.words[2].syllables.size.should eq 2
      first_part.words[3].syllables.size.should eq 2
    end

    it 'parses accentuated syllables' do
      first_verse = @psalm.verses[0]
      first_part = first_verse.first
      first_part.words[3].syllables[0].accent?.should eq true
      first_part.words[3].syllables[1].accent?.should eq false
    end

    it 'drops comments in the psalm text' do
      psalm_text_with_comments = "Psalmus 116.

# The shortest psalm of the Psalter.
Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: * # Praise the Lord, all nations
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
      @reader.read_str(psalm_text_with_comments).should == @psalm
    end

    it 'drops comments in the header' do
      psalm_text_with_comments = "Psalmus 116.
# The shortest psalm of the Psalter.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: * # Praise the Lord, all nations
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
      @reader.read_str(psalm_text_with_comments).should == @psalm
    end

    it 'is able to read psalm without a title' do
      bare_text = 'Gló/ri/a [Pat]ri et [Fí]lio, *
et Spi[rí]tu/i [San]cto.
Sicut erat in prin/cí/pio, et [nunc] et [sem]per, *
et in sǽ/cu/la sæ/cu[ló]rum. [A]men.'
      psalm = @reader.read_str(bare_text, false)
      psalm.verses.size.should eq 2
      psalm.header.title.should eq ''
    end
  end
end