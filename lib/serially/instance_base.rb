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
      Serially::Worker.enqueue(@instance.class, @instance.instance_id)
    end

    private

  end
end