module Serially

    def self.included(receiver)
      receiver.extend Serially::ClassMethods

      # do not overwrite existing serially tasks, which could have been created by
      # inheritance, see class method inherited
      Serially::TaskManager[receiver] ||= Serially::TaskManager.new

      super
    end

    module ClassMethods
      # make sure inheritance works with Serially
      def inherited(subclass)
        Serially::TaskManager[subclass] = Serially::TaskManager[self].clone
        super
      end

      def serially(*args, &block)
        options = args[0] || {}

        # @task_manager is a class instance variable
        # TODO: one of these is redundant
        @task_manager = Serially::TaskManager.new(self, options)
        Serially::TaskManager[self] ||= @task_manager

        @task_manager.instance_eval(&block) if block # new DSL
        @task_manager
      end
    end
end