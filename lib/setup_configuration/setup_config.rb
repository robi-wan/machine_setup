require 'pp'


module SetupConfiguration
  ;
end

# todo add config options for mps3.ini - Details:
# [EINSTELLUNG]
#TABSTART=2
#DRUCK=0
#DATKONVERT=0
#
#[SPRACHE]
#AKTUELL=0
#SPRACHE0=DEUTSCH
#SPRACHE1=ENGLISH
#
#[MINMAXWERTE]
#BEGIN_MIN=0
#END_MIN=0
#BEGIN_MAX=0
#END_MAX=0
#BEGIN_WAAG_MIN=3000
#END_WAAG_MIN=3029
#BEGIN_WAAG_MAX=3030
#END_WAAG_MAX=3059
#
#[MASCHINENTYP]
#BEGIN_TYP0=0
#BEGIN_TYP1=1000
#BEGIN_TYP2=2000
#BEGIN_TYP3=2500
#BEGIN_TYP4=3000
#BEGIN_TYP5=4000
#BEGIN_TYP6=5000
#BEGIN_TYP7=6000




class SetupConfiguration::Suite
  attr_accessor :categories
  attr_accessor :settings
  attr_accessor :name

  def initialize
    @categories= Hash.new { |hash, key| hash[key] = [] }
    @settings= SetupConfiguration::Setting.new()
  end

  def category(category, &category_params)
    puts "executes category in Suite: #{category}"

    #this code calls instance_eval and delivers the context object
    parameter_factory = SetupConfiguration::ParameterFactory.new()
    parameter_factory.instance_eval(&category_params)
    @categories[category] << parameter_factory.params()

    # this .instance_eval call returns the last value of the last executed code (an array from method param in Parameters)
    #categories[category] << SetupConfiguration::Parameters.new().instance_eval(&category_params)

    # flatten is needed: Parameters#param returns an array which is inserted in an array...
    @categories[category].flatten!
  end

  def setting(&setting_params)
    @settings.instance_eval(&setting_params) if setting_params
  end

  # Gets all known parameters.
  def parameters()
    @categories.values.flatten
  end

  #
  # Finds a Parameter with the given key.
  # If there is no such parameter the method returns nil.
  #
  def find_param(key)
    find_param_by_key(key)
  end

  #
  # Finds a Parameter with the given key.
  # If there is no such parameter the method returns nil.
  #
  def find_param_by_key(key)
    self.parameters().select(){|p| p.key.eql?(key)}.first
  end

  #
  # Finds a Parameter with the given number.
  # If there is no such parameter the method returns nil.
  #
  def find_param_by_number(number)
    self.parameters().select(){|p| p.number.eql?(number)}.first
  end

  #
  # Validates the uniqueness of parameter keys and numbers.
  #
  def validate_params()

    #todo number 0 is forbidden - reserved
    #todo (0..1299).contains(parameter_number)

    keys=[]
    numbers=[]
    self.parameters().each() do |p|
      if keys.include? p.key
        # todo error handling
        throw RuntimeError.new("parameter key '#{p.key}' defined more than once")
      else
        keys << p.key
      end

      if numbers.include? p.number
        # todo error handling
        throw RuntimeError.new("parameter number '#{p.number}' defined more than once")
      else
        numbers << p.number
      end
    end
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

class SetupConfiguration::Setting

  attr_reader :minimum
  attr_reader :maximum
  attr_reader :balance_minimum
  attr_reader :balance_maximum

  def initialize
    @minimum=(0..0)
    @maximum=(0..0)
    @balance_minimum=(0..0)
    @balance_maximum=(0..0)
  end

  def min(range)
    @minimum=range
  end

  def max(range)
    @maximum=range
  end

  def balance_min(range)
    @balance_minimum=range
  end

  def balance_max(range)
    @balance_maximum=range
  end
end

class SetupConfiguration::ParameterFactory

  attr_accessor :params

  def initialize
    self.params= []
  end

  def param(parameter, number, &parameter_def)
    puts "executed param in Parameters: #{parameter}"
    # evaluate given block in Parameter context and return new parameter
    p = SetupConfiguration::Parameter.new(parameter)
    p.number=(number)
    p.instance_eval(&parameter_def) if parameter_def
    params << p
  end

end

class SetupConfiguration::Parameter

  attr_accessor :key
  attr_accessor :number
  attr_reader :dependency
  attr_reader :machine_type

  def initialize(name)
    # depends upon no other parameter
    @dependency=:none
    # valid on all machines
    @machine_type=0
    @key= name
  end

  def depends_on(dependency)
    @dependency=dependency
  end

  def for_machine_type(machine_type)
    @machine_type=machine_type
  end

end
