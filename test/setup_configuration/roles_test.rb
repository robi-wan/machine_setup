# encoding: utf-8
require File.dirname(__FILE__) + "/../test_helper"

class RoleTest < Test::Unit::TestCase

  include SetupConfiguration::Roles

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
    assert_equal 1, role_value(:foreman)
    assert_equal 2, role_value(:service)
    assert_equal 4, role_value(:application_engineer)
    assert_equal 8, role_value(:test_bay)
    assert_equal 16, role_value(:developer)
    assert_raise ArgumentError do
      role_value(:lari_fari_ga_ga)
    end
  end

  def test_reverse
    assert_equal [],                                                                 compute_roles(0)
    assert_equal [:foreman],                                                         compute_roles(1)
    assert_equal [:service],                                                         compute_roles(2)
    assert_equal [:foreman, :service],                                               compute_roles(3)
    assert_equal [:application_engineer],                                            compute_roles(4)
    assert_equal [:foreman, :application_engineer],                                  compute_roles(5)
    assert_equal [:service, :application_engineer],                                  compute_roles(6)
    assert_equal [:foreman, :service, :application_engineer],                        compute_roles(7)
    assert_equal [:test_bay],                                                        compute_roles(8)
    assert_equal [:foreman, :test_bay],                                              compute_roles(9)
    assert_equal [:service, :test_bay],                                              compute_roles(10)
    assert_equal [:foreman, :service, :test_bay],                                    compute_roles(11)
    assert_equal [:application_engineer, :test_bay],                                 compute_roles(12)
    assert_equal [:foreman, :application_engineer, :test_bay],                       compute_roles(13)
    assert_equal [:service, :application_engineer, :test_bay],                       compute_roles(14)
    assert_equal [:foreman, :service, :application_engineer, :test_bay],             compute_roles(15)
    assert_equal [:developer],                                                       compute_roles(16)
    assert_equal [:foreman, :developer],                                             compute_roles(17)
    assert_equal [:service, :developer],                                             compute_roles(18)
    assert_equal [:foreman, :service, :developer],                                   compute_roles(19)
    assert_equal [:application_engineer, :developer],                                compute_roles(20)
    assert_equal [:foreman, :application_engineer, :developer],                      compute_roles(21)
    assert_equal [:service, :application_engineer, :developer],                      compute_roles(22)
    assert_equal [:foreman, :service, :application_engineer, :developer],            compute_roles(23)
    assert_equal [:test_bay, :developer],                                            compute_roles(24)
    assert_equal [:foreman, :test_bay, :developer],                                  compute_roles(25)
    assert_equal [:service, :test_bay, :developer],                                  compute_roles(26)
    assert_equal [:foreman, :service, :test_bay, :developer],                        compute_roles(27)
    assert_equal [:application_engineer, :test_bay, :developer],                     compute_roles(28)
    assert_equal [:foreman, :application_engineer, :test_bay, :developer],           compute_roles(29)
    assert_equal [:service, :application_engineer, :test_bay, :developer],           compute_roles(30)
    assert_equal [:foreman, :service, :application_engineer, :test_bay, :developer], compute_roles(31)
  end

end
