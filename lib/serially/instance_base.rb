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
      Serially::Worker.enqueue(@instance.class, get_instance_id(@instance))
    end

    def tasks
      @task_manager.tasks
    end

    private

    def get_instance_id(instance)
      instance_id = instance.respond_to?(:id) ? instance.id : instance.object_id
      instance_id
    end

  end
end