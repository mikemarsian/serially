require 'spec_helper'

describe 'Simple class that includes Serially' do
  let(:simple) { SimpleClass.new }
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
  end

  context 'task runner' do
    it 'should run all tasks till the first task that returns false' do
      runner.run!(SimpleClass, nil)
      observer.status(:enrich).should == true
      observer.message(:enrich).should == 'Enriched just fine'

      observer.status(:validate).should == true
      observer.message(:validate).should == ''

      observer.status(:refund).should == false
      observer.message(:refund).should == ''
    end
    it 'should not run any task after the first task that returned false' do
      runner.run!(SimpleClass, nil)
      observer.status(:archive).should be_blank
      observer.status(:complete).should be_blank
    end
  end
end