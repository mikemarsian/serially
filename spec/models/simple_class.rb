require 'spec_helper'

class SimpleClass
  include Serially

  serially do
    task :enrich
    task :validate
    task :refund
    task :archive do |simple|
      puts "Archiving #{simple.instance_id} failed"
      nil
    end
    task :complete
  end

  def enrich
    msg = "Enriched just fine"
    print_me(msg)
    [true, msg]
  end

  def validate
    print_me("Validated successfully")
    "Validated"
  end

  def refund
    print_me("Refunding failed")
    false
  end

  def complete
    print_me("Trying to complete")
    raise RuntimeError.new("Unexpected failure")
  end

  private

  def print_me(action)
    puts "#{action} #{self.instance_id}"
  end

end

class EasyClass
  include Serially

  serially do
    task :enrich
    task :validate
    task :email_for_review
  end
end