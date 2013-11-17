# -*- coding: utf-8 -*-

require 'spec_helper'
require 'stringio'

describe Pslm::LatexOutputter do
  before :each do
    @psalm_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:"
    # yes, I cheat - I deleted the second line to make the psalm shorter :)

    @reader = Pslm::PslmReader.new()
    @psalm = @reader.read_str(@psalm_text)
    @outputter = Pslm::LatexOutputter.new
  end

  describe "#get_outputter" do

    it 'returns an instance of a defined formatter class' do
      @outputter.get_formatter(:pointing, {}).should be_an_instance_of Pslm::LatexOutputter::PointingFormatter
    end

    it 'returns nil if there is no such formatter class' do
      @outputter.get_formatter(:cursing, {}).should eq nil
    end
  end

  describe "#process" do

    it 'returns just the text with no options' do
      expected = "Psalmus 116.

Laudáte Dóminum, omnes Gentes:
laudáte eum, omnes pópuli:"
      @outputter.process(@psalm, {}).should eq expected
    end

    it 'marks accents' do
      expected = 'Psalmus 116.

Laudáte Dóminum, \underline{om}nes \underline{Gen}tes:
laudáte eum, \underline{om}nes \underline{pó}puli:'
      @outputter.process(@psalm, {:pointing => {
        :accents => [2,2],
        :preparatory => [0,0],
        :accent_style => :underline,
      }}).should eq expected
    end
  end

  describe "#process_verse" do
    before :each do
      @verse_text = "Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *\n"+
        "lau/dá/te e/um, [om]nes [pó]pu/li:"
      @verse = @reader.load_verse(StringIO.new(@verse_text))
    end

    it 'returns just the text with no options' do
      expected = "Laudáte Dóminum, omnes Gentes:
laudáte eum, omnes pópuli:"
      @outputter.process_verse(@verse, {}).should eq expected
    end

    it 'marks accents' do
      expected = 'Laudáte Dóminum, \underline{om}nes \underline{Gen}tes:
laudáte eum, \underline{om}nes \underline{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :accents => [2,2],
        :preparatory => [0,0],
        :accent_style => :underline,
      }}).should eq expected
    end

    it 'marks as many accents as requested' do
      expected = 'Laudáte Dóminum, omnes \underline{Gen}tes:
laudáte eum, omnes \underline{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :accents => [1,1],
        :preparatory => [0,0],
        :accent_style => :underline,
      }}).should eq expected
    end

    it 'marks as many accents as requested (with many accents per part)' do
      verse_text = "Lau[dá]te [Dó]mi/num, [om]nes [Gen]tes: *\n"+
        "lau[dá]te [e]um, [om]nes [pó]pu/li:"
      verse = @reader.load_verse(StringIO.new(verse_text))

      expected = 'Laudáte Dóminum, omnes \underline{Gen}tes:
laudáte eum, omnes \underline{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :accents => [1,1],
        :preparatory => [0,0],
        :accent_style => :underline,
      }}).should eq expected
    end

    it 'marks preparatory two syllables' do
      expected = 'Laudáte Dóminum, \textit{omnes} \underline{Gen}tes:
laudáte eum, \textit{omnes} \underline{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :accents => [1,1],
        :preparatory => [2,2],
        :accent_style => :underline,
      }}).should eq expected
    end

    it 'marks one preparatory syllable' do
      expected = 'Laudáte Dóminum, om\textit{nes} \underline{Gen}tes:
laudáte eum, om\textit{nes} \underline{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :accents => [1,1],
        :preparatory => [1,1],
        :accent_style => :underline,
      }}).should eq expected
    end

    it 'marks preparatory syllables with word boundaries inbetween' do
      expected = 'Laudáte Dómi\textit{num, omnes} \underline{Gen}tes:
laudáte \textit{eum, omnes} \underline{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :accents => [1,1],
        :preparatory => [3,4],
        :accent_style => :underline,
      }}).should eq expected
    end

    it 'inserts break-hints' do
      expected = 'Lau\-dá\-te Dó\-mi\-num, om\-nes \underline{Gen}\-tes:
lau\-dá\-te e\-um, om\-nes \underline{pó}\-pu\-li:'
      @outputter.process_verse(@verse, {
        :pointing => {
          :accents => [1,1],
          :preparatory => [0,0],
          :accent_style => :underline,},
        :break_hints => true
      }).should eq expected
    end
  end
end