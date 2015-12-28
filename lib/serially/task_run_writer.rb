module Serially
  class TaskRunWriter

    # called by TaskRunner, after each task has finished running
    def update(task, item_id, success, msg)
      TaskRun.write_task_run(task, item_id, success, msg)
    end

  end
end