module Serially
  class TaskRunner
    # called from within SeriallyWorker
    def self.get_next_task(item_class, item_id)
      task = Serially::Task.waiting(item_class, item_id).first
      task
    end

    # for synchronous tasks, such as ocr
    def self.perform_task(task)

    end
  end
end