class SimpleInstanceId < SimpleClass
  attr_accessor :simple_key
  def initialize(key)
    @simple_key = key
  end

  def instance_id
    @simple_key
  end
end

class ComplexInstanceId < SimpleClass
  attr_accessor :key1
  attr_accessor :key2
  attr_accessor :key3

  def initialize(key1, key2, key3)
    @key1 = key1
    @key2 = key2
    @key3 = key3
  end

  def instance_id
    [@key1, @key2, @key3]
  end
end