# encoding: utf-8

module SetupConfiguration
  #
  # Module which acts as a container for generated methods which will deliver binary values 
  # of machine types.
  #
  module ParameterMachineTypeBridge

    def self.create_method(name, &block)
      self.send(:define_method, name, &block)
    end
    
  end
end
