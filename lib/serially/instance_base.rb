module Serially
  class InstanceBase
    extend Forwardable

    def initialize(instance)
      @instance = instance
      @task_manager = Serially::TaskManager[instance.class]
    end

    # delegate instance methods to task_manager
    def_delegator :@task_manager, :tasks

    def start!
      Serially::Job.enqueue(@instance.class, @instance.instance_id)
    end

    def task_runs
      raise NotSupportedError.new('Serially: task_runs query is supported only for ActiveRecord classes') unless @instance.class.is_active_record?
      Serially::TaskRun.where(item_class: @instance.class.to_s, item_id: @instance.id).order('task_order ASC')
    end


  end
end