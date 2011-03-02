# encoding: utf-8

def SetupConfiguration(name, abbreviation=name, &block)
  suite=SetupConfiguration::Suite.instance
  suite.name=name
  suite.abbreviation=abbreviation
  suite.instance_eval(&block)
  suite.validate_params()
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
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/generator_module')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/template_binding')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/parameter_template_binding')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/mps_template_binding')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/setup_code_generator')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/setup_code_binding')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/setup_config')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/suite_generator')
require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/translation')

require File.expand_path(File.dirname(__FILE__) + '/setup_configuration/legacy/legacy')