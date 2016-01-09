require './spec/active_record_helper'

class SimpleModel < ActiveRecord::Base
  include Serially

  self.table_name =  'simple_items'

  serially do
    task :model_step1 do |instance|
      true
    end
    task :model_step2 do |instance|
      ["OK", 'step 2 finished ok']
    end
    task :model_step3
  end

  def model_step3
    [false, 'step 3 failed']
  end
end