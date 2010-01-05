# encoding: utf-8
require File.dirname(__FILE__) + "/../test_helper"

class ParameterTest < Test::Unit::TestCase

  context "A Parameter" do
    setup do
      @parameter = SetupConfiguration::Parameter.new(:drive_config, 42)
    end

    should "return its name" do
      assert_equal :drive_config, @parameter.key
    end

    should "return its number" do
      assert_equal 42, @parameter.number
    end

    should "return its default machine type" do
      assert_equal 0, @parameter.machine_type
    end

    should "return its default parameter dependency" do
      assert_equal :none, @parameter.dependency
    end

    context "with a defined machine type" do
      setup do
        @parameter.for_machine_type 13
      end

      should "return its given machine type" do
        assert_equal 13, @parameter.machine_type
      end

    end

    context "with a defined parameter dependency" do
      setup do
        @parameter.depends_on :machine_virtual
      end

      should "return its given parameter dependency" do
        assert_equal :machine_virtual, @parameter.dependency
      end

    end

  end

end
