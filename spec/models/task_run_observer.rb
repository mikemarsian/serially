require 'spec_helper'

class TaskRunObserver
  def initialize
    @updates = {}
  end

  def update(task, item_id, success, msg)
    @updates[task.name] = {task: task, item_id: item_id, status: success, message: msg}
  end

  attr_accessor :updates

  def status(task_name)
    @updates[task_name].try(:fetch, :status, nil)
  end

  def message(task_name)
    @updates[task_name].try(:fetch, :message, nil)
  end

  def item_id(task_name)
    @updates[task_name].try(:fetch, :item_id, nil)
  end
end