require 'pp'


require 'singleton'
module SetupConfiguration
  ;
end

class SetupConfiguration::Suite
  include Singleton
  attr_accessor :categories

  def initialize
    self.categories= Hash.new { |hash, key| hash[key] = [] }
  end

  def category(category, &category_params)
    puts "executes category in Suite: #{category}"
    # todo eval category_params in this class and add creates params to category
    categories[category] << SetupConfiguration::Parameters.new().instance_eval(&category_params)
    # flatten is needed: Parameters#param returns an array which is inserted in an array...
    categories[category].flatten!
  end
end

class SetupConfiguration::Parameters

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

end

class SetupConfiguration::Parameter

  attr_accessor :id
  attr_accessor :key
  attr_accessor :depends_upon_param
  attr_accessor :valid_on_machinetype

  def initialize(name, dependent_param=-1, machine_type=0)
    # depends upon no other parameter
    @depends_upon_param=dependent_param
    # valid on all machines
    @valid_on_machinetype=machine_type
    @key= name
  end


end

def SetupConfiguration(&block)
  SetupConfiguration::Suite.instance.instance_eval(&block)
end


SetupConfiguration do
  category :common do
    param :machine_config do
      id=1
    end
  end
  category :drives do
    param :sheet do
      id=2
    end
    param :portion do
      id=3
    end
  end
  category :drives do
    param :knife do
      id=4
    end
  end
end


puts SetupConfiguration::Suite.instance
pp SetupConfiguration::Suite.instance
puts SetupConfiguration::Suite.instance.categories.size
