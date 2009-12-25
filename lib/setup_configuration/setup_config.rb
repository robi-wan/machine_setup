module SetupConfiguration

  def self.description_ranges()
    [(0..199), (200..599), (600..1299)]
  end

  def self.parameter_range()
    Range.new(description_ranges().first().first(), description_ranges().last().last())
  end

end

class SetupConfiguration::Suite
  include Singleton

  attr_accessor :categories
  attr_accessor :settings
  attr_accessor :name
  attr_accessor :abbreviation

  def initialize
    self.categories= Hash.new { |hash, key| hash[key] = [] }
    self.settings= SetupConfiguration::Setting.new()
  end

  def category(category, &category_params)
    if category_params then
#      puts "executes category in Suite: #{category}"

      #this code calls instance_eval and delivers the context object
      parameter_factory = SetupConfiguration::ParameterFactory.new()
      parameter_factory.instance_eval(&category_params)
      categories[category] << parameter_factory.params()

      # this .instance_eval call returns the last value of the last executed code (an array from method param in Parameters)
      #categories[category] << SetupConfiguration::Parameters.new().instance_eval(&category_params)

      # flatten is needed: Parameters#param returns an array which is inserted in an array...
      categories[category].flatten!
    else
      puts "WARNING: Empty category '#{category}' will be ignored. "
    end
  end

  def setting(&setting_params)
    settings.instance_eval(&setting_params) if setting_params
  end

  # Gets all known parameters.
  def parameters()
    categories.values.flatten
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

    categories.each() do |key, value|
      throw RuntimeError.new("ERROR: category '#{key}' contains more than 150 parameters. Reduce parameter count.") if value.size >150
    end
    
    keys=[]
    numbers=[]
    #valid parameter numbers start at 1
    valid_param_numbers=Range.new(SetupConfiguration.parameter_range().first()+1, SetupConfiguration.parameter_range().last)

    self.parameters().each() do |p|

      puts "WARNING: parameter number 404 is reserved for machine type. you are using it for '#{p.key}'." if p.number.eql?(404)
      throw RuntimeError.new("ERROR: parameter number '#{p.number}' not supported. Number must be in range #{valid_param_numbers}.") unless valid_param_numbers.member?(p.number)

      if keys.include? p.key
        # todo error handling
        throw RuntimeError.new("ERROR: parameter key '#{p.key}' defined more than once")
      else
        keys << p.key
      end

      
      if numbers.include? p.number
        # todo error handling
        throw RuntimeError.new("ERROR: parameter number '#{p.number}' defined more than once")
      else
        numbers << p.number
      end
    end
  end

end


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
#    puts "executed param in Parameters: #{parameter}"
    # evaluate given block in Parameter context and return new parameter
    p = SetupConfiguration::Parameter.new(parameter, number)
    p.instance_eval(&parameter_def) if parameter_def
    params << p
  end

end

class SetupConfiguration::Parameter

  attr_accessor :key
  attr_accessor :number
  attr_reader :dependency
  attr_reader :machine_type

  def initialize(name, number)
    # depends upon no other parameter
    @dependency=:none
    # valid on all machines
    @machine_type=0
    @key= name
    @number=number
  end

  def depends_on(dependency)
    @dependency=dependency
  end

  def for_machine_type(machine_type)
    @machine_type=machine_type
  end

end
