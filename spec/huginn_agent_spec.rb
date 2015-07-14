require_relative 'spec_helper'

class ::Agent
  def self.exist?
    'ok'
  end
end

class FirstTest < HuginnAgent
  def self.description; 'a'; end
end

class SecondTest < HuginnAgent
  def self.description; 'b'; end
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

end
