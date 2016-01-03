require 'spec_helper'

describe 'Simple ActiveRecord model that includes Serially' do
  let(:simple) { SimpleModel.create(title: 'IamSimpleModel') }
  let(:observer) { TaskRunObserver.new }
  let(:runner) { Serially::TaskRunner.new(observer) }

  it 'should contain class methods included from Serially' do
    simple.class.should respond_to(:serially)
  end

  context 'instance' do
    it 'should contain instance methods included from Serially' do
      simple.should respond_to(:serially)
      simple.serially.should respond_to(:start!)
    end

    it 'should contains all the tasks' do
      simple.serially.tasks.keys.should == [:model_step1, :model_step2, :model_step3]
    end

    context '#start!' do
      it 'should enqueue job with correct params' do
        simple.serially.start!
        resque_jobs = Resque.peek(Serially::Worker.queue, 0, 10)
        resque_jobs.should be_present
        resque_jobs.count.should == 1
        resque_jobs.first['class'].should == Serially::Worker.to_s
        resque_jobs.first['args'].should == [SimpleModel.to_s, simple.id]
      end
    end
  end

  context 'task runner' do
    it 'should run all tasks till the first task that returns false' do
      result = runner.run!(SimpleModel, simple.instance_id)
      observer.status(:model_step1).should == true
      observer.message(:model_step1).should == ''

      observer.status(:model_step2).should == true
      observer.message(:model_step2).should == 'step 2 finished ok'

      observer.status(:model_step3).should == false
      observer.message(:model_step3).should == 'step 3 failed'

      result.should include("Serially: task 'model_step3' for SimpleModel/#{simple.instance_id} finished with success: false, message: step 3 failed")
    end
  end

  context 'worker' do
    before(:each) do
      Serially::TaskRun.delete_all
    end

    context 'valid params' do
      it 'should write all finished task runs to DB' do
        item = SimpleModel.create(title: 'IamItem')
        Serially::Worker.perform(SimpleModel, item.instance_id)
        Serially::TaskRun.count.should == 3

        step1 = Serially::TaskRun.where(task_name: 'model_step1').first
        step1.task_order.should == 0
        step1.should be_finished_ok
        step1.finished_at.should_not be_blank
        step1.result_message.should == ''

        step2 = Serially::TaskRun.where(task_name: 'model_step2').first
        step2.task_order.should == 1
        step2.should be_finished_ok
        step2.finished_at.should_not be_blank
        step2.finished_at.should >= step1.finished_at
        step2.result_message.should == 'step 2 finished ok'

        step3 = Serially::TaskRun.where(task_name: 'model_step3').first
        step3.task_order.should == 2
        step3.should be_finished_error
        step3.finished_at.should_not be_blank
        step3.finished_at.should >= step2.finished_at
        step3.result_message.should == 'step 3 failed'
      end
    end

    context 'invalid params' do
      context 'when instance_id is invalid' do
        let(:invalid_id) { 888 }
        it 'should not write to db' do
          Serially::Worker.perform(SimpleModel.to_s, invalid_id)

          # since instance can't be created, only first task_run should be written to DB
          Serially::TaskRun.count.should == 1
          Serially::TaskRun.first.task_order.should == 0
          Serially::TaskRun.first.should be_finished_error
          Serially::TaskRun.first.finished_at.should_not be_blank
          Serially::TaskRun.first.result_message.should == "Serially: instance couldn't be created, task 'model_step1'' not started"
        end
      end
    end

  end
end
