require 'pp'


require 'singleton'
module SetupConfiguration
  ;
end

# todo validate uniqueness of parameter#key
# todo validate uniqueness of parameter#number
class SetupConfiguration::Suite
  include Singleton
  attr_accessor :categories

  def initialize
    self.categories= Hash.new { |hash, key| hash[key] = [] }
  end

  def category(category, &category_params)
    puts "executes category in Suite: #{category}"
    # todo eval category_params in this class and add creates params to category

    #this code calls instance_eval and delivers the context object
    parameter_factory = SetupConfiguration::ParameterFactory.new()
    parameter_factory.instance_eval(&category_params)
    categories[category] << parameter_factory.params()

    # this .instance_eval call returns the last value of the last executed code (an array from method param in Parameters)
    #categories[category] << SetupConfiguration::Parameters.new().instance_eval(&category_params)

    # flatten is needed: Parameters#param returns an array which is inserted in an array...
    categories[category].flatten!
  end

  #
  # Finds a Parameter with the given key.
  # If there is no such parameter the method returns nil.
  #
  def find_param(key)
    param=nil
    self.categories.values.flatten.each(){|p| param = p if p.key.eql?(key)}
    param
  end
end

# this Suite2 allows params outside a category
#class SetupConfiguration::Suite2
#  include Singleton
#  attr_accessor :categories
#  attr_accessor :cat
#
#  def initialize
#    self.categories= Hash.new { |hash, key| hash[key] = [] }
#  end
#
#  def category(category, &category_params)
#    puts "executes category in Suite: #{category}"
#    # todo eval category_params in this class and add creates params to category
#    setup_configuration_parameters_new = SetupConfiguration::Parameters.new()
#    setup_configuration_parameters_new.instance_eval(&category_params)
#    pp setup_configuration_parameters_new
#
#    self.cat= category
#    self.instance_eval(&category_params)
#
#    #categories[category] << SetupConfiguration::Parameters.new().instance_eval(&category_params)
#    # flatten is needed: Parameters#param returns an array which is inserted in an array...
#    categories[category].flatten
#    self.cat=:none
#  end
#
#  def param(parameter, &parameter_def)
#    puts "executed param in Suite: #{parameter}"
#    # eval given block in Parameter context and return new parameter
#    p = SetupConfiguration::Parameter.new(parameter)
#    p.instance_eval(&parameter_def)
#    self.categories[self.cat] << p
#  end
#
#
#end


class SetupConfiguration::ParameterFactory

  attr_accessor :params

  def initialize
    self.params= []
  end

  def param(parameter, &parameter_def)
    puts "executed param in Parameters: #{parameter}"
    # eval given block in Parameter context and return new parameter
    p = SetupConfiguration::Parameter.new(parameter)
    p.instance_eval(&parameter_def)
    params << p
  end

  def param2(parameter, number, &parameter_def)
    puts "executed param in Parameters: #{parameter}"
    # eval given block in Parameter context and return new parameter
    p = SetupConfiguration::Parameter.new(parameter)
    p.number(number)
    p.instance_eval(&parameter_def) if parameter_def
    params << p
  end


end

class SetupConfiguration::Parameter

  attr_reader :number
  attr_reader :key
  attr_reader :depends_on
  attr_reader :for_machine_type

  def initialize(name, dependent_param=:none, machine_type=0)
    # depends upon no other parameter
    @depends_on=dependent_param
    # valid on all machines
    @for_machine_type=machine_type
    @key= name
  end

  def number(n)
    @number=n
  end

  def depends_on(dependency)
    @depends_on=dependency
  end

  def for_machine_type(machine_type)
    @for_machine_type=machine_type
  end

end

def SetupConfiguration(&block)
  SetupConfiguration::Suite.instance.instance_eval(&block)
end

#def SetupConfiguration2(&block)
#  SetupConfiguration::Suite2.instance.instance_eval(&block)
#end


SetupConfiguration do

  category :common do
    param :underleaver_config do
      number 1
    end
    param :distance_photo_sensor do
      number 2
    end
    param :distance_blade_to_sheet_drive do
      number 3
    end
    param :distance_sheet_drive_to_sheet_exit do
      number 4
    end
    param :time_for_cutting_unit do
      number 5
    end

    param :paper_jam_detection_active do
      number 6
    end
    param :paper_jam_detection_signal_length do
      number 7
      depends_on :paper_jam_detection_active
    end
    param :paper_jam_detection_check_time do
      number 8
      depends_on :paper_jam_detection_active
    end

    param :ext_enabling_following_unit do
      number 10
    end
    param :ext_enabling_following_unit_method do
      number 11
      depends_on :ext_enabling_following_unit
    end
    param :ext_enabling_following_unit_delay do
      number 12
      depends_on :ext_enabling_following_unit
    end

    param :ext_enabling_previous_unit do
      number 13
    end
  end

  # paper roll drive
  category :drives do
    param :paper_roll_config do
      number 300
    end
    param :paper_roll_distance_revolution do
      number 301
      depends_on :paper_roll_config
    end
    param :paper_roll_gear_in do
      number 302
      depends_on :paper_roll_config
    end
    param :paper_roll_gear_out do
      number 303
      depends_on :paper_roll_config
    end
  end

  # blade roll drive
  category :drives do
    param :blade_config do
      number 310
    end
    param :blade_distance_revolution do
      number 311
      depends_on :blade_config
    end
    param :blade_gear_in do
      number 312
      depends_on :blade_config
    end
    param :blade_gear_out do
      number 313
      depends_on :blade_config
    end
  end


end


puts SetupConfiguration::Suite.instance
pp SetupConfiguration::Suite.instance
puts SetupConfiguration::Suite.instance.categories.size

pp SetupConfiguration::Suite.instance.find_param(:blade_gear_in)
pp SetupConfiguration::Suite.instance.find_param(:none)
