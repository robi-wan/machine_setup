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
    attr_reader   :maximum_numbers_per_category

    def initialize
      self.categories= Hash.new { |hash, key| hash[key] = [] }
      self.settings= Setting.new()
      self.next_category_number = 0
      @maximum_numbers_per_category = 150
    end

    def category(category, &category_params)
      if category_params

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
        $stderr.puts "WARNING: Empty category '#{category}' will be ignored. "
      end
    end

    def category_by_name(name)
      cat = self.categories.keys.detect(){|c| c.name.eql?(name)}
      unless cat
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
    def parameters
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
      self.parameters().detect(){|p| p.key.eql?(key)}
    end

    #
    # Finds a Parameter with the given number.
    # If there is no such parameter the method returns nil.
    #
    def find_param_by_number(number)
      self.parameters().detect(){|p| p.number.eql?(number)}
    end

    #
    # Validates the uniqueness of parameter keys and numbers.
    #
    def validate_params

      categories.each() do |key, value|
        throw RuntimeError.new("ERROR: category '#{key}' contains more than #{maximum_numbers_per_category} parameters. Reduce parameter count.") if value.size >maximum_numbers_per_category
      end

      keys=[]
      numbers=[]
      # slicer contains parameter with number 0... therefore valid parameter numbers starts at 0
      valid_param_numbers=SetupConfiguration.parameter_range()

      self.parameters().each() do |p|

        $stderr.puts "WARNING: parameter number 404 is reserved for machine type. you are using it for '#{p.key}'." if p.number.eql?(404)
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
        param = self.parameters().detect(){|p| p.key.eql?(ref.key) && p.param?}

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

    #TODO remove range argument
    def machine_type(name, number, range=nil)
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

    def initialize
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
      p
    end

    def param_ref(parameter)
      p = ParameterReference.new(parameter)
      params << p
    end


    #
    # Additional block is allowed, it may contain call for_machine_type and depends_on.
    # This additional information is applied only to generated parameter
    # <drive>_selection.
    # The additional for_machine_type is also applied to other generated parameters.
    #
    def drive(drive, number, added_props=[], &parameter_def)

      key = symbol(drive, 'drive')
      drive_selection = symbol(key, 'selection')

      drive_param=param(drive_selection, number)
      drive_param.instance_eval(&parameter_def) if parameter_def

      properties=[%w(distance revolution), %w(gear in), %w(gear out), 'length', 'motortype']
      properties += added_props if added_props
      properties.each_with_index do |prop, index|
        parameter = param(symbol(key, *prop), number + index + 1) { depends_on drive_selection }
        parameter.for_machine_type(drive_param.machine_type)
      end

    end

    private

    def symbol(*strings)
      strings.join('_').to_sym
    end
  end

  class SoftwareOptions
    include BinaryCodedValues

    OPTIONS = {:do_not_copy => 1, :needs_licence => 2}

    def values
      OPTIONS
    end

    # TODO check for maximum and raise error
    def compute_options(number)
      value(number)
    end

  end

  class Roles
    include BinaryCodedValues

    ROLES = {:foreman => 1, :service => 2, :application_engineer => 4, :test_bay => 8, :developer => 16}

    def values
      ROLES
    end

    # TODO check for maximum and raise error
    def compute_roles(number)
      value(number)
    end


  end

  class Parameter
    include Enumerable
    include ParameterMachineTypeBridge

    attr_accessor :key
    attr_accessor :number
    attr_reader :dependency
    attr_reader :machine_type
    attr_reader :options
    attr_reader :roles

    def initialize(name, number)
      # depends upon no other parameter
      @dependency=:none
      # valid on all machines
      @machine_type=0
      @options=0
      @roles=0
      @key= name
      @number=number
      @role = Roles.new
      @option = SoftwareOptions.new
    end

    def depends_on(dependency)
      @dependency=dependency
    end

    def for_machine_type(machine_type)
      @machine_type=machine_type
    end

    def has_options(*opt)
      # use @options as initial value: multiple calls to has_options are possible and result value is chained
      # (and not reset if using '0' as explicit initial value)
      @options = opt.uniq.inject(@options) do |sum, o|
        sum + @option.number(o)
      end
    end

    def enabled_for_role(*roles)
      # use @roles as initial value: multiple calls to enabled_for_role are possible and result value is chained
      # (and not reset if using '0' as explicit initial value)
      @roles = roles.uniq.inject(@roles) do |sum, r|
        sum + @role.number(r)
      end
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

    def options
      assigned? ? @param.options : 0
    end

    def roles
      assigned? ? @param.roles : 0
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

    RANGES = [1000..1999, 2000..2999, 3000..3999, 4000..4999, 5000..5999, 6000..6999, 7000..7999, 8000..8999].freeze

    attr_reader :name
    attr_reader :range
    attr_reader :sequence_number
    attr_reader :sequence_number_coded
    attr_reader :binary_number

    def initialize(name, sequence_number, range = nil)
      @name=name
      raise RuntimeError.new("ERROR: Number for machine type must be greater than 0: [name=#{name}] [number=#{sequence_number}]") if sequence_number <= 0
      raise RuntimeError.new("ERROR: More than #{RANGES.length} different machine types are not supported: [name=#{name}] [number=#{sequence_number}]") if sequence_number > RANGES.length
      @sequence_number=sequence_number
      @sequence_number_coded = @sequence_number - 1
      @range = range ? range : RANGES[@sequence_number_coded]
      @binary_number=2**@sequence_number_coded
    end

    def <=>(machine_type)
      self.range.first <=> machine_type.range.first
    end

  end

end
  
