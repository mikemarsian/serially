class CreateSeriallyTasks < ActiveRecord::Migration
  def change
    create_table :serially_tasks do |t|
      t.string  :item_class,          null: false
      t.integer :item_id,        null: false
      t.integer :task_number,        null: false
      t.string :task_name,        null: false
      t.integer  :status,         null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.text     :result_message
      t.timestamps null: false
    end

    add_index :serially_tasks, [:item_class, :item_id]
  end
end