require 'active_record'
require_relative './../lib/generators/serially/install/templates/create_serially_tasks'

# switch the active database connection to an SQLite, in-memory database
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
# don't output all the migration activity
ActiveRecord::Migration.verbose = false

# execute the migration, creating a simple_table (dirty_items) and columns (body, email, name)
ActiveRecord::Schema.define(:version => 1) do
  create_table :simple_items do |t|
    t.string :title
    t.text :description
    t.integer :score
  end
end

# install generator migration
CreateSeriallyTasks.new.change