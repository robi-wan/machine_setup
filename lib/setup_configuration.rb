module SetupConfiguration
end

def SetupConfiguration(name, &block)
  suite=SetupConfiguration::Suite.instance
  suite.name=name
  suite.instance_eval(&block)
  suite.validate_params()
rescue
  raise
end

require 'pp'
require 'singleton'
require 'erb'
require 'fileutils'
require 'i18n'
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/setup_config')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/suite_generator')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/translation')