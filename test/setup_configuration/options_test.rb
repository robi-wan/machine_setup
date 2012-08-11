# encoding: utf-8
require File.dirname(__FILE__) + "/../test_helper"

class SoftwareOptionsTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @options = SetupConfiguration::SoftwareOptions.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_numeric_values
    assert_equal(@options.number(:do_not_copy), 1)
    assert_equal(@options.number(:needs_licence), 2)
    assert_raise ArgumentError do
      @options.number(:lari_fari_ga_ga)
    end
  end

  def test_reverse
    assert_equal [], @options.compute_options(0)
    assert_equal [:do_not_copy], @options.compute_options(1)
    assert_equal [:needs_licence], @options.compute_options(2)
    assert_equal [:do_not_copy, :needs_licence], @options.compute_options(3)

    # actually more than 3 is not possible yet - there are just two options...
    assert_equal [], @options.compute_options(4)
    assert_equal [:do_not_copy], @options.compute_options(5)
    assert_equal [:needs_licence], @options.compute_options(6)
    assert_equal [:do_not_copy, :needs_licence], @options.compute_options(7)
    assert_equal [], @options.compute_options(8)
  end

end
