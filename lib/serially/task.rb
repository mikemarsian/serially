module Serially
  class Task

    attr_accessor :name, :klass

    def initialize(task_name, klass, task_manager, options)
      @name = task_name.to_sym
      @klass = @klass
      @options = options
      @task_manager = task_manager
    end

    def ==(task)
      if task.is_a? Symbol
        name == task
      else
        name == task.name
      end
    end

    def <=>(task)
      if task.is_a? Symbol
        name <=> task
      else
        name <=> task.name
      end
    end

    def to_s
      name.to_s
    end

  end
end