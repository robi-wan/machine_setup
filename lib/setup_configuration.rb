# encoding: utf-8

module SetupConfiguration
end

def SetupConfiguration(name, abbreviation=name, &block)
  suite=SetupConfiguration::Suite.instance
  suite.name=name
  suite.abbreviation=abbreviation
  suite.instance_eval(&block)
  suite.validate_params()
  #TODO add method for handling param_refs
  suite.assign_param_refs()
rescue
  raise
end

require 'pp'
require 'singleton'
require 'erubis'
require 'fileutils'
require 'i18n'
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/core_ext')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/parameter_machinetype_bridge')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/setup_config')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/suite_generator')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/translation')

require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/legacy/legacy')