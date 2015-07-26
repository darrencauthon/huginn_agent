class HuginnAgent

  class Emitter

    attr_reader :agent

    def initialize agent
      @agent = agent
    end

    def emit
      declare_the_huginn_agent

      the_description = agent.description
      "#{agent.to_s}Agent".constantize.class_eval do
        description the_description
      end

      the_event_description = agent.event_description
      "#{agent.to_s}Agent".constantize.class_eval do
        event_description the_event_description
      end

      if agent.new.respond_to?(:check)
        "#{agent.to_s}Agent".constantize.class_eval do
          default_schedule 'every_1h'

          def check
            base_agent.check
          end
        end
      else
        "#{agent.to_s}Agent".constantize.class_eval do
          cannot_be_scheduled!
        end
      end

      "#{agent.to_s}Agent".constantize.class_eval do
        def working?
          base_agent.working?
        end
      end

      "#{agent.to_s}Agent".constantize.class_eval do
        def default_options
          base_agent.default_options
        end
      end

      "#{agent.to_s}Agent".constantize.class_eval do
        def validate_options
          base_agent.validate_options
        end
      end
    end

    private

    def declare_the_huginn_agent
      eval "class ::#{agent.to_s}Agent < Agent; def base_agent; @base_agent ||= #{agent}.new.tap { |a| a.parent_agent = self}; end; end"
    end

  end

end
