require 'active_record'

module Serially
  class TaskRun < ActiveRecord::Base
    enum status: { pending: 0, started: 1, started_async: 2, finished_ok: 3, finished_error: 4 }

    self.table_name = 'serially_task_runs'

    validates :item_class, :item_id, :task_name, presence: true
    validates :task_name, uniqueness: { scope: [:item_class, :item_id] }

    def self.create_from_hash!(args = {})
      task_run = TaskRun.new do |t|
        t.item_class = args[:item_class] if args[:item_class].present?
        t.item_id = args[:item_id] if args[:item_id].present?
        t.status = args[:status] if args[:status].present?
        t.task_name = args[:task_name] if args[:task_name].present?
      end
      task_run.save!
      task_run
    end

    def finished?
      finished_ok? || finished_error?
    end

    def self.write_task_run(task, item_id, success, msg)
      task_run = TaskRun.where(item_class: task.klass, item_id: item_id, task_name: task.name).first_or_initialize
      if task_run.finished?
        Resque.logger.warn("Serially: task '#{task.name}' for #{task.klass}/#{item_id} finished already, not saving this task run")
        false
      else
        saved = task_run.tap {|t|
          t.status = success ? TaskRun.statuses[:finished_ok] : TaskRun.statuses[:finished_error]
          t.result_message = msg
          t.finished_at = DateTime.now
        }.save
        saved
      end
    end
  end
end