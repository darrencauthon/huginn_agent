class HuginnAgent

  module Hacker

    def self.inject_these_agents_into_huginn

      Agent.instance_eval do

        alias :default_types :types

        def types
          (default_types + HuginnAgent.agent_types)
            .sort_by { |x| x.to_s }
        end

        def valid_type?(type)
          types.include? type.constantize
        rescue
          false
        end

      end

    end

  end

end
