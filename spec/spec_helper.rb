require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'resque'
require 'mock_redis'
require 'serially'
#require 'resque-lonely_job'
#require 'timecop'

RSpec.configure do |config|
  config.before(:suite) do
    Resque.redis = MockRedis.new
  end

  # should syntax is more readable
  config.expect_with :rspec do |c|
    c.syntax = :should
  end
  config.mock_with :rspec do |c|
    c.syntax = :should
  end

end

# example model classes
Dir[File.dirname(__FILE__) + "/models/*.rb"].sort.each { |f| require File.expand_path(f) }