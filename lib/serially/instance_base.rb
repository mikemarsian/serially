module Serially
  class InstanceBase
    extend Forwardable

    def initialize(instance)
      @instance = instance
      @task_manager = Serially::TaskManager[instance.class]
    end

    # delegate instance methods to task_manager
    def_delegator :@task_manager, :tasks

  end
end