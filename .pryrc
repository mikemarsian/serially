class SimpleClass
      include Serially

      serially do
        task :enrich
        task :validate
        task :refund
        task :archive
      end
end
def create_simple
    simple = SimpleClass.new
    simple
end