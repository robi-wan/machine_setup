# encoding: utf-8
require File.dirname(__FILE__) + "/../test_helper"

class RoleTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @r = SetupConfiguration::Roles.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_numeric_values
    assert_equal 1, @r.number(:foreman)
    assert_equal 2, @r.number(:service)
    assert_equal 4, @r.number(:application_engineer)
    assert_equal 8, @r.number(:test_bay)
    assert_equal 16, @r.number(:developer)
    assert_raise ArgumentError do
      @r.number(:lari_fari_ga_ga)
    end
  end

  def test_reverse
    assert_equal [],                                                                 @r.compute_roles(0)
    assert_equal [:foreman],                                                         @r.compute_roles(1)
    assert_equal [:service],                                                         @r.compute_roles(2)
    assert_equal [:foreman, :service],                                               @r.compute_roles(3)
    assert_equal [:application_engineer],                                            @r.compute_roles(4)
    assert_equal [:foreman, :application_engineer],                                  @r.compute_roles(5)
    assert_equal [:service, :application_engineer],                                  @r.compute_roles(6)
    assert_equal [:foreman, :service, :application_engineer],                        @r.compute_roles(7)
    assert_equal [:test_bay],                                                        @r.compute_roles(8)
    assert_equal [:foreman, :test_bay],                                              @r.compute_roles(9)
    assert_equal [:service, :test_bay],                                              @r.compute_roles(10)
    assert_equal [:foreman, :service, :test_bay],                                    @r.compute_roles(11)
    assert_equal [:application_engineer, :test_bay],                                 @r.compute_roles(12)
    assert_equal [:foreman, :application_engineer, :test_bay],                       @r.compute_roles(13)
    assert_equal [:service, :application_engineer, :test_bay],                       @r.compute_roles(14)
    assert_equal [:foreman, :service, :application_engineer, :test_bay],             @r.compute_roles(15)
    assert_equal [:developer],                                                       @r.compute_roles(16)
    assert_equal [:foreman, :developer],                                             @r.compute_roles(17)
    assert_equal [:service, :developer],                                             @r.compute_roles(18)
    assert_equal [:foreman, :service, :developer],                                   @r.compute_roles(19)
    assert_equal [:application_engineer, :developer],                                @r.compute_roles(20)
    assert_equal [:foreman, :application_engineer, :developer],                      @r.compute_roles(21)
    assert_equal [:service, :application_engineer, :developer],                      @r.compute_roles(22)
    assert_equal [:foreman, :service, :application_engineer, :developer],            @r.compute_roles(23)
    assert_equal [:test_bay, :developer],                                            @r.compute_roles(24)
    assert_equal [:foreman, :test_bay, :developer],                                  @r.compute_roles(25)
    assert_equal [:service, :test_bay, :developer],                                  @r.compute_roles(26)
    assert_equal [:foreman, :service, :test_bay, :developer],                        @r.compute_roles(27)
    assert_equal [:application_engineer, :test_bay, :developer],                     @r.compute_roles(28)
    assert_equal [:foreman, :application_engineer, :test_bay, :developer],           @r.compute_roles(29)
    assert_equal [:service, :application_engineer, :test_bay, :developer],           @r.compute_roles(30)
    assert_equal [:foreman, :service, :application_engineer, :test_bay, :developer], @r.compute_roles(31)
  end

end
