require 'spec_helper'

describe 'Simple Class with instance_id' do
  let(:simple) { SimpleInstanceId.new('IamKey') }
  let(:complex_args) { ['IamKey1', 'IamKey2', 333] }
  let(:complex) { ComplexInstanceId.new(*complex_args) }

  describe 'SimpleInstanceId' do
    it 'start! should queue job with the right instance_id params' do
      Resque.should_receive(:enqueue).with(Serially::Job, SimpleInstanceId.to_s, 'IamKey')
      simple.serially.start!
    end
    it 'create_instance should call the right initialize' do
      SimpleInstanceId.should_receive(:new).with('IamKey')
      Serially::Job.perform(SimpleInstanceId, 'IamKey')
    end
    context 'job' do
      it 'should not write anything to DB, since SimpleInstanceId is not ActiveRecord model' do
        Serially::Job.perform(SimpleInstanceId.to_s, 123)
        Serially::TaskRun.count.should == 0
      end
    end
  end

  describe 'ComplexInstanceId' do
    it 'start! should queue job with the right instance_id params' do
      Resque.should_receive(:enqueue).with(Serially::Job, ComplexInstanceId.to_s, ['IamKey1', 'IamKey2', 333])
      complex.serially.start!
    end
    it 'create_instance should call the right initialize' do
      ComplexInstanceId.should_receive(:new).with('IamKey1', 'IamKey2', 333)
      Serially::Job.perform(ComplexInstanceId, ['IamKey1', 'IamKey2', 333])
    end
    context 'job' do
      it 'should not write anything to DB, since ComplexInstanceId is not ActiveRecord model' do
        Serially::Job.perform(ComplexInstanceId.to_s, complex_args)
        Serially::TaskRun.count.should == 0
      end
    end
  end
end