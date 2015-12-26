require 'spec_helper'

describe 'Instance methods' do
  let(:simple) { SimpleClass.new }
  let(:simple_model) { SimpleModel.create(title: 'IamSimpleModel') }
  let(:simple_override) { SimpleModelOverride.create(title: 'IamSimpleModelOverride') }
  context '#instance_id' do
    context 'no override provided' do
      it 'returns object_id for plain ruby class' do
        simple.instance_id.should == simple.object_id
      end
      it 'returns id for ActiveRecord model' do
        simple_model.instance_id.should == simple_model.id
      end
    end
    context 'override provided' do
      it 'returns the value provided by the overriding method' do
        simple_override.instance_id.should == simple_override.title.hash
      end
    end
  end

  context '#serially' do
    context '#tasks' do
      it 'should return all the tasks' do
        simple.serially.tasks.keys.should == [:enrich, :validate, :refund, :archive, :complete]
      end
    end

    context '#start!' do
      it 'should enqueue Serially::Worker job' do
        simple.serially.start!
        resque_jobs = Resque.peek(Serially::Worker.queue, 0, 10)
        resque_jobs.count.should == 1
        resque_jobs.first['class'].should == Serially::Worker.to_s
        resque_jobs.first['args'].should == [SimpleClass.to_s, simple.object_id]
      end

    end
  end
end