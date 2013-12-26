# -*- coding: utf-8 -*-

# "joins" several input streams, so that #gets behaves as if they were
# a single stream
class JoinedInput

  # accepts any number of open IOs
  def initialize(*ins)
    @streams = ins
  end

  def gets
    if @streams.empty? then
      return nil
    end

    l = @streams.first.gets
    if l == nil
      @streams.shift
      return gets
    end

    unless l.end_with? "\n"
      l += "\n"
    end

    return l
  end

  def read
    @streams.collect {|s| s.read }.join "\n"
  end

  def close
    @streams.each {|s| s.close }
    @streams = []
  end

  def closed?
    @streams.empty?
  end
end
