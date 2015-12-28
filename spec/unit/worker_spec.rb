require 'spec_helper'

describe 'Serially::Worker' do
  context '::enqueue' do
    it 'should enque' do
      Serially::Worker.enqueue(SimpleModel, 12)
      resque_jobs = Resque.peek(Serially::Worker.queue, 0, 10)
      resque_jobs.should be_present
      resque_jobs.count.should == 1
      resque_jobs.first['class'].should == Serially::Worker.to_s
      resque_jobs.first['args'].should == [SimpleModel.to_s, 12]
    end
  end

  context '::enqueue_batch' do
    it 'should enqueue_batch'
  end
end