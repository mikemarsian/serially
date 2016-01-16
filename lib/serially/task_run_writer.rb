module Serially
  class TaskRunWriter

    # called by TaskRunner, after each task and its error handler have finished running
    def update(task, instance, success, msg, result_obj, error_handled)
      TaskRun.write_task_run(task, instance.instance_id, success, msg, result_obj, error_handled)
    end

  end
end