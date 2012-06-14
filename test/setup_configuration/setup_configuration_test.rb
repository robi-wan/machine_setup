# encoding: utf-8
require File.dirname(__FILE__) + "/../test_helper"

class SetupConfigurationTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end


  def test_parameter_range
    assert_equal( (0..1299), SetupConfiguration.parameter_range())
  end

  def test_description_ranges
    assert_equal(3, SetupConfiguration.description_ranges().size)
    assert_equal((0..199), SetupConfiguration.description_ranges()[0])
    assert_equal((200..599), SetupConfiguration.description_ranges()[1])
    assert_equal((600..1299), SetupConfiguration.description_ranges()[2])
  end
end
