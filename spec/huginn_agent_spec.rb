require_relative 'spec_helper'

class Class
  def description value
    the_class = class << self; self; end
    the_value = value
    the_class.send(:define_method, :the_description) do
      the_value
    end
  end

  def cannot_be_scheduled!
    (class << self; self; end)
      .send(:define_method, :the_cannot_be_scheduled!) { true }
  end

  def default_schedule value
    the_class = class << self; self; end
    the_value = value
    the_class.send(:define_method, :the_default_schedule) do
      the_value
    end
  end
end

class ::Agent
end

class FirstTest < HuginnAgent
  def self.description; 'a'; end

  def default_options
    @default_options ||= Object.new
  end
end

class SecondTest < HuginnAgent
  def self.description; 'b'; end

  def default_options
    @default_options ||= Object.new
  end

  def check
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
      HuginnAgent.new.default_options.count.must_equal 0
      HuginnAgent.new.default_options.is_a?(Hash).must_equal true
    end

    it "should default the agents to return their specific default options" do
      expected_result = Object.new
      first_test      = Struct.new(:default_options, :parent_agent).new expected_result, nil

      FirstTest.stubs(:new).returns first_test
      FirstTest.emit
      FirstTestAgent.new.default_options.must_be_same_as expected_result
    end
  end

  describe "validate_options "do

    it "should have a base validate_options method" do
      HuginnAgent.new.validate_options
    end

    it "should pass the errors from the base class" do
      expected_result = Object.new
      first_test      = Struct.new(:validate_options, :parent_agent).new expected_result, nil

      FirstTest.stubs(:new).returns first_test
      FirstTest.emit

      result = FirstTestAgent.new.validate_options
      result.must_be_same_as expected_result
    end

  end

  describe "options" do

    let(:options)    { Object.new }
    let(:first_test) { FirstTestAgent.new }

    before do
      FirstTest.emit
      first_test.stubs(:options).returns options
    end

    it "should be bound to the actual agent in use" do
      first_test.base_agent.options.must_be_same_as options
    end

  end

  describe "errors" do

    let(:errors)    { Object.new }
    let(:first_test) { FirstTestAgent.new }

    before do
      FirstTest.emit
      first_test.stubs(:errors).returns errors
    end

    it "should be bound to the actual agent in use" do
      first_test.base_agent.errors.must_be_same_as errors
    end

  end

  describe "scheduling" do
    it "should call cannot_be_scheduled! by default" do
      FirstTest.emit
      eval(FirstTestAgent.to_s)
        .the_cannot_be_scheduled!.must_equal true
    end

    it "should NOT call cannot_be_scheduled! if a check method is defined" do
      SecondTest.emit
      eval(SecondTestAgent.to_s)
        .respond_to?(:the_cannot_be_scheduled!).must_equal false
    end

    it "should have a default schedule of every hour" do
      SecondTest.emit
      eval(SecondTestAgent.to_s)
        .the_default_schedule.must_equal 'every_1h'
    end
  end

end
