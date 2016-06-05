# -*- coding: utf-8 -*-

require 'spec_helper'

describe Pslm::PsalmPatterns do

  before :each do
    # minimal example
    @patterns_i = Pslm::PsalmPatterns.new({'I' => [[2, 0], [1, 2]]})

    # minimal example of a tone with two differences differing in preparatory syllables
    @patterns_iv = Pslm::PsalmPatterns.from_yaml('IV: [ [1, 2], [1, {g: 0, E: 3}] ]')

    @patterns_per = Pslm::PsalmPatterns.from_yaml('per: [[1, 3], [1, 1]]')
  end

  describe "instance creation / initialization" do

    it 'is initialized by providing some data' do
      Pslm::PsalmPatterns.new({'I' => [[2, 0], [1, 2]]}).should be_an_instance_of Pslm::PsalmPatterns
    end

    it 'may be loaded from yaml' do
      yaml_data = 'I: [[2, 0], [1, 2]]'
      Pslm::PsalmPatterns.from_yaml(yaml_data).should be_an_instance_of Pslm::PsalmPatterns
    end

    it 'works when loaded from the default data file' do
      Pslm::PsalmPatterns.default.tone_data('III', 'g2').should eq [[2, 0], [1, 3]]
    end
  end

  describe "#tone_data" do

    it 'returns tone data' do
      @patterns_i.tone_data('I', 'a').should eq [[2, 0], [1, 2]]
    end

    it 'works for peregrinus' do
      @patterns_per.tone_data('per').should eq [[1, 3], [1, 1]]
    end

    it 'raises ToneError on an unknown tone' do
      expect do
        @patterns_i.tone_data('XX', 'q')
      end.to raise_error Pslm::PsalmPatterns::ToneError
    end

    it 'correctly resolves a meaningful difference' do
      @patterns_iv.tone_data('IV', 'g').should eq [[1,2], [1,0]]
    end

    it 'raises DifferenceError on an unknown difference for tones where differences are meaningful' do
      expect do
        @patterns_iv.tone_data('IV', 'Q')
      end.to raise_error Pslm::PsalmPatterns::DifferenceError
    end

    it 'never raises DifferenceError on an unknown difference for tones where differences are meaningless for the pattern' do
      @patterns_i.tone_data('I', 'z').should eq [[2, 0], [1, 2]]
      @patterns_i.tone_data('I', '$').should eq [[2, 0], [1, 2]]
    end

    it 'is case insensitive' do
      @patterns_iv.tone_data('IV', 'g').should eq [[1,2], [1,0]]
      @patterns_iv.tone_data('iv', 'G').should eq [[1,2], [1,0]]
    end
  end

  describe '#tone_data_by_str' do
    it 'works wit dot as separator' do
      @patterns_i.tone_data_by_str('I.a').should eq [[2, 0], [1, 2]]
    end

    it 'works wit space as separator' do
      @patterns_i.tone_data_by_str('I a').should eq [[2, 0], [1, 2]]
    end

    it 'works wit random characters as separator' do
      @patterns_i.tone_data_by_str('I#a').should eq [[2, 0], [1, 2]]
    end

    it 'works for tone without differences' do
      @patterns_per.tone_data_by_str('per').should eq [[1, 3], [1, 1]]
    end
  end

  describe "#describe_tone_data" do

    it 'converts tone data to a more programmer-readable structure' do
      @patterns_i.describe_tone_data([[1, 2], [1, 0]]).should eq([
          {:accents => 1, :preparatory => 2},
          {:accents => 1, :preparatory => 0}
      ])
    end
  end

  describe "#normalize_tone_str" do

    it 'handles a correct tone identifier correctly' do
      @patterns_i.normalize_tone_str('I.f').should eq ['I', 'f']
    end

    it 'handles a correct tone identifier with tone separated from difference by a space' do
      @patterns_i.normalize_tone_str('I f').should eq ['I', 'f']
    end

    it 'copes with a tone containing spaces' do
      @patterns_i.normalize_tone_str('IV alt.A').should eq ['IV alt', 'A']
    end

    it 'copes with a tone containing spaces - even if space is the tone-difference separator' do
      @patterns_i.normalize_tone_str('IV alt A').should eq ['IV alt', 'A']
    end
  end
end
