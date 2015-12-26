module Serially
  class TaskRunner
    # returns the next task in their order of definition
    def self.get_next_task(item_class, item_id, prev_task)
      task = nil
      task_manager = Serially::TaskManager[item_class]
      if task_manager
        task = task_manager.next_task(prev_task)
      end
      task
    end

    # for synchronous tasks, such as ocr
    def self.perform_task(task)
      #TODO implement
    rescue StandardError => exc
    ensure

    end
  end
end