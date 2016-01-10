require 'spec_helper'

class TaskRunObserver
  def initialize
    @updates = {}
  end

  def update(task, item_id, success, msg, result_obj)
    @updates[task.name] = {task: task, item_id: item_id, status: success, message: msg, result_object: result_obj}
  end

  attr_accessor :updates

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

end