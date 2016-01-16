require 'spec_helper'

describe 'Simple class that includes Serially' do
  let(:simple) { SimpleClass.new }

  it 'should contain class methods included from Serially' do
    simple.class.should respond_to(:serially)
  end

  context 'instance' do
    it 'should contain instance methods included from Serially' do
      simple.should respond_to(:serially)
      simple.serially.should respond_to(:start!)
    end
  end

end