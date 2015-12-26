require 'spec_helper'

class SimpleModelOverride < ActiveRecord::Base
  include Serially

  self.table_name =  'simple_items'

  serially do
    task :model_step1
    task :model_step2
    task :model_step3
  end

  def self.create_instance(id)
    instance = where(id: id).first
    instance.description = 'IamClone'
    instance
  end

  def instance_id
    self.title.hash
  end
end