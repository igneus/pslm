# -*- coding: utf-8 -*-

describe "the Ruby language" do

  # two syntax features I don't use often and never remember
  # how it really works
  describe "splatting in the argument list" do
    def foo(a, b, c, d)
      return [d, c]
    end

    def bar(*args)
      foo(0,9,*args)
    end

    it 'works as I expect' do
      foo(1,2,*[3,4]).should eq [4, 3]
    end

    it 'works as I expect 2' do
      bar(3,4).should eq [4, 3]
    end
  end
end
