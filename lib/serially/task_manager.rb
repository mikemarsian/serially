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
      @tasks = []
    end

    def add_task(task_name, options = {})
      # allow reloading a task
      @tasks.delete(task_name) if @tasks.include?(task_name)
      @tasks << Serially::Task.new(task_name, @klass, self, @options)
    end
  end
end