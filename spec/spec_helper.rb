require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'resque'
require 'pry'
require 'database_cleaner'
require 'serially'


RSpec.configure do |config|

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # clean Resque before every top-level group
  config.before(:all) do
    Resque.redis.flushdb
  end

  # should syntax is more readable
  config.expect_with :rspec do |c|
    c.syntax = :should
  end
  config.mock_with :rspec do |c|
    c.syntax = :should
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end

end

# example model classes
Dir[File.dirname(__FILE__) + "/models/*.rb"].sort.each { |f| require File.expand_path(f) }

# **** helper methods ***

def create_task_run_from_hash(args = {})
  task_run = Serially::TaskRun.new do |t|
    t.item_class = args[:item_class] if args[:item_class].present?
    t.item_id = args[:item_id] if args[:item_id].present?
    t.status = args[:status] if args[:status].present?
    t.task_name = args[:task_name] if args[:task_name].present?
    t.task_order = args[:task_order] if args[:task_order].present?
  end
  task_run.save!
  task_run
end