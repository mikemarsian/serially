require 'spec_helper'

describe 'Simple sub-class' do
  let(:sub) { SimpleSubClass.new }

  context 'instance' do
    it 'should contain only tasks of his parent' do
      sub.serially.tasks.keys.should == [:enrich, :validate, :refund, :archive, :complete]
    end

  end

  context 'clone' do
    it 'should contain tasks with klass SimpleSubClass, not SimpleClass' do
      sub.serially.tasks[:enrich].klass.should == SimpleSubClass
    end

    it 'should contain tasks with identical to parent name, options, and run_block' do
      sub.serially.tasks.values.first.name.should == Serially::TaskManager[SimpleClass].tasks.values.first.name
      sub.serially.tasks[:enrich].options.should == Serially::TaskManager[SimpleClass].tasks[:enrich].options
      sub.serially.tasks[:enrich].run_block.should == Serially::TaskManager[SimpleClass].tasks[:enrich].run_block
    end
    it "should contain parents' serially options" do
      Serially::TaskManager[SimpleSubClass].options.should == Serially::TaskManager[SimpleClass].options
    end

  end

  context 'worker' do
    before(:each) do
      Serially::TaskRun.delete_all
    end
    it 'should not write anything to DB, since SimpleSubClass is not ActiveRecord model' do
      Serially::Worker.perform(SimpleSubClass, nil)
      Serially::TaskRun.count.should == 0
    end
  end
end