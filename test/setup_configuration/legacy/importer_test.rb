# encoding: utf-8
require File.dirname(__FILE__) + "/../../test_helper"

class ImporterTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @mps3_v1 = IniFile.load(File.join(File.dirname(__FILE__),'data/v1/mps3.ini'))
    @mps3_v2 = IniFile.load(File.join(File.dirname(__FILE__),'data/v2/mps3.ini'))
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_mps3_v1
    pe = SetupConfiguration::Legacy::ParameterExtractor.new(@mps3_v1['PARAMANZEIGE'])
    assert_not_nil pe
    level = '1a'
    assert_not_nil pe.param_dependencies(level)
    count = 4
    assert_equal count, pe.param_dependencies(level).length

    assert_not_nil pe.machine_types(level)
    assert_equal count, pe.machine_types(level).length

    assert_nil pe.param_options(level)

    assert_nil pe.roles(level)
  end

  def test_mps3_v2
    pe = SetupConfiguration::Legacy::ParameterExtractor.new(@mps3_v2['PARAMANZEIGE'])
    assert_not_nil pe
    level = '1a'
    count = 4
    assert_not_nil pe.param_dependencies(level)
    assert_equal count, pe.param_dependencies(level).length

    assert_not_nil pe.machine_types(level)
    assert_equal count, pe.machine_types(level).length

    assert_not_nil pe.param_options(level)
    assert_equal count, pe.param_options(level).length

    assert_not_nil pe.roles(level)
    assert_equal count, pe.roles(level).length

  end
end