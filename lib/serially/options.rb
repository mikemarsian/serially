module Serially

  class Options
    # this should be overridden in sub-classes
    def self.allowed
      []
    end

    def self.validate(options)
      invalid_options = {}

      valid_options = options.select{ |k,v| allowed.include?(k) }
      invalid_keys = options.keys.select{ |k| !allowed.include?(k) }
      empty_values = valid_options.select{ |k, v| v.blank? }.keys

      invalid_options['Unrecognized Keys'] = invalid_keys if invalid_keys.present?
      invalid_options['Empty Values'] = empty_values if empty_values.present?

      invalid_options
    end
  end

  class GlobalOptions < Options
    def self.allowed
      [:in_queue]
    end

    def self.default_queue
      'serially'
    end
  end

  class TaskOptions < Options
    def self.allowed
      [:on_error]
    end

  end

end