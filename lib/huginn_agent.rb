require 'active_support/inflector'
require "huginn_agent/version"

class HuginnAgent

  def self.inherited type
    @types ||= []
    @types << type
  end

  def self.types
    @types ||= []
  end

  def self.agent_types
    types.map { |x| "#{x}Agent".constantize }
  end

  def self.description
  end

  def default_options
    {}
  end

  def validate_options
  end

  def self.emit
    eval "class ::#{self.to_s}Agent < Agent; def initialize; @base_agent = #{self}.new; end; end"

    the_description = self.description
    "#{self.to_s}Agent".constantize.class_eval do
      description the_description
    end

    "#{self.to_s}Agent".constantize.class_eval do
      def default_options
        @base_agent.default_options
      end
    end

    "#{self.to_s}Agent".constantize.class_eval do
      def validate_options
        @base_agent.validate_options
      end
    end
  end

  def self.hack_huginn_to_accept_me

    Agent.instance_eval do

      alias :default_types :types

      def types
        (default_types + HuginnAgent.agent_types)
          .sort_by { |x| x.to_s }
      end

      def valid_type?(type)
        types.include? type.constantize
      end

    end

  end

end
