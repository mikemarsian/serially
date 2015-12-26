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
          instance = SimpleModel.create_instance(id: simple_model.id, title: 'Kuku')
          instance.should be_blank
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
end