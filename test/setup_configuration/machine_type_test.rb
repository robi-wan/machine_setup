# encoding: utf-8
require File.dirname(__FILE__) + "/../test_helper"

class MachineTypeTest < Test::Unit::TestCase

  context "A Machine Type" do
    setup do
      @machine_one = SetupConfiguration::MachineType.new(:machine_one, 1, 1000..1999)
      @machine_three = SetupConfiguration::MachineType.new(:machine_three, 3, 3000..3999)
      @machine_four = SetupConfiguration::MachineType.new(:machine_four, 4)
      @machine_five = SetupConfiguration::MachineType.new(:machine_five, 5)
    end

    should "return its name" do
      assert_equal :machine_one, @machine_one.name
    end

    should "return its machine type number range" do
      #default machine type ranges
      assert_equal 1000..1999, @machine_one.range
      assert_equal 3000..3999, @machine_three.range
      assert_equal 4000..4999, @machine_four.range
      assert_equal 5000..5999, @machine_five.range
    end

    should "return its sequence number" do
      assert_equal 1, @machine_one.sequence_number
      assert_equal 3, @machine_three.sequence_number
      assert_equal 4, @machine_four.sequence_number
      assert_equal 5, @machine_five.sequence_number
    end

    should "return its coded sequence number as used in mps3.ini" do
      assert_equal 0, @machine_one.sequence_number_coded
      assert_equal 2, @machine_three.sequence_number_coded
      assert_equal 3, @machine_four.sequence_number_coded
      assert_equal 4, @machine_five.sequence_number_coded
    end

    should "return its binary number" do
      assert_equal 1, @machine_one.binary_number
      assert_equal 4, @machine_three.binary_number
      assert_equal 8, @machine_four.binary_number
      assert_equal 16, @machine_five.binary_number
    end

  end
  
  
end
