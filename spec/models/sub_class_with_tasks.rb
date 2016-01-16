require 'spec_helper'

class SubClassWithTasks < SimpleClass
  include Serially

  serially do
    task :zip
    task :send do |instance|
      false
    end
    task :acknowledge do |instance|
      true
    end
  end

  def zip
    ["OK", "ok"]
  end

  attr_accessor :simple_key
  def initialize(key)
    @simple_key = key
  end

  def instance_id
    @simple_key
  end
end