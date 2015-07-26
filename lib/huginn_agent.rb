require 'active_support/inflector'
require "huginn_agent/emitter"
require "huginn_agent/version"

class HuginnAgent

  attr_accessor :parent_agent

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

  def self.event_description
  end

  def default_options
    {}
  end

  def working?
    true
  end

  def validate_options
  end

  def method_missing(meth, *args, &blk)
    parent_agent.send(meth, *args, &blk)
  end

  def self.emit
    HuginnAgent::Emitter.emit self
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
