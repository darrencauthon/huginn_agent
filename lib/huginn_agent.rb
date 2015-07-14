require "huginn_agent/version"

class HuginnAgent

  def self.emit
    eval "class ::TheTestAgent; end"
  end

end
