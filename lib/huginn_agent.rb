require "huginn_agent/version"

class HuginnAgent

  def self.description
  end

  def self.emit
    eval <<EOF
    class ::#{self.to_s}Agent < ::Agent
    end
EOF
    the_description = self.description
    eval("::#{self.to_s}Agent").instance_eval do
      description the_description
    end
  end

end
