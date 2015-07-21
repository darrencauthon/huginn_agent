require 'active_support/inflector'
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

  def validate_options
  end

  def method_missing(meth, *args, &blk)
    parent_agent.send(meth, *args, &blk)
  end

  def self.emit
    eval "class ::#{self.to_s}Agent < Agent; def base_agent; @base_agent ||= #{self}.new.tap { |a| a.parent_agent = self}; end; end"

    the_description = self.description
    "#{self.to_s}Agent".constantize.class_eval do
      description the_description
    end

    the_event_description = self.event_description
    "#{self.to_s}Agent".constantize.class_eval do
      event_description the_event_description
    end

    if self.new.respond_to?(:check)
      "#{self.to_s}Agent".constantize.class_eval do
        default_schedule 'every_1h'

        def check
          base_agent.check
        end
      end
    else
      "#{self.to_s}Agent".constantize.class_eval do
        cannot_be_scheduled!
      end
    end

    "#{self.to_s}Agent".constantize.class_eval do
      def working?
        base_agent.working?
      end
    end

    "#{self.to_s}Agent".constantize.class_eval do
      def default_options
        base_agent.default_options
      end
    end

    "#{self.to_s}Agent".constantize.class_eval do
      def validate_options
        base_agent.validate_options
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
