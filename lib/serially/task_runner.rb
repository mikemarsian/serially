require 'observer'

module Serially
  class TaskRunner
    include Observable

    def initialize(task_run_observer = nil)
      add_observer(task_run_observer) if task_run_observer
    end

    def run!(item_class, item_id = nil)
      last_run = []
      instance = item_id.blank? ? item_class.send(:create_instance) : item_class.send(:create_instance, item_id)
      Serially::TaskManager[item_class].each do |task|
        # if task.async?
        #   started_async_task = SerialTasksManager.begin_task(task)
        #   # if started async task successfully, exit the loop, otherwise go to next task
        #   break if started_async_task
        # else
        #started_async_task = false

        success, msg, result_obj = task.run!(instance)
        error_handled = task.on_error!(instance, msg, result_obj) if !success
        last_run = [task, success, msg, result_obj]

        # write result log to DB
        changed
        notify_observers(task, instance, success, msg, result_obj, error_handled)
        # if task didn't complete successfully, and error handler didn't return true, exit
        break if !success && !error_handled
      end
      # if started_async_task
      #   msg = "SerialTasksManager: started async task for #{item_class}/#{item_id}. Worker is exiting..."
      # else
      #   msg = "SerialTasksManager: no available tasks found for #{item_class}/#{item_id}. Worker is exiting..."
      # end

      # If we are here, it means that no more tasks were found
      success = last_run[1]
      msg = success ? "Serially: finished all tasks for #{item_class}/#{item_id}. Serially::Job is stopping..." :
                      "Serially: task '#{last_run[0]}' for #{item_class}/#{item_id} finished with success: #{last_run[1]}, message: #{last_run[2]}"
      msg
    end
  end
end
