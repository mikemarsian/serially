require 'spec_helper'

describe 'Sub-class that includes Serially' do
  let(:sub) { SubClassWithTasks.new }
  let(:observer) { TaskRunObserver.new }
  let(:runner) { Serially::TaskRunner.new(observer) }

  context 'instance' do
    it 'should contain only its own tasks' do
      sub.serially.tasks.keys.should == [:zip, :send, :acknowledge]
    end
  end

  context 'task runner' do
    it 'should run all tasks till the first task that returns false' do
      result = runner.run!(SubClassWithTasks)
      observer.status(:zip).should == true
      observer.message(:zip).should == 'ok'

      observer.status(:send).should == false
      observer.message(:send).should == ''

      observer.status(:acknowledge).should be_blank

      result.should include("Serially: task 'send' for SubClassWithTasks/ finished with success: false, message: ")
    end
  end
end