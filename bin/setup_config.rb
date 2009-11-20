param_def=ARGV[0]

throw RuntimeError.new("parameter definition nicht angegeben") if param_def.nil?
throw RuntimeError.new("parameter definition existiert nicht") unless File.file?(param_def)

require File.dirname(__FILE__) + '/../lib/setup_configuration'

load param_def

# todo need path of param_def - file for getting translation files...

suite=SetupConfiguration::SuiteGenerator.instance.suite
translator=SetupConfiguration::Translation::Translator.new

#set output path
SetupConfiguration::SuiteGenerator.instance.output_path=File.dirname(param_def)

# load files with translations
SetupConfiguration::Translation.translation_files(suite.name).each() do |t|
  trans_file=File.join(File.dirname(param_def), t)
  SetupConfiguration::Translation::Translator.i18n_load_path(trans_file) if File.file?(trans_file)
end

# gets translations for parameters
SetupConfiguration::Translation.languages().each do |lang|

  suite.parameters.each() do |p|
  name, desc = translator.translate(p.key, lang)
  puts "key: '#{p.key}'\nname: '#{name}'\ndescription: #{desc}\n"
  end

end

#include SetupConfiguration::Generator
#description_bindings().each do |b|
#  pp b
#  puts b.lang_name()
#  puts b.translate(1)
#end

#include SetupConfiguration::Generator
#parameter_bindings().each do |b|
#  pp b
#  puts b.lang_name()
#  puts b.name(1)
#end


SetupConfiguration::SuiteGenerator.generate()
