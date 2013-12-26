# -*- coding: utf-8 -*-

require 'spec_helper'
require 'stringio'

describe JoinedInput do
  describe '#gets' do
    it 'joins two StringIOs' do
      s1 = StringIO.new 'abc'
      s2 = StringIO.new 'def'
      joined = JoinedInput.new s1, s2

      joined.gets.should eq "abc\n"
      joined.gets.should eq "def\n"
      joined.gets.should be_nil
    end

    it 'handles newlines correctly' do
      s1 = StringIO.new 'hi'
      s2 = StringIO.new "\nhey"
      joined = JoinedInput.new s1, s2

      joined.gets.should eq "hi\n"
      joined.gets.should eq "\n"
      joined.gets.should eq "hey\n"
      joined.gets.should be_nil
    end
  end

  describe '#read' do
    it 'joins two StringIOs' do
      s1 = StringIO.new 'abc'
      s2 = StringIO.new 'def'
      joined = JoinedInput.new s1, s2

      joined.read.should eq "abc\ndef"
    end
  end
end