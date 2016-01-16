require 'spec_helper'

describe 'Simple class with callbacks' do
  let(:simple) { SimpleCallbacksClass.new('IamKey') }
  let(:observer) { TaskRunObserver.new }
  let(:runner) { Serially::TaskRunner.new(observer) }

  before(:each) do
    Serially::TaskRun.delete_all
  end

  context 'on_error' do
    before(:each) do
      runner.run!(SimpleCallbacksClass, 'IamKey')
    end
    it 'should not be called if task finished successfully' do
      observer.instance.called.should include(:do_step1)
      observer.instance.called.should_not include(:step1_error)
      observer.error_handled(:do_step1).should be_falsey
    end

    it 'should be called if task did not finish successfully' do
      observer.instance.called.should include(:do_step1, :do_step2, :last_steps_error)
      observer.error_handled(:do_step2).should == true
    end

    it 'next task after on_error should not be called if on_error returned true' do
      observer.instance.called.should include(:do_step3)
      observer.error_handled(:do_step3).should be_falsey
    end

    it 'next task after on_error should be called if on_error returned false' do
      observer.instance.called.should_not include(:do_step4)
      observer.error_handled(:do_step3).should be_falsey
    end
  end
end