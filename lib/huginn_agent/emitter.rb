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

      if agent.new.respond_to?(:check)
        huginn_agent.class_eval do
          default_schedule 'every_1h'

          def check
            base_agent.check
          end
        end
      else
        huginn_agent.class_eval do
          cannot_be_scheduled!
        end
      end

      huginn_agent.class_eval do
        def working?
          base_agent.working?
        end
      end

      huginn_agent.class_eval do
        def default_options
          base_agent.default_options
        end
      end

      huginn_agent.class_eval do
        def validate_options
          base_agent.validate_options
        end
      end
    end

    private

    def declare_the_huginn_agent
      eval "class ::#{agent.to_s}Agent < Agent; def base_agent; @base_agent ||= #{agent}.new.tap { |a| a.parent_agent = self}; end; end"
    end

    def set_the_agent_description
      description = agent.description
      huginn_agent.class_eval { description description }
    end

    def set_the_event_description
      description = agent.event_description
      huginn_agent.class_eval { event_description description }
    end

  end

end
