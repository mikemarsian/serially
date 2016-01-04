require 'spec_helper'

describe 'Class with serially options' do
  let(:simple) { SimpleOptionsClass.new }

  context 'in_queue' do
    it 'should enqueue to the right queue' do
      simple.serially.start!
      resque_jobs = Resque.peek('my_queue', 0, 10)
      resque_jobs.should be_present
      resque_jobs.count.should == 1
      resque_jobs.first['class'].should == Serially::Job.to_s
      resque_jobs.first['args'].should == [SimpleOptionsClass.to_s, simple.instance_id]
    end
    it 'should not enqueue to the default queue' do
      simple.serially.start!
      resque_jobs = Resque.peek(Serially::Options.default_queue, 0, 10)
      resque_jobs.should be_blank
    end
  end
end