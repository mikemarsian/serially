module Serially
  class Base
    def initialize(task_manager)
      @task_manager = task_manager
    end

    # DSL
    def task(name, task_options = {}, &block)
      @task_manager.add_task(name, task_options, &block)
    end
  end
end