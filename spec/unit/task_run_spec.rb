require 'spec_helper'

describe 'Serially::TaskRun' do

  context 'creating' do
    it 'should fail if mandatory fields are not present' do
      task = Serially::TaskRun.new
      task.should_not be_valid

      task.item_class = SimpleClass.to_s
      task.should_not be_valid

      task.item_id = '126'
      task.should_not be_valid

      task.task_name = 'validate'
      task.should be_valid
    end
    it 'should fail if item_id exists already' do
      create_args = {item_class: SimpleClass.to_s, item_id: '123', status: 1, task_name: 'validate', task_order: 0}
      task1 = create_task_run_from_hash(create_args)
      task1.should be_valid

      lambda { create_task_run_from_hash(create_args) }.should raise_error

      task2 = create_task_run_from_hash(create_args.merge({task_name: 'enrich', task_order: 1}))
      task2.should be_valid

      task3 = create_task_run_from_hash(create_args.merge({item_id: 124, task_order: 2}))
      task3.should be_valid
    end
  end
end