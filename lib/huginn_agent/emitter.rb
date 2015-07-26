class HuginnAgent

  class Emitter

    attr_reader :agent

    def initialize agent
      @agent = agent
    end

    def huginn_agent
      "#{agent.to_s}Agent".constantize
    end

    def emit
      declare_the_huginn_agent
      set_the_agent_description
      set_the_event_description
      set_the_scheduling
      set_the_check
      set_the_working
      set_the_default_options
      set_the_validation
    end

    private

    def declare_the_huginn_agent
      eval <<AGENT
        class ::#{agent.to_s}Agent < Agent
          def base_agent
            @base_agent ||= #{agent}.new.tap { |a| a.parent_agent = self}
          end
        end
AGENT
    end

    def set_the_agent_description
      description = agent.description
      huginn_agent.class_eval { description description }
    end

    def set_the_event_description
      description = agent.event_description
      huginn_agent.class_eval { event_description description }
    end

    def set_the_scheduling
      if agent.new.respond_to?(:check)
        huginn_agent.class_eval { default_schedule 'every_1h' }
      else
        huginn_agent.class_eval { cannot_be_scheduled! }
      end
    end

    def set_the_check
      if agent.new.respond_to?(:check)
        huginn_agent.class_eval do
          def check
            base_agent.check
          end
        end
      end
    end

    def set_the_working
      huginn_agent.class_eval do
        def working?
          base_agent.working?
        end
      end
    end

    def set_the_default_options
      huginn_agent.class_eval do
        def default_options
          base_agent.default_options
        end
      end
    end

    def set_the_validation
      huginn_agent.class_eval do
        def validate_options
          base_agent.validate_options
        end
      end
    end

  end

end
