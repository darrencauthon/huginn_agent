require 'active_support/inflector'
require "huginn_agent/emitter"
require "huginn_agent/hacker"
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

  def self.emit
    HuginnAgent::Emitter.new(self).emit
  end

  def self.hack_huginn_to_accept_me
    HuginnAgent::Hacker.hack_huginn_to_accept_me
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

end
