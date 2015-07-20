require_relative 'spec_helper'

class Class
  def description value
    the_class = class << self; self; end
    the_value = value
    the_class.send(:define_method, :the_description) do
      the_value
    end
  end
end

class ::Agent
end

class FirstTest < HuginnAgent
  def self.description; 'a'; end

  def self.default_options
    @default_options ||= Object.new
  end
end

class SecondTest < HuginnAgent
  def self.description; 'b'; end

  def self.default_options
    @default_options ||= Object.new
  end
end

describe HuginnAgent do

  it "should be a class" do
    HuginnAgent.new.is_a?(HuginnAgent).must_equal true
  end

  describe "emit" do

    after do
      Object.send(:remove_const, :FirstTestAgent) if Object.constants.include?(:FirstTestAgent)
      Object.send(:remove_const, :SecondTestAgent) if Object.constants.include?(:FirstTestAgent)
    end

    [
      { type: FirstTest,  agent: :FirstTestAgent  },
      { type: SecondTest, agent: :SecondTestAgent },
    ].each do |test|

      describe "creating an agent" do

        it "should create an agent class" do
          test[:type].emit
          Object.constants.include?(test[:agent]).must_equal true
        end

        it "should create each agent with an Agent base class" do
          test[:type].emit
          eval(test[:agent].to_s).new.is_a?(Agent).must_equal true
        end

        it "should set the agent description" do
          test[:type].emit
          eval(test[:agent].to_s)
            .the_description.must_equal test[:type].description
        end

      end

    end

  end

  describe "description" do

    it "should default to nil" do
      HuginnAgent.description.nil?.must_equal true
    end

    it "should have each agent create their own description" do
      FirstTest.description.must_equal 'a'
      SecondTest.description.must_equal 'b'
    end

  end

  describe "default_options" do
    it "should default to an empty hash" do
      HuginnAgent.default_options.count.must_equal 0
      HuginnAgent.default_options.is_a?(Hash).must_equal true
    end

    it "should default the agents to return their specific default options" do
      FirstTest.emit
      FirstTestAgent.new.default_options.must_be_same_as FirstTest.default_options

      SecondTest.emit
      SecondTestAgent.new.default_options.must_be_same_as SecondTest.default_options
    end
  end

  describe "validate_options "do

    it "should have a base validate_options method" do
      HuginnAgent.new.validate_options nil
    end

  end

end
