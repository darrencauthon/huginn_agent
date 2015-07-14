require_relative 'spec_helper'

class FirstTest < HuginnAgent
end

class SecondTest < HuginnAgent
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

      end

    end

  end

end
