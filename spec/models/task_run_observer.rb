require 'spec_helper'

class TaskRunObserver
  def initialize
    @updates = {}
  end

  def update(task, instance, success, msg, result_obj, error_handled)
    @updates[task.name] = {task: task, item_id: instance.instance_id, status: success, message: msg, result_object: result_obj, error_handled: error_handled}
    @instance = instance
  end

  attr_accessor :updates, :instance

  def item_id(task_name)
    @updates[task_name].try(:fetch, :item_id, nil)
  end

  def status(task_name)
    @updates[task_name].try(:fetch, :status, nil)
  end

  def message(task_name)
    @updates[task_name].try(:fetch, :message, nil)
  end

  def result_object(task_name)
    @updates[task_name].try(:fetch, :result_object, nil)
  end

  def error_handled(task_name)
    @updates[task_name].try(:fetch, :error_handled, nil)
  end

end