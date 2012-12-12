# encoding: utf-8
require File.dirname(__FILE__) + "/../test_helper"

class MPSTemplateBindingTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @mps = SetupConfiguration::Generator::MPSTemplateBinding.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_create_instance
    assert_not_nil @mps
    assert_not_nil SetupConfiguration::Generator::MPSTemplateBinding.new {}
  end

  def test_sanitize_do_nothing
    bundle = []
    5.times { bundle << (1..3).to_a }
    assert_equal bundle, @mps.send(:sanitize, bundle)
  end
end