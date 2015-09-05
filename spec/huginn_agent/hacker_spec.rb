require_relative '../spec_helper'

class Agent
  def self.types
  end
end

describe Agent do

  before { HuginnAgent::Hacker.inject_these_agents_into_huginn }

  describe "valid type?" do

    let(:a) { Object.new }
    let(:b) { Object.new }
    let(:c) { Object.new }

    before { Agent.stubs(:types).returns [a, b, c] }

    it "should return true if the type, constantized, matches" do
      Agent.valid_type?(Struct.new(:constantize).new(a)).must_equal true
      Agent.valid_type?(Struct.new(:constantize).new(b)).must_equal true
      Agent.valid_type?(Struct.new(:constantize).new(c)).must_equal true
    end

    it "should return false if the type, constantized, does not match" do
      Agent.valid_type?(Struct.new(:constantize).new('a')).must_equal false
      Agent.valid_type?(Struct.new(:constantize).new(Object.new)).must_equal false
      Agent.valid_type?(Struct.new(:constantize).new(nil)).must_equal false
    end

    it "should return false if the type cannot be constantized" do
      failing_constantize = Object.new.tap { |x| x.stubs(:constantize).raises 'no no' }
      Agent.valid_type?(failing_constantize).must_equal false
    end

  end

end
