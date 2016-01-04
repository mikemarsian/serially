require 'spec_helper'

describe 'Serially::Job' do
  context '::enqueue' do
    it 'should enque' do
      Serially::Job.enqueue(SimpleModel, 12)
      resque_jobs = Resque.peek(Serially::Job.queue, 0, 10)
      resque_jobs.should be_present
      resque_jobs.count.should == 1
      resque_jobs.first['class'].should == Serially::Job.to_s
      resque_jobs.first['args'].should == [SimpleModel.to_s, 12]
    end
  end
end