require File.dirname(__FILE__) + "/../test_helper"
module SetupConfiguration

  class ParameterFactoryTest < Test::Unit::TestCase

    context "A ParameterFactory" do

      setup do
        @creator = ParameterFactory.new()
      end

      should "define a method 'drive'" do
        contain_method("drive")
      end

      should "define a method 'param'" do
        contain_method("param")
      end

      should "define a method 'param_ref'" do
        contain_method("param_ref")
      end

    end

    :private

    def contain_method(name)
      # Ruby 1.8.7 delivers string, Ruby 1.9.2 delivers symbols in public_methods array
      assert_equal 1, @creator.public_methods.select(){|m| m.to_s.eql?(name)}.length
    end
    
  end
end
