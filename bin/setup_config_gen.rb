#!/usr/bin/env ruby
param_def=ARGV[0]

throw RuntimeError.new("parameter definition nicht angegeben") if param_def.nil?
throw RuntimeError.new("parameter definition existiert nicht") unless File.file?(param_def)

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'setup_configuration'

# load file with parameter dsl
load param_def

# get reference to suite instance which holds parameter configuration
suite=SetupConfiguration::Suite.instance

#set output path
generator = SetupConfiguration::SuiteGenerator.new()
generator.output_path=File.dirname(param_def)

# load files with translations
SetupConfiguration::Translation.translation_files(suite.name).each() do |t|
  trans_file=File.join(File.dirname(param_def), t)
  if File.file?(trans_file)
    SetupConfiguration::Translation::Translator.i18n_load_path(trans_file)
  else
    puts "WARNING: expected file with translations '#{trans_file}' not found."
  end
end

generator.generate()
