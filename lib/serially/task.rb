module Serially
  class Task

    attr_accessor :name, :task_order, :klass, :options, :run_block

    def initialize(task_name, task_order, options, task_manager, &run_block)
      @name = task_name.to_sym
      @task_order = task_order
      @klass = task_manager.klass
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

    # <i>instance</i> - instance on which the task callback should be run
    def run!(instance)
      if instance
        if !@run_block && !instance.respond_to?(@name)
          raise Serially::ConfigurationError.new("Serially task #{@name} in class #{@klass} doesn't have an implementation method or a block to run")
        end
        begin
          status, msg, result_obj = @run_block ? @run_block.call(instance) : instance.send(@name)
        rescue StandardError => exc
          return [false, "Serially: task '#{@name}' raised exception: #{exc.message}", exc]
        end
      else
        return [false, "Serially: instance couldn't be created, task '#{@name}'' not started"]
      end
      # returns true (unless status == nil/false/[]), '' (unless msg is a not empty string) and result_obj, which might be nil
      # if task doesn't return it
      [status.present?, msg.to_s, result_obj]
    end
    
    # <i>instance</i> - instance on which the error handler should be run
    # <i>result_msg</i> - result message string, returned by the task callback. Can be nil, if no string was returned by the task
    # <i>result_obj</i> - result object, returned by the task callback. Can be nil, if no object was returned by the task
    def on_error!(instance, result_msg, result_obj)
      if options[:on_error]
        if !klass.method_defined?(options[:on_error])
          raise Serially::ConfigurationError.new("Serially: error handler #{options[:on_error]} not found for task #{self.name}")
        end

        begin
          status = instance.send(options[:on_error], result_msg, result_obj)
        rescue StandardError => exc
          Resque.logger.error("Serially: error handler for task '#{@name}' raised exception: #{exc.message}")
          status = false
        end
        status
      end
    end

  end

end
