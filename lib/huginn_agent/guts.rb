class HuginnAgent

  module Guts

    module ClassMethods

      def inherited type
        @types ||= []
        @types << type
      end

      def types
        @types ||= []
      end

      def agent_types
        types.map { |x| "#{x}Agent".constantize }
      end

      def emit
        HuginnAgent::Emitter.new(self).emit
      end

      def hack_huginn_to_accept_me
        HuginnAgent::Hacker.hack_huginn_to_accept_me
      end
      
    end
  
    module InstanceMethods

      def parent_agent
        @parent_agent
      end

      def parent_agent= parent_agent
        @parent_agent = parent_agent
      end

      def method_missing meth, *args, &blk
        parent_agent.send meth, *args, &blk
      end
  
    end
  
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

  end

end
