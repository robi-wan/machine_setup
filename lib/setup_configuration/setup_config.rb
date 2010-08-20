# encoding: utf-8

module SetupConfiguration

  def self.description_ranges()
    [0..199, 200..599, 600..1299]
  end

  def self.parameter_range()
    Range.new(description_ranges().first().first(), description_ranges().last().last())
  end


  class Suite
    include Singleton

    attr_accessor :categories
    attr_accessor :settings
    attr_accessor :name
    attr_accessor :abbreviation
    attr_accessor :next_category_number

    def initialize
      self.categories= Hash.new { |hash, key| hash[key] = [] }
      self.settings= Setting.new()
      self.next_category_number = 0
    end

    def category(category, &category_params)
      if category_params then

        #this code calls instance_eval and delivers the context object
        parameter_factory = ParameterFactory.new()
        parameter_factory.instance_eval(&category_params)
        cat = category_by_name(category)
        categories[cat] << parameter_factory.params()

        # this .instance_eval call returns the last value of the last executed code (an array from method param in Parameters)
        #categories[category] << SetupConfiguration::Parameters.new().instance_eval(&category_params)

        # flatten is needed: Parameters#param returns an array which is inserted in an array...
        categories[cat].flatten!
      else
        puts "WARNING: Empty category '#{category}' will be ignored. "
      end
    end

    def category_by_name(name)
      cat = self.categories.keys.select(){|c| c.name.eql?(name)}.first
      unless cat then
        cat = Category.new
        cat.number = self.next_category_number!
        cat.name = name
      end
      cat
    end

    def next_category_number!
      number = next_category_number
      self.next_category_number+=1
     number
    end

    def setting(&setting_params)
      settings.instance_eval(&setting_params) if setting_params
    end

    # Gets all known parameters.
    def parameters()
      # cache parameters so sorting is necessary only once - this saves a lot of time...
      @parameters ||= categories.values.flatten.sort
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
      # slicer contains parameter with number 0... therefore valid parameter numbers starts at 0
      valid_param_numbers=SetupConfiguration.parameter_range()

      self.parameters().each() do |p|

        puts "WARNING: parameter number 404 is reserved for machine type. you are using it for '#{p.key}'." if p.number.eql?(404)
        throw RuntimeError.new("ERROR: parameter number '#{p.number}' not supported. Number must be in range #{valid_param_numbers}.") unless valid_param_numbers.member?(p.number)

        if p.param?
          if keys.include? p.key
            raise RuntimeError.new("ERROR: parameter key '#{p.key}' defined more than once")
          else
            keys << p.key
          end


          if numbers.include? p.number
            raise RuntimeError.new("ERROR: parameter number '#{p.number}' defined more than once")
          else
            numbers << p.number
          end
        else
          assign_param_ref(p)
        end#p.param?

      end
      #force fresh sort of parameters
      @parameters = nil
    end#validate_params

    def assign_param_ref(ref)
        param = self.parameters().select(){|p| p.key.eql?(ref.key) && p.param?}.first

        if param
          ref.assign(param)
        else
          raise RuntimeError.new("ERROR: reference to unknown parameter with key '#{ref.key}'")
        end
    end#assign_param_ref

  end


  class Setting

    attr_reader :minimum
    attr_reader :maximum
    attr_reader :balance_minimum
    attr_reader :balance_maximum

    def initialize
      @minimum=0..0
      @maximum=0..0
      @balance_minimum=0..0
      @balance_maximum=0..0
      @machine_types=[]
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

    def machine_type(name, number, range)
      machine_type = MachineType.new(name, number, range)
      @machine_types << machine_type
      # generates a method with given machine type name in a module
      # this module is included in Parameter class so machine type dependencies can be
      # given with machine type names (in DSL) instead of binary numbers
      ParameterMachineTypeBridge.send(:define_method, name) do
        machine_type.binary_number
      end
    end

    def machine_types
      @machine_types.sort {|a, b| a.sequence_number <=> b.sequence_number}
    end

  end

  class Category
    include Enumerable

    attr_accessor :number
    attr_accessor :name
    attr_accessor :parameter

    def initialize()
      @parameter = []
    end

    def <=>(parameter)
      self.number <=> parameter.number
    end

  end


  class ParameterFactory

    attr_accessor :params

    def initialize
      self.params= []
    end

    def param(parameter, number, &parameter_def)
      # evaluate given block in Parameter context and return new parameter
      p = Parameter.new(parameter, number)
      p.instance_eval(&parameter_def) if parameter_def
      params << p
    end

    def param_ref(parameter)
      p = ParameterReference.new(parameter)
      params << p
    end

  end

  class Parameter
    include Enumerable
    include ParameterMachineTypeBridge

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

    def <=>(parameter)
      self.number <=> parameter.number
    end

    def param?
      true
    end

  end

  class ParameterReference
    include Enumerable

    attr_reader :key

    def initialize(key)
      @key = key
      @param=nil
    end

    def assign(parameter)
      @param = parameter
    end

    def assigned?
      @param
    end

    def number
      assigned? ? @param.number : 1
    end

    def machine_type
      assigned? ? @param.machine_type : 0
    end

    def dependency
      assigned? ? @param.dependency : :none
    end

    def <=>(parameter)
      self.number <=> parameter.number
    end

    def param?
      false
    end

  end

  class MachineType
    include Enumerable

    attr_reader :name
    attr_reader :range
    attr_reader :sequence_number
    attr_reader :binary_number

    def initialize(name, sequence_number, range)
      @name=name
      @range=range
      @sequence_number=sequence_number
      if @sequence_number <= 0
        @binary_number=0
      else
        @binary_number=2**(@sequence_number-1)
      end
    end

    def <=>(machine_type)
      self.range.first <=> machine_type.range.first
    end

  end

end
  