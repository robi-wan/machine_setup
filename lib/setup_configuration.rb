module SetupConfiguration
end

def SetupConfiguration(&block)
  SetupConfiguration::SuiteGenerator.suite_eval(&block)
rescue
  raise
end

require 'singleton'
require 'erb'
require 'fileutils'
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/setup_config')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/suite_generator')
