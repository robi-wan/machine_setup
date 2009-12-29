require File.dirname(__FILE__) + "/../test_helper"

class MachineTypeTest < Test::Unit::TestCase

  context "A Machine Type" do
    setup do
      @all_machines = SetupConfiguration::MachineType.new(:all_machines, 0, 0..999)
      @machine_one = SetupConfiguration::MachineType.new(:machine_one, 1, 1000..1999)
      @machine_three = SetupConfiguration::MachineType.new(:machine_one, 3, 3000..3999)
    end

    should "return its name" do
      assert_equal :all_machines, @all_machines.name
    end

    should "return its machine type number range" do
      assert_equal 0..999, @all_machines.range
    end

    should "return its sequence number" do
      assert_equal 0, @all_machines.sequence_number
      assert_equal 1, @machine_one.sequence_number
      assert_equal 3, @machine_three.sequence_number
    end

    should "return its binary number" do
      assert_equal 0, @all_machines.binary_number
      assert_equal 1, @machine_one.binary_number
      assert_equal 4, @machine_three.binary_number
    end

  end
  
  
end
