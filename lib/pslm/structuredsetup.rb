# -*- coding: utf-8 -*-

require 'delegate'
require 'deep_merge/core' # only the environment non polluting core of deep_merge

# Nested Hashes; automatic creation of missing nodes
class StructuredSetup < SimpleDelegator

  def initialize(data={})
    @data = deep_copy data
    super(@data)
  end

  # set(:key1, :key2, :key3, value) ~ set[:key1][:key2][:key3] = value
  # setter with automatic creation of missing nodes
  def set(*args)
    value = args.pop
    last_key = args.pop

    hsh = get_create(args)
    hsh[last_key] = value
  end

  # getter with automatic creation of missing nodes
  def get(*keys)
    get_create(keys[0..-2])[keys[-1]]
  end

  # getter with default value
  def get_dv(*args)
    default = args.pop
    innermost = get_create(args[0..-2])
    unless innermost.has_key? args[-1] then
      innermost[args[-1]] = default
    end

    return innermost[args[-1]]
  end

  def dup
    deep_copy self
  end

  def update(s2)
    DeepMerge.deep_merge!(
      s2,
      @data,
      overwrite_arrays: true
    )
  end

  private

  # returns the innermost Hash
  def get_create(keys)
    keys = keys.dup
    hsh = @data
    while keys.size > 0 do
      key = keys.shift

      unless hsh.has_key? key
        hsh[key] = {}
      end

      unless hsh[key].is_a? Hash
        raise RuntimeError.new "Cannot set to key '#{key}': it's value is #{hsh[key].class}, not Hash. Keys were #{keys}"
      end

      hsh = hsh[key]
    end

    return hsh
  end

  def deep_copy(obj)
    Marshal.load(Marshal.dump(obj))
  end
end
