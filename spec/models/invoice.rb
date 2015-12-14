require 'spec_helper'

class Invoice
  include Serially

  serially do
    task :enrich
    task :validate
    task :refund
    task :archive
  end
end