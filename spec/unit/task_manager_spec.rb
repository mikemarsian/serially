require 'spec_helper'

describe 'Serially::TaskManager' do
  let(:simple) { SimpleClass.new }

  context '#each' do
    it 'returns next task, when it exists' do
      enumerator = Serially::TaskManager[SimpleClass].each
      enumerator.next.should == :enrich
      enumerator.next.should == :validate
    end
  end
end