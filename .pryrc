class SimpleClass
      include Serially

      serially do
        task :enrich
        task :validate
        task :refund
        task :archive
      end
end

class SimpleSubClass < SimpleClass
  include Serially

  serially do
    task :zip
    task :send
    task :acknowledge
  end
end

def create_simple
    simple = SimpleClass.new
    simple
end

def create_sub
    simple = SimpleSubClass.new
    simple
end