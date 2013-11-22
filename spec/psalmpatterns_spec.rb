# -*- coding: utf-8 -*-

require 'spec_helper'

describe Pslm::PsalmPatterns do

  before :each do
    # minimal example
    @patterns_i = Pslm::PsalmPatterns.new({'I' => [[2, 0], [1, 2]]})

    # minimal example of a tone with two differences differing in preparatory syllables
    @patterns_iv = Pslm::PsalmPatterns.from_yaml('IV: [ [1, 2], [1, {g: 0, E: 3}] ]')
  end

  it 'is initialized by providing some data' do
    Pslm::PsalmPatterns.new({'I' => [[2, 0], [1, 2]]}).should be_an_instance_of Pslm::PsalmPatterns
  end

  it 'may be loaded from yaml' do
    yaml_data = 'I: [[2, 0], [1, 2]]'
    Pslm::PsalmPatterns.from_yaml(yaml_data).should be_an_instance_of Pslm::PsalmPatterns
  end

  it 'returns tone data' do
    @patterns_i.tone_data('I', 'a').should eq [[2, 0], [1, 2]]
  end

  it 'raises ToneError on an unknown tone' do
    expect do
      @patterns_i.tone_data('XX', 'q')
    end.to raise_error Pslm::PsalmPatterns::ToneError
  end

  it 'converts tone data to a more programmer-readable structure' do
    @patterns_i.describe_tone_data([[1, 2], [1, 0]]).should eq([
        {:accents => 1, :preparatory => 2},
        {:accents => 1, :preparatory => 0}
    ])
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

  it 'works when loaded from the default data file' do
    Pslm::PsalmPatterns.default.tone_data('III', 'g2').should eq [[2, 0], [1, 3]]
  end

end