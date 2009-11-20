module SetupConfiguration
end

def SetupConfiguration(name, &block)
  SetupConfiguration::SuiteGenerator.suite_eval(name, &block)
rescue
  raise
end

require 'singleton'
require 'erb'
require 'fileutils'
require 'i18n'
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/setup_config')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/suite_generator')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/translation')
