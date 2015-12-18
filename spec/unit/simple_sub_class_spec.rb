require 'spec_helper'

describe 'Simple sub-class' do
  let(:sub) { SimpleSubClass.new }

  context 'instance' do
    it 'should contain only tasks of his parent' do
      sub.serially.tasks.map(&:name).should == [:enrich, :validate, :refund, :archive]
    end
  end
end