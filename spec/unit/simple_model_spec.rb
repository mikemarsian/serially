require 'spec_helper'

describe 'Simple ActiveRecord model that includes Serially' do
  let(:simple) { SimpleModel.create(title: 'IamSimpleModel') }

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
end
