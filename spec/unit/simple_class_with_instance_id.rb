require 'spec_helper'

describe 'Simple Class with instance_id' do
  let(:simple) { SimpleInstanceId.new('IamKey') }
  let(:complex_args) { ['IamKey1', 'IamKey2', 333] }
  let(:complex) { ComplexInstanceId.new(*complex_args) }
  let(:observer) { TaskRunObserver.new }
  let(:runner) { Serially::TaskRunner.new(observer) }

  describe 'SimpleInstanceId' do
    it 'start! should queue job with the right instance_id params' do
      Resque.should_receive(:enqueue).with(Serially::Job, SimpleInstanceId.to_s, 'IamKey')
      simple.serially.start!
    end
    it 'create_instance should call the right initialize' do
      SimpleInstanceId.should_receive(:new).with('IamKey')
      Serially::Job.perform(SimpleInstanceId, 'IamKey')
    end

    context 'task runner' do
      it 'should run all tasks till the first task that returns false' do
        result = runner.run!(SimpleInstanceId, 'IamKey')
        observer.status(:enrich).should == true
        observer.message(:enrich).should == 'Enriched just fine'
        observer.item_id(:enrich).should == nil

        observer.status(:validate).should == true
        observer.message(:validate).should == ''

        observer.status(:refund).should == false
        observer.message(:refund).should == 'failed'
        observer.result_object(:refund).should == {reason: 'external api', date: Date.today}

        result.should include("Serially: task 'refund' for SimpleClass/ finished with success: false, message: ")
      end
      it 'should not run any task after the first task that returned false' do
        runner.run!(SimpleClass, 'IamKey')
        observer.status(:archive).should be_blank
        observer.status(:complete).should be_blank
      end
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