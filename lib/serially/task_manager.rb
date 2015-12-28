module Serially
  class TaskManager

    # the following two methods provide the storage of all task managers
    def self.[](klass)
      (@task_managers ||= {})[klass.to_s]
    end

    def self.[]=(klass, task_manager)
      (@task_managers ||= {})[klass.to_s] = task_manager
    end

    attr_accessor :tasks, :options, :klass

    def initialize(klass, options = {})
      @klass = klass
      @options = options
      # Hash is ordered since Ruby 1.9
      @tasks = {}
    end

    def clone_for(new_klass)
      new_mgr = TaskManager.new(new_klass, self.options)
      self.each { |task| new_mgr.add_task(task.name, task.options, &task.run_block) }
      new_mgr
    end


    def add_task(task_name, task_options, &block)
      raise Serially::ConfigurationError.new("Task #{task_name} is already defined in class #{@klass}") if @tasks.include?(task_name)
      raise Serially::ConfigurationError.new("Task name #{task_name} defined in class #{@klass} is not a symbol") if !task_name.is_a?(Symbol)
      @tasks[task_name] = Serially::Task.new(task_name, task_options, self, &block)
    end

    # Allow iterating over tasks
    def each
      return enum_for(:each) unless block_given?  # return Enumerator

      @tasks.values.each do |task|
        yield task
      end
    end

  end
end