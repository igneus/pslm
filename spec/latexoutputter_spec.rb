# -*- coding: utf-8 -*-

require 'spec_helper'
require 'stringio'

describe Pslm::LatexOutputter do
  before :each do
    @reader = Pslm::PslmReader.new()

    @psalm_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:"
    # yes, I cheat - I deleted the second line to make the psalm shorter :)
    @psalm = @reader.read_str(@psalm_text)

    @full_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
    @full_psalm = @reader.read_str(@full_text)

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
      expected =
"Laudáte Dóminum, omnes Gentes:
laudáte eum, omnes pópuli:"
      @outputter.process(@psalm, {}).should eq expected
    end

    it 'marks accents' do
      expected =
'Laudáte Dóminum, \underline{om}nes \underline{Gen}tes:
laudáte eum, \underline{om}nes \underline{pó}puli:'
      @outputter.process(@psalm, {:pointing => {
        :accents => [2,2],
        :preparatory => [0,0],
        :accent_style => :underline,
      }}).should eq expected
    end

    it 'wraps the whole psalm in an environment' do
      expected = '\begin{psalmus}
Psalmus 116.

Laudáte Dóminum, omnes Gentes:
laudáte eum, omnes pópuli:
\end{psalmus}' + "\n"
      @outputter.process(@psalm, {
        :wrapper => { :environment_name => 'psalmus' },
        :title => { :template => :plain }
      }).should eq expected
    end

    it 'paragraphifies verses' do
      expected = "Psalmus 116.

Laudáte Dóminum, omnes Gentes:
laudáte eum, omnes pópuli:

Quóniam confirmáta est super nos misericórdia ejus:
et véritas Dómini manet in ætérnum."
      @outputter.process(@full_psalm, {
        :verses => { :paragraphify => true },
        :title => { :template => :plain }
      }).should eq expected
    end

    it 'skips verses' do
      expected = "Quóniam confirmáta est super nos misericórdia ejus:
et véritas Dómini manet in ætérnum."
      @outputter.process(@full_psalm, {
        :skip_verses => 1,
      }).should eq expected
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

    it 'marks accents - bold' do
      expected = 'Laudáte Dóminum, omnes \textbf{Gen}tes:
laudáte eum, omnes \textbf{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :accents => [1,1],
        :preparatory => [0,0],
        :accent_style => :bold,
      }}).should eq expected
    end

    it 'marks accents and preparatory syllables for a specified psalm tone' do
      expected = 'Laudáte Dóminum, \textbf{om}nes \textbf{Gen}tes:
laudáte eum, \textit{omnes} \textbf{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :tone => 'I.f',
        :accent_style => :bold,
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

    it "doesn't insert break hint at the end of a word before interpunction" do
      verse_text = 'Non mó/ri[ar], sed [vi]vam: *
et nar/rá/bo [ó]pe/ra [Dó]mini.'
      expected = 'Non mó\-ri\-ar, sed vi\-vam:
et nar\-rá\-bo ó\-pe\-ra Dó\-mini.'
      verse = @reader.load_verse(StringIO.new(verse_text))
      @outputter.process_verse(verse, {
        :break_hints => true
      }).should eq expected
    end

    it 'inserts part-dividing characters: flex, asterisk' do
      verse_text = 'Lau/da á/ni/ma me/a [Dó]mi/num, + # psalm 145
lau/dá/bo Dó/mi/num in [vi]ta [me]a: *
psal/lam De/o me/o [quám]di/u [fú]e/ro.'
      expected = 'Lauda ánima mea Dóminum,~\dag\mbox{}
laudábo Dóminum in vita mea:~*
psallam Deo meo quámdiu fúero.'
      verse = @reader.load_verse(StringIO.new(verse_text))
      @outputter.process_verse(verse, {
        :parts => {
          :marks_type => :simple,
          :novydvur_newlines => false,}
      }).should eq expected
    end

    it 'breaks verse parts on separate lines' do
      verse_text = 'Lau/da á/ni/ma me/a [Dó]mi/num, + # psalm 145
lau/dá/bo Dó/mi/num in [vi]ta [me]a: *
psal/lam De/o me/o [quám]di/u [fú]e/ro.'
      expected = 'Lauda ánima mea Dóminum,\\\\
laudábo Dóminum in vita mea:\\\\
psallam Deo meo quámdiu fúero.'
      verse = @reader.load_verse(StringIO.new(verse_text))
      @outputter.process_verse(verse, {
        :parts => {
          :marks_type => :no,
          :novydvur_newlines => true,}
      }).should eq expected
    end

    it 'makes a lettrine' do
      expected = '\lettrine{L}{audáte} Dóminum, omnes Gentes:
laudáte eum, omnes pópuli:'
      @outputter.process_verse(@verse, {
        :lettrine => {}
      }).should eq expected
    end

    it 'makes a lettrine with digraph' do
      verse_text = "Chvalte Hospo[di]na [z ne]bes, *
chvalte ho [na] vý[sos]tech!"
      expected = '\lettrine{Ch}{valte} Hospodina z nebes,
chvalte ho na výsostech!'
      verse = @reader.load_verse(StringIO.new(verse_text))
      @outputter.process_verse(verse, {
        :lettrine => { :digraphs => ['ch'] }
      }).should eq expected
    end
  end
end