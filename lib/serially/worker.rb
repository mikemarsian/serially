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
      while (task = Serially::Manager.get_next_task(item_class, item_id))
        # if task.async?
        #   started_async_task = SerialTasksManager.begin_task(task)
        #   # if started async task successfully, exit the loop, otherwise go to next task
        #   break if started_async_task
        # else
        #started_async_task = false
        Serially::Manager.perform_task(task)
      end
      # if started_async_task
      #   msg = "SerialTasksManager: started async task for #{item_class}/#{item_id}. Worker is exiting..."
      # else
      #   msg = "SerialTasksManager: no available tasks found for #{item_class}/#{item_id}. Worker is exiting..."
      # end

      # If we are here, it means that no more tasks were found
      msg = "Serially: no available tasks found for #{item_class}/#{item_id}. SeriallyWorker is exiting..."
      Resque.logger.info(msg)
    end

    # when enqueuing lifecycle_task job, we don't specify which task it should perform, since this is decided from within the job
    def self.enqueue(item_class, item_id)
      Resque.enqueue(Serially::Worker, item_class, item_id)
    end

    def self.enqueue_batch(item_class, items)
      items.each {|item| enqueue(item_class, item.id)}
    end
  end
end