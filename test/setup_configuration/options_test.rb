# encoding: utf-8
require File.dirname(__FILE__) + "/../test_helper"

class SoftwareOptionsTest < Test::Unit::TestCase

  include SetupConfiguration::SoftwareOptions

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

  def test_numeric_values
    assert_equal(opt_value(:do_not_copy), 1)
    assert_equal(opt_value(:needs_licence), 2)
    assert_raise ArgumentError do
      opt_value(:lari_fari_ga_ga)
    end
  end

  def test_reverse
    assert_equal [], compute_options(0)
    assert_equal [:do_not_copy], compute_options(1)
    assert_equal [:needs_licence], compute_options(2)
    assert_equal [:do_not_copy, :needs_licence], compute_options(3)

    # actually more than 3 is not possible yet - there are just two options...
    assert_equal [], compute_options(4)
    assert_equal [:do_not_copy], compute_options(5)
    assert_equal [:needs_licence], compute_options(6)
    assert_equal [:do_not_copy, :needs_licence], compute_options(7)
    assert_equal [], compute_options(8)
  end

end
