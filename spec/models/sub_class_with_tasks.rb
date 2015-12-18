require 'spec_helper'

class SubClassWithTasks < SimpleClass
  include Serially

  serially do
    task :zip
    task :send
    task :acknowledge
  end
end