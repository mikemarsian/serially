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
end