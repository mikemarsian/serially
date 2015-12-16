module Serially
  class Base
    def initialize(task_manager)
      @task_manager = task_manager
    end

    # DSL
    def task(name, options = {})
      @task_manager.add_task(name, options)
    end
  end
end