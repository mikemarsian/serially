module Serially

    def self.included(receiver)
      receiver.extend Serially::ClassMethods
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

        # If TaskManager for current including class doesn't exist, create it
        task_manager = Serially::TaskManager.new(self, options)
        Serially::TaskManager[self] ||= task_manager

        # create a new base, and resolve DSL
        @serially = Serially::Base.new(task_manager)
        @serially.instance_eval(&block) if block

        # return Serially::Base
        @serially
      end
    end

    # this is the entry point for all instance-level access to Serially
    def serially
      @serially ||= Serially::InstanceBase.new(self)
    end
end