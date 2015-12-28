# encoding: UTF-8
require 'resque'
require 'resque-lonely_job'

module Serially
  class Worker
    # LonelyJob ensures that only one job a time runs per item_class/item_id (such as Invoice/34599), which
    # effectively means that for every invoice there is only one job a time, which ensures invoice jobs are processed serially
    extend Resque::Plugins::LonelyJob

    @queue = 'serially'
    def self.queue
      @queue
    end

    # this ensures that for item_class=Invoice, and item_id=34500, only one job will run at a time
    def self.redis_key(item_class, item_id, *args)
      "serially:#{item_class}_#{item_id}"
    end

    def self.perform(item_class, item_id)
      writer = TaskRunWriter.new if item_class.is_active_record?
      result_str = TaskRunner.new(writer).run!(item_class, item_id)
      Resque.logger.info(result_str)
    end

    def self.enqueue(item_class, item_id)
      Resque.enqueue(Serially::Worker, item_class.to_s, item_id)
    end

    def self.enqueue_batch(item_class, items)
      items.each {|item| enqueue(item_class.to_s, item.instance_id)}
    end
  end
end