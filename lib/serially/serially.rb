module Serially

    def self.included(receiver)
      receiver.extend Serially::ClassMethods
      # remove any task_manager that might have been inherited - inclusion takes precedence
      Serially::TaskManager[receiver] = nil
      super
    end

    module ClassMethods
      # make sure inheritance works with Serially
      def inherited(subclass)
        Serially::TaskManager[subclass] = Serially::TaskManager[self].clone_for(subclass)
        super
      end

      def serially(*args, &block)
        options = args[0] || {}
        invalid_options = Serially::Options.validate(options)
        raise Serially::ConfigurationError.new("Serially received the following invalid options: #{invalid_options}") if invalid_options.present?

        # If TaskManager for current including class doesn't exist, create it
        Serially::TaskManager[self] ||= Serially::TaskManager.new(self, options)
        task_manager = Serially::TaskManager[self]

        # create a new base, and resolve DSL
        @serially = Serially::Base.new(task_manager)
        if block
          @serially.instance_eval(&block)
        else
          raise Serially::ConfigurationError.new("Serially is defined without a block of tasks definitions in class #{self}")
        end

        # return Serially::Base
        @serially
      end

      def start_batch!(instance_ids)
        queue = Serially::TaskManager[self].queue
        instance_ids.each do |instance_id|
          Serially::Job.enqueue(self, instance_id, queue)
        end
      end

      def is_active_record?
        self < ActiveRecord::Base
      end

      # override this to provide a custom way of creating instances of your class
      def create_instance(*args)
        args = args.flatten
        if self.is_active_record?
          if args.count == 1
            args[0].is_a?(Fixnum) ? self.where(id: args[0]).first : self.where(args[0]).first
          else
            raise Serially::ArgumentError.new("Serially: default implementation of ::create_instance expects to receive either id or hash")
          end
        else
          begin
            args.blank? ? new : new(*args)
          rescue StandardError => exc
            raise Serially::ArgumentError.new("Serially: since no implementation of ::create_instance is provided in #{self}, tried to call new, but failed with provided arguments: #{args}")
          end
        end
      end
    end

    # this is the entry point for all instance-level access to Serially
    def serially
      @serially ||= Serially::InstanceBase.new(self)
    end

    # override this to provide a custom way of fetching id of your class' instance
    def instance_id
      self.respond_to?(:id) ? self.id : self.object_id
    end




    class Options
      ALLOWED = [:in_queue]

      def self.default_queue
        'serially'
      end

      def self.validate(options)
        invalid_options = {}

        valid_options = options.select{ |k,v| ALLOWED.include?(k) }
        invalid_keys = options.keys.select{ |k| !ALLOWED.include?(k) }
        empty_values = valid_options.select{ |k, v| v.blank? }.keys

        invalid_options['Unrecognized Keys'] = invalid_keys if invalid_keys.present?
        invalid_options['Empty Values'] = empty_values if empty_values.present?

        invalid_options
      end
    end
end