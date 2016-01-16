require 'active_record'

module Serially
  class TaskRun < ActiveRecord::Base
    enum status: { pending: 0, started: 1, started_async: 2, finished_ok: 3, finished_error: 4 }
    serialize :result_object

    self.table_name = 'serially_task_runs'

    validates :item_class, :item_id, :task_name, presence: true
    validates :task_name, uniqueness: { scope: [:item_class, :item_id] }

    scope :finished, -> { where(status: finished_statuses) }

    def self.finished_statuses
      [TaskRun.statuses[:finished_ok], TaskRun.statuses[:finished_error]]
    end

    def finished?
      finished_ok? || finished_error?
    end

    def self.write_task_run(task, item_id, success, result_msg, result_obj, error_handled)
      task_run = TaskRun.where(item_class: task.klass, item_id: item_id, task_name: task.name).first_or_initialize
      if task_run.finished?
        Resque.logger.warn("Serially: task '#{task.name}' for #{task.klass}/#{item_id} finished already, not saving this task run")
        false
      else
        saved = task_run.tap {|t|
          t.task_order = task.task_order
          t.status = success ? TaskRun.statuses[:finished_ok] : TaskRun.statuses[:finished_error]
          t.result_message = result_msg
          t.result_object = result_obj
          t.error_handled = error_handled
          t.finished_at = DateTime.now
        }.save
        saved
      end
    end
  end
end