require 'spec_helper'

describe 'Instance methods' do
  let(:simple) { SimpleClass.new }
  let(:simple_model) { SimpleModel.create(title: 'IamSimpleModel') }
  let(:simple_override) { SimpleModelOverride.create(title: 'IamSimpleModelOverride') }
  before(:each) do
    Serially::TaskRun.delete_all
  end
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

    context '#task_runs' do
      before(:all) { Resque.inline = true }
      after(:all) { Resque.inline = false }

      it 'should raise exception for class that is not ActiveRecord' do
        lambda { simple.serially.task_runs }.should raise_error(Serially::NotSupportedError)
      end
      it 'should return empty array for instance that did not call start!' do
        simple_model.serially.task_runs.should be_kind_of(ActiveRecord::Relation)
        simple_model.serially.task_runs.all.should == []
      end
      it 'should return relation of all task_runs related to current instance' do
        simple_model.serially.start!

        task_runs = simple_model.serially.task_runs
        task_runs.should be_kind_of(ActiveRecord::Relation)
        task_runs.count.should == 3
      end

      it 'should returned task_runs ordered by task_order ASC ' do
        simple_model.serially.start!
        task_runs = simple_model.serially.task_runs
        task_runs.first.should == Serially::TaskRun.where(item_class: SimpleModel.to_s, item_id: simple_model.id).order("task_order ASC").first
        task_runs.last.should == Serially::TaskRun.where(item_class: SimpleModel.to_s, item_id: simple_model.id).order("task_order ASC").last
      end

      it 'should respond to the usual Relation methods' do
        simple_model.serially.start!
        task_runs = simple_model.serially.task_runs

        task_runs.first.task_name.should == 'model_step1'
        task_runs.last.task_name.should == 'model_step3'
      end
      it 'should respond to finished, pending' do
        simple_model.serially.start!
        task_runs = simple_model.serially.task_runs

        task_runs.finished.count.should == 3
        task_runs.finished_error.count.should == 1
      end
    end
  end
end