require 'active_support/ordered_hash'

module Serially
  class TaskManager

    # the following two methods provide the storage of all task managers
    def self.[](klass)
      (@task_managers ||= {})[klass.to_s]
    end

    def self.[]=(klass, task_manager)
      (@task_managers ||= {})[klass.to_s] = task_manager
    end

    attr_accessor :tasks

    def initialize(klass, options = {})
      @klass = klass
      @options = options
      @tasks = ActiveSupport::OrderedHash.new
    end

    def add_task(task_name, task_options,  &block)
      # allow reloading a task
      raise Serially::ConfigurationError.new("Task #{task_name} is already defined in class #{@klass}") if @tasks.include?(task_name)
      raise Serially::ConfigurationError.new("Task name #{task_name} defined in class #{@klass} is not a symbol") if !task_name.is_a?(Symbol)
      @tasks[task_name] = Serially::Task.new(task_name, @klass, self, task_options, &block)
    end

    def next_task(task)
      index = @tasks.values.index(task)
      if index
        @tasks.values.at(index + 1) # returns nil if index + 1 <= @tasks.length
      else
        nil
      end
    end
  end
end