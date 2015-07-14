require "huginn_agent/version"

class HuginnAgent

  def self.emit
    eval "class ::#{self.to_s}Agent; end"
  end

end
