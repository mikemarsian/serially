require 'spec_helper'

describe 'Serially::Task' do
  let(:simple) { SimpleClass.new }
  let(:easy) { EasyClass.new }
  context 'equality' do
    it 'tasks with identical names should be equal' do
      simple.serially.tasks[:enrich].should == :enrich
    end
    it 'tasks with identical names but different including class should not be equal' do
      simple.serially.tasks[:enrich].should == :enrich
      easy.serially.tasks[:enrich].should == :enrich
      simple.serially.tasks[:enrich].should_not == easy.serially.tasks[:enrich]
    end
  end
  context '#to_s' do
    it 'should return the name of the task' do
      simple.serially.tasks[:enrich].to_s.should == 'enrich'
    end
  end
  context '#run!' do
    context 'using instance method' do
      it 'should return true and message string when task returns true and provides message string' do
        status, msg = simple.serially.tasks[:enrich].run!
        status.should == true
        msg.should == 'Enriched just fine'
      end
      it 'should return true and empty message string when task returns some value other than null or false' do
        status, msg = simple.serially.tasks[:validate].run!
        status.should == true
        msg.should == ''
      end
      it 'should return false and empty message string when task returns false' do
        status, msg = simple.serially.tasks[:refund].run!
        status.should == false
        msg.should == ''
      end
      it 'should return false and a message with exception, if task raises exception' do
        status, msg = simple.serially.tasks[:complete].run!
        status.should == false
        msg.should include("Serially: task 'complete' raised exception: Unexpected failure")
      end
    end

    context 'using block' do
      it 'should return false and empty message if task returns nil' do
        status, msg = simple.serially.tasks[:archive].run!
        status.should == false
        msg.should == ''
      end
    end
  end
end