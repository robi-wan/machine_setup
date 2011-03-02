require "test/unit"
require File.dirname(__FILE__) + "/../test_helper"
module SetupConfiguration

  class ParameterFactoryTest < Test::Unit::TestCase

    context "A ParameterFactory" do

      setup do
        @creator = ParameterFactory.new()
      end

      should "define a method 'drive'" do
        assert_not_nil @creator.public_methods.delete("drive")
      end

      should "define a method 'param'" do
        assert_not_nil @creator.public_methods.delete("param")
      end

      should "define a method 'param_ref'" do
        assert_not_nil @creator.public_methods.delete("param_ref")
      end

    end
  end
end
