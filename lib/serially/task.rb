module Serially
  class Task

    attr_accessor :name, :klass

    def initialize(task_name, klass, task_manager, options, &run_block)
      @name = task_name.to_sym
      @klass = klass
      @options = options
      @run_block = run_block
      @task_manager = task_manager
    end

    def ==(task)
      if task.is_a? Symbol
        name == task
      else
        name == task.name && self.klass == task.klass
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

    # <i>args</i> - arguments needed to create an instance of your class. If you don't provide custom implementation for create_instance,
    # pass instance_id or hash of arguments,
    def run!(*args)
      instance = args[0].blank? ? instance = @klass.send(:create_instance) : @klass.send(:create_instance, *args)
      if instance
        if !@run_block && !instance.respond_to?(@name)
          raise Serially::ConfigurationError.new("Serially task #{@name} in class #{@klass} doesn't have an implementation method or a block to run")
        end
        begin
          status, msg = @run_block ? @run_block.call(instance) : instance.send(@name)
        rescue StandardError => exc
          return [false, "Serially: task '#{@name}' raised exception: #{exc.message}"]
        end
      else
        return [false, "Serially: instance couldn't be created, task '#{@name}'' not started"]
      end
      # returns true (unless status == nil/false/[]) and '' (unless msg is a not empty string)
      [status.present?, msg.to_s]
    end

  end
end