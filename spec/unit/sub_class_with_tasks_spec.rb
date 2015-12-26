require 'spec_helper'

describe 'Sub-class that includes Serially' do
  let(:sub) { SubClassWithTasks.new }

  context 'instance' do
    it 'should contain only its own tasks' do
      sub.serially.tasks.keys.should == [:zip, :send, :acknowledge]
    end
  end
end