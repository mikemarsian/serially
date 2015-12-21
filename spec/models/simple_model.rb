require 'spec_helper'
require 'active_record_helper'

class SimpleModel < ActiveRecord::Base
  include Serially

  self.table_name =  'simple_items'

  serially do
    task :model_step1
    task :model_step2
    task :model_step3
  end
end