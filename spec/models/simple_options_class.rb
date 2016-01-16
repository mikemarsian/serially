require 'spec_helper'

class SimpleOptionsClass
  include Serially

  serially in_queue: 'my_queue' do
    task :do_this do |instance|
      puts "Doing this"
      true
    end
    task :do_that do |instance|
      puts "Doing that"
      true
    end
  end

  attr_accessor :simple_key
  def initialize(key)
    @simple_key = key
  end

  def instance_id
    @simple_key
  end
end