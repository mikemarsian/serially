require 'spec_helper'

class SingleTaskClass
  include Serially

  serially do
    task :do_just_this
  end

  def do_just_this
    puts "I'm just doing this"
    true
  end
end