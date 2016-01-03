class CreateSeriallyTaskRuns < ActiveRecord::Migration
  def change
    create_table :serially_task_runs do |t|
      t.string  :item_class,          null: false
      t.string :item_id,        null: false
      t.string :task_name,        null: false
      t.integer :task_order,      null: false
      t.integer  :status,         default: 0
      t.datetime :finished_at
      t.text     :result_message
      t.timestamps null: false
    end

    add_index :serially_task_runs, [:item_class, :item_id]
  end
end