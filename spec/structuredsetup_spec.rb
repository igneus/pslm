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
end