require 'spec_helper'

class SimpleClass
  include Serially

  serially do
    task :enrich
    task :validate
    task :refund
    task :archive
  end
end