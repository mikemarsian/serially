require 'spec_helper'

describe 'Invalid definitions' do

  context 'same task is defined twice' do
    it 'should raise ConfigurationError' do
      lambda {
        class SameTaskTwiceClass
          include Serially

          serially do
            task :enrich
            task :validate
            task :refund
            task :enrich
          end
        end
      }.should raise_error(Serially::ConfigurationError)
    end
  end

  context 'serially defined without a block' do
    it 'should raise ConfigurationError' do
      lambda {
        class WithoutBlock
          include Serially

          serially
        end
      }.should raise_error(Serially::ConfigurationError)
    end
  end

  context 'task without a method or a block' do
    it 'should not raise ConfigurationError when class is defined' do
      lambda {
        class WithoutMethod
          include Serially

          serially do
            task :do_this
          end
        end
      }.should_not raise_error
    end
    it 'should raise ConfigurationError when task runs' do
      lambda {
        class WithoutMethod
          include Serially

          serially do
            task :do_this
          end
        end
        instance = WithoutMethod.new
        instance.serially.tasks[:do_this].run!(instance)
      }.should raise_error(Serially::ConfigurationError)
    end
  end

  context 'invalid serially options' do
    it 'should raise ConfigurationError' do
      lambda {
        class InvalidSeriallyOptions
          include Serially

          serially kuku: true do
            task :do_something do |instance|
              true
            end
          end
        end
      }.should raise_error(Serially::ConfigurationError)
    end
  end

  context 'empty serially options' do
    it 'should raise ConfigurationError' do
      lambda {
        class InvalidSeriallyOptions
          include Serially

          serially in_queue: '' do
            task :do_something do |instance|
              true
            end
          end
        end
      }.should raise_error(Serially::ConfigurationError)

      lambda {
        class InvalidSeriallyOptions
          include Serially

          serially in_queue: nil do
            task :do_something do |instance|
              true
            end
          end
        end
      }.should raise_error(Serially::ConfigurationError)
    end
  end

  context 'on_error callback' do
    before(:all) { Resque.inline = true }
    after(:all) { Resque.inline = false }
    it 'should raise ConfigurationError if declared callback does not exist' do
      lambda {
        class InvalidCallbacks
          include Serially

          serially do
            task :do_something, on_error: :handle_error do |instance|
              false
            end
          end

          def initialize(key1)
            @key1 = key1
          end
          attr_accessor :key1
          def instance_id
            @key1
          end
        end
        InvalidCallbacks.new(:key11).serially.start!
      }.should raise_error(Serially::ConfigurationError)
    end
  end
end