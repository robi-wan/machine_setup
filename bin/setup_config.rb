param_def=ARGV[0]

throw RuntimeError.new("parameter definition nicht angegeben") if param_def.nil?
throw RuntimeError.new("parameter definition existiert nicht") unless File.file?(param_def)

require File.dirname(__FILE__) + '/../lib/setup_configuration'
load param_def
