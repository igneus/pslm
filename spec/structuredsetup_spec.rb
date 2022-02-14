# -*- coding: utf-8 -*-

require 'spec_helper'
require 'pslm/structuredsetup'

describe StructuredSetup do

  before :each do
    @empty = StructuredSetup.new
  end

  it 'is empty' do
    @empty.size.should eq 0
  end

  describe '#set' do
    it 'creates nested missing Hash' do
      @empty.set(:section, :item, :value)
      @empty.size.should eq 1
      @empty[:section].size.should eq 1
      @empty[:section][:item].should eq :value
    end

    it 'works for a single level, too' do
      @empty.set(:item, 7)
      @empty[:item].should eq 7
    end
  end

  describe '#get' do
    it 'gets a value from nested Hashes' do
      @empty.set(:section, :item, 7)
      @empty.get(:section, :item).should eq 7
    end

    it 'works for a single level, too' do
      @empty.set(:item, 7)
      @empty.get(:item).should eq 7
    end
  end

  describe '#get_dv' do
    it 'simply gets if the value is there' do
      @empty.set(:section, :item, 7)
      @empty.get_dv(:section, :item, 9).should eq 7
    end

    it 'gets default if the value is not there ...' do
      @empty.get_dv(:section, :item, 9).should eq 9
    end

    it '... and assigns it at the same time' do
      @empty.get(:section, :item).should eq nil

      @empty.get_dv(:section, :item, 9)
      @empty.get(:section, :item).should eq 9
    end
  end

  describe '#update' do
    it 'updates recursively' do
      setup = StructuredSetup.new({
        :elephant => {
          :ears => 'large',
          :eyes => 'rather small'
        },
        :giraffe => {
          :neck => 'very long',
        }
      })

      setup.update({:elephant => {:ears => 'very large', :tail => true}})
      setup[:elephant].should eq({:ears => 'very large', :eyes => 'rather small', :tail => true})
    end

    it 'does not attempt to merge arrays, overwrites them' do
      setup = described_class.new({key: [1, 2]})
      setup.update({key: [3]})

      expect(setup[:key]).to eq [3]
    end

    it 'preserves duplicate values in arrays' do
      setup = described_class.new({a: [1, 1]})
      setup.update({b: [2, 2]})

      expect(setup[:a]).to eq [1, 1]
      expect(setup[:b]).to eq [2, 2]
    end
  end
end
