require_relative 'spec/active_record_helper'

class SimpleClass
      include Serially

      serially do
        task :enrich
        task :validate
        task :refund
        task :archive
      end
end

class SimpleSubClass < SimpleClass
  include Serially

  serially do
    task :zip
    task :send
    task :acknowledge
  end
end

class SimpleModel < ActiveRecord::Base
  include Serially

  self.table_name =  'simple_items'

  serially do
    task :model_step1
    task :model_step2
    task :model_step3
  end
end

def create_simple
    simple = SimpleClass.new
    simple
end

def create_sub
    simple = SimpleSubClass.new
    simple
end

def create_model
    simple = SimpleModel.create(title: 'IAmSimple')
    simple
end