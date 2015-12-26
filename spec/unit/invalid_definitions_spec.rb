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
      }.should_not raise_error(Serially::ConfigurationError)
    end
    it 'should raise ConfigurationError when task runs' do
      lambda {
        class WithoutMethod
          include Serially

          serially do
            task :do_this
          end
        end
        WithoutMethod.new.serially.tasks[:do_this].run!
      }.should raise_error(Serially::ConfigurationError)
    end
  end
end