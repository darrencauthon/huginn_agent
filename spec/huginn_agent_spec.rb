require_relative 'spec_helper'

class TheTest < HuginnAgent
end

describe HuginnAgent do

  it "should be a class" do
    HuginnAgent.new.is_a?(HuginnAgent).must_equal true
  end

  describe "emit" do

    after do
      Object.send(:remove_const, :TheTestAgent) if Object.constants.include?(:TheTestAgent)
    end

    it "should create an agent class" do
      TheTest.emit
      Object.constants.include?(:TheTestAgent).must_equal true
    end

  end

end
