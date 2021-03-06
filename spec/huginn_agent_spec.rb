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

  def cannot_receive_events!
    (class << self; self; end)
      .send(:define_method, :the_cannot_receive_events!) { true }
  end

  def default_schedule value
    the_class = class << self; self; end
    the_value = value
    the_class.send(:define_method, :the_default_schedule) do
      the_value
    end
  end

  def event_description value
    the_class = class << self; self; end
    the_value = value
    the_class.send(:define_method, :the_event_description) do
      the_value
    end
  end

end

class ::Agent
end

class FirstTest < HuginnAgent
  def self.description; 'a'; end

  def self.event_description; 't'; end

  def default_options
    @default_options ||= Object.new
  end
end

class SecondTest < HuginnAgent
  def self.description; 'b'; end

  def self.event_description; 'u'; end

  def default_options
    @default_options ||= Object.new
  end

  def check
  end
end

class ThirdTest < HuginnAgent
  def self.description; 'c'; end

  def receive
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
      Object.send(:remove_const, :ThirdTestAgent) if Object.constants.include?(:FirstTestAgent)
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

    it "should bind the check method" do
      SecondTest.emit
      expected_result = Object.new
      base_agent = Struct.new(:check).new expected_result
      agent = SecondTestAgent.new
      agent.stubs(:base_agent).returns base_agent
      agent.check.must_be_same_as expected_result
    end
  end

  describe "create_event" do

    it "should bind the create_event method from the actual agent to the base agent" do
      FirstTest.emit
      expected_result = Object.new
      data = Object.new
      agent = FirstTestAgent.new

      agent.stubs(:create_event).with(data).returns expected_result
      result = agent.base_agent.create_event(data)
      result.must_be_same_as expected_result
    end

  end

  describe "event description" do

    it "should default to nothing" do
      HuginnAgent.event_description.nil?.must_equal true
    end

    it "should bind up the event description" do
      FirstTest.emit
      FirstTestAgent.the_event_description.must_equal FirstTest.event_description
      SecondTest.emit
      SecondTestAgent.the_event_description.must_equal SecondTest.event_description
    end
  end

  describe "working?" do

    it "should default working? to true" do
      FirstTest.emit
      agent = FirstTestAgent.new
      agent.working?.must_equal true
    end

    it "should bind up working?" do
      FirstTest.emit
      agent = FirstTestAgent.new
      expected_result = Object.new
      agent.base_agent.stubs(:working?).returns expected_result
      agent.working?.must_be_same_as expected_result
    end

  end

  describe "all of the methods on the base agent that I do not want to bind up manually" do
    it "should all of the undefined methods to the parent agent" do
      FirstTest.emit
      agent = FirstTestAgent.new

      expected_result = Object.new

      method = :abc
      input1 = Object.new
      input2 = Object.new
      input3 = Object.new

      agent.stubs(method).with(input1, input2, input3).returns expected_result

      result = agent.base_agent.send(method, input1, input2, input3)

      result.must_be_same_as expected_result
    end
  end

  describe "receiving events" do

    it "should call cannot_receive_events! by default" do
      FirstTest.emit
      eval(FirstTestAgent.to_s)
        .the_cannot_receive_events!.must_equal true
    end

    describe "when receive is declared" do

      it "should not call cannot_receive_events" do
        ThirdTest.emit
        eval(ThirdTestAgent.to_s)
          .respond_to?(:the_cannot_receive_events!).must_equal false
      end

      it "should bind the check method" do
        ThirdTest.emit
        expected_result, events = Object.new, Object.new
        base_agent = Object.new.tap { |s| s.stubs(:receive).with(events).returns expected_result }
        agent = ThirdTestAgent.new
        agent.stubs(:base_agent).returns base_agent
        agent.receive(events).must_be_same_as expected_result
      end

    end

  end

end
