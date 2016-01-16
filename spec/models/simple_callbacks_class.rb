require 'spec_helper'

class SimpleCallbacksClass
  include Serially

  attr_accessor :simple_key, :called
  def initialize(key)
    @simple_key = key
    @called = []
  end

  def instance_id
    @simple_key
  end

  serially do
    task :do_step1, on_error: :step1_error
    task :do_step2, on_error: :last_steps_error do |instance|
      instance.called << :do_step2
      puts 'Doing step 2'
      [false, 'step 2 failed', {run_date: Date.today}]
    end
    task :do_step3, on_error: :last_steps_error
    task :do_step4 do |instance|
      true
    end
  end

  def do_step1
    puts 'Doing Step1'
    called << :do_step1
    [true, 'Step 1 completed']
  end

  def step1_error(result_msg, result_object)
    called << :step1_error
    puts 'Step 1 is crucial, stopping!'
    false
  end

  def do_step3
    called << :do_step3
    raise RuntimeError('Unexpected')
  end

  def last_steps_error(result_msg, result_object)
    called << :last_steps_error
    if result_object.is_a?(Hash) && result_object[:run_date] == Date.today
      true # continue to next step
    else
      false # stop task run chain
    end
  end


end