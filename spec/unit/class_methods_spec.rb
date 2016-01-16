require 'spec_helper'

describe 'Class methods' do
  let(:simple) { SimpleClass.new }
  let(:simple_model) { SimpleModel.create(title: 'IamSimpleModel') }
  let(:simple_override) { SimpleModelOverride.create(title: 'IamSimpleModelOverride') }
  context '::create_instance' do
    context 'default implementation used' do
      context 'simple ruby class' do
        it 'should create new object for plain ruby class' do
          SimpleClass.create_instance.should be_instance_of(SimpleClass)
        end

        it 'when not passing any arguments, should create instance using new' do
          instance = SimpleClass.create_instance
          instance.should be_instance_of(SimpleClass)
          instance.should_not == simple_model
        end

        it 'when passing invalid params, should raise ArgumentError' do
          lambda { SimpleClass.create_instance(12) }.should raise_error(Serially::ArgumentError)
        end
      end

      context 'ActiveRecord model' do
        it 'when passing id, should create identical entity' do
          instance = SimpleModel.create_instance(simple_model.id)
          instance.should be_instance_of(SimpleModel)
          instance.should == simple_model
        end

        it 'when passing id with correct params, should create identical entity' do
          instance = SimpleModel.create_instance(id: simple_model.id, title: simple_model.title)
          instance.should be_instance_of(SimpleModel)
          instance.should == simple_model
        end

        it 'when passing incorrect params, should return nil' do
          lambda{ SimpleModel.create_instance(id: simple_model.id, title: 'Kuku') }.should raise_error(Serially::ArgumentError)
        end

        it 'when passing invalid params, should raise ArgumentError' do
          lambda { SimpleModel.create_instance(simple_model.id, 'Kuku') }.should raise_error(Serially::ArgumentError)
        end
      end

    end

    context 'override provided' do
      it 'should create identical entity' do
        created_instance = SimpleModelOverride.create_instance(simple_override.id)
        created_instance.should == simple_override
        created_instance.description.should == 'IamClone'
      end
    end
  end

  context '::start_batch!' do
    context 'for simple class' do
      let(:ids) { %w(key1 key2 key3) }
      it 'should be available on any class that includes Serially' do
        SimpleClass.should respond_to(:start_batch!)
        SimpleModel.should respond_to(:start_batch!)
      end
      it 'should schedule jobs as the number of ids passed' do
        SimpleInstanceId.start_batch!(ids)

        resque_jobs = Resque.peek(Serially::Job.queue, 0, 10)
        resque_jobs.count.should == ids.count
        resque_jobs.first['class'].should == Serially::Job.to_s
        resque_jobs.map{|h| h['args'][1]}.should include(*ids)
      end
    end
    context 'for model class' do
      let(:ids) { [SimpleModel.create(title: 'A').id, SimpleModel.create(title: 'B').id, SimpleModel.create(title: 'C').id] }
      before(:all) { Resque.inline = true }
      after(:all) { Resque.inline = false }
      it 'should create task runs as expected' do
        SimpleModel.start_batch!(ids)
        Serially::TaskRun.count.should == 9 # 3 instances, 3 task runs for each
        Serially::TaskRun.finished_error.count.should == 3
        Serially::TaskRun.finished_ok.count.should == 6
        Serially::TaskRun.where(item_id: ids.first).count.should == 3
      end
    end
  end
end