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

  def self.emit
    eval "class ::#{self.to_s}Agent < Agent; end"

    the_description = self.description
    "#{self.to_s}Agent".constantize.class_eval do
      description the_description
    end
  end

end
