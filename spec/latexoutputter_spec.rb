# -*- coding: utf-8 -*-

require 'spec_helper'
require 'stringio'

describe Pslm::LatexOutputter do
  before :each do
    @reader = Pslm::PslmReader.new()

    psalm_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:"
    # yes, I cheat - I deleted the second line to make the psalm shorter :)
    @psalm = @reader.read_str(psalm_text)

    full_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:
Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
    @full_psalm = @reader.read_str(full_text)

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

    it 'marks accents and preparatory syllables with semantic commands' do
      expected = 'Laudáte Dóminum, \accent{om}nes \accent{Gen}tes:
laudáte eum, \preparatory{omnes} \accent{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :tone => 'I.f',
        :accent_style => :semantic,
      }}).should eq expected
    end

    it 'marks accents and preparatory syllables each with different style' do
      expected = 'Laudáte Dóminum, \underline{om}nes \underline{Gen}tes:
laudáte eum, \preparatory{omnes} \underline{pó}puli:'
      @outputter.process_verse(@verse, {:pointing => {
        :tone => 'I.f',
        :accent_style => :underline,
        :preparatory_style => :semantic,
      }}).should eq expected
    end

    it 'marks accents and preparatory syllables with nothing' do
      expected = 'Laudáte Dóminum, omnes Gentes:
laudáte eum, omnes pópuli:'
      @outputter.process_verse(@verse, {:pointing => {
        :accents => [1,1],
        :preparatory => [2,2],
        :accent_style => :none,
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
      expected = '\lettrine{CH}{valte} Hospodina z nebes,
chvalte ho na výsostech!'
      verse = @reader.load_verse(StringIO.new(verse_text))
      @outputter.process_verse(verse, {
        :lettrine => { :digraphs => ['ch'] }
      }).should eq expected
    end

    it 'replaces a pair of quotation marks in a verse' do
      verse_text = 'Jak to, že bezbožník [po]hrdá [Bo]hem *
a říká si v srdci: "[Ne]po[tres]tá!"?'
      expected = "Jak to, že bezbožník pohrdá Bohem
a říká si v srdci: ``Nepotrestá!''?"
      verse = @reader.load_verse(StringIO.new(verse_text))
      @outputter.process_verse(verse, {
        :quote => :double
      }).should eq expected
    end

    it 'deletes quotation marks' do
      verse_text = 'Jak to, že bezbožník [po]hrdá [Bo]hem *
a říká si v srdci: "[Ne]po[tres]tá!"?'
      expected = "Jak to, že bezbožník pohrdá Bohem
a říká si v srdci: Nepotrestá!?"
      verse = @reader.load_verse(StringIO.new(verse_text))
      @outputter.process_verse(verse, {
        :quote => :delete
      }).should eq expected
    end

    describe 'sliding accent' do
      let(:settings) do
        {:pointing => {
           :accents => [2, 2],
           :preparatory => [0,0],
           :sliding_accent => [false, true],
           :accent_style => :bold,
         }}
      end

      let(:verse) { @reader.load_verse StringIO.new text }

      describe 'no superfluous note' do
        let(:text) { 'Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num.' }

        it 'marks the accent as usual' do
          @outputter.process_verse(verse, settings)
            .should eq 'Quóniam confirmáta est super nos miseri\textbf{cór}dia \textbf{e}jus:
et véritas Dómini manet \textbf{in} æ\textbf{tér}num.'
        end
      end

      describe 'superfluous note given' do
        let(:text) { 'Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:' }

        it 'marks the accent and the superfluous note as single unit' do
          @outputter.process_verse(verse, settings)
            .should eq 'Laudáte Dóminum, \textbf{om}nes \textbf{Gen}tes:
laudáte eum, \textbf{om}nes \textbf{pópu}li:'
        end
      end
    end
  end

  describe '#process_psalm' do
    it 'replaces quotation marks correctly in a psalm' do
      psalm_text = 'Žalm 110, 1-5.7

Hos/po/din ře/kl mé/mu [Pá]nu: +
"Seď [po] mé [pra]vi/ci, *
do/kud ne/po/lo/žím tvé ne/přá/te/le za pod[nož] tvým [no]hám."
Žezlo moci ti podává Hos/po/din [ze] Si[ó]nu: *
"Pa/nuj u/pro[střed] svých [ne]přátel!
Ode dne zrození je ti urče/no vlád/nout [v po]svát/ném [les]ku: *
zplodil jsem tě ja/ko ro/su [před] ji[třen]kou."'
      expected = 'Hospodin řekl mému Pánu:
\guillemotright Seď po mé pravici,
dokud nepoložím tvé nepřátele za podnož tvým nohám.\guillemotleft '+'
Žezlo moci ti podává Hospodin ze Siónu:
\guillemotright Panuj uprostřed svých nepřátel!
Ode dne zrození je ti určeno vládnout v posvátném lesku:
zplodil jsem tě jako rosu před jitřenkou.\guillemotleft '
      psalm = @reader.read_str(psalm_text)
      @outputter.process_psalm(psalm, {
        :quote => :guillemets
      }).should eq expected
    end

    it 'marks strophe ends' do
      psalm_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:

Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
      expected = 'Laudáte Dóminum, omnes Gentes:
laudáte eum, omnes pópuli:\\
Quóniam confirmáta est super nos misericórdia ejus:
et véritas Dómini manet in ætérnum.'
      psalm = @reader.read_str(psalm_text)
      @outputter.process_psalm(psalm, {
        :strophes => {
          :end_marks => false,
          :paragraph_space => true,
        },
      }).should eq expected
    end

    it 'marks strophe ends (more real-life example with simple verse formatting)' do
      psalm_text = "Psalmus 116.

Lau/dá/te Dó/mi/num, [om]nes [Gen]tes: *
lau/dá/te e/um, [om]nes [pó]pu/li:

Quóniam confirmáta est super nos mi/se/ri[cór]di/a [e]jus: *
et véritas Dó/mi/ni ma/net [in] æ[tér]num."
      expected = 'Laudáte Dóminum, omnes Gentes:
laudáte eum, omnes pópuli:\\

Quóniam confirmáta est super nos misericórdia ejus:
et véritas Dómini manet in ætérnum.'
      psalm = @reader.read_str(psalm_text)
      @outputter.process_psalm(psalm, {
        :strophes => {
          :end_marks => false,
          :paragraph_space => true,
        },
        :verses => {
          :paragraphify => true
        },
      }).should eq expected
    end
  end
end
