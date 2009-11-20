require "test/unit"
require File.dirname(__FILE__) + "/../test_helper"

class GeneratorTest < Test::Unit::TestCase
  include SetupConfiguration::Generator

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

#  # Fake test
#  def test_fail
#
#    # To change this template use File | Settings | File Templates.
#    fail("Not implemented")
#  end

  def test_parameter_range
    assert_equal( (0..1299), parameter_range())
  end

  def test_description_ranges
    assert_equal(3, description_ranges().size)
    assert_equal((0..199), description_ranges()[0])
    assert_equal((200..599), description_ranges()[1])
    assert_equal((600..1299), description_ranges()[2])
  end
end
