# -*- coding: utf-8 -*-

require 'spec_helper'

describe Pslm::Psalm do
  
  Syllable = Pslm::Psalm::Syllable
  
  describe Syllable do
    
    it 'compares with == as expected' do
      Syllable.new('hi').should == Syllable.new('hi')
    end
  end
end