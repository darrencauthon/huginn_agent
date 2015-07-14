require "huginn_agent/version"

class HuginnAgent

  def self.description
  end

  def self.emit
    eval "class ::#{self.to_s}Agent < ::Agent; end"
  end

end
