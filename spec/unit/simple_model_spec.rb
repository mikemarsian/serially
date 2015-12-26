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
      runner.run!(SimpleModel, simple.instance_id)
      observer.status(:model_step1).should == true
      observer.message(:model_step1).should == ''

      observer.status(:model_step2).should == true
      observer.message(:model_step2).should == 'step 2 finished ok'

      observer.status(:model_step3).should == false
      observer.message(:model_step3).should == 'step 3 failed'
    end
  end
end
