require 'active_support/inflector'
require "huginn_agent/guts"
require "huginn_agent/emitter"
require "huginn_agent/hacker"
require "huginn_agent/version"

class HuginnAgent

  include HuginnAgent::Guts

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

end
