require 'spec_helper'

class TaskRunObserver
  def initialize
    @updates = {}
  end

  def update(task, success, msg)
    @updates[task.name] = {task: task, status: success, message: msg}
  end

  attr_accessor :updates

  def status(task_name)
    @updates[task_name].try(:fetch, :status, nil)
  end

  def message(task_name)
    @updates[task_name].try(:fetch, :message, nil)
  end
end