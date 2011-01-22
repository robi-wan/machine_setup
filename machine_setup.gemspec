# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "machine_setup"
  s.version     = "0.2.0"

  s.authors     = ["robi-wan"]
  s.email       = %q{robi-wan@suyu.de}
  s.homepage    = %q{http://github.com/robi-wan/machine_setup}
  s.summary     = %q{Generating configuration for machine setup parameters.}
  s.description = %q{Helps generating configuration files for machine setup parameters.}

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency "i18n", "~> 0.5"
  s.add_runtime_dependency "inifile", "~> 0.3"
  s.add_runtime_dependency "erubis", "~> 2.6"
  s.add_development_dependency "shoulda"

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- test/*`.split("\n")
  # this does not work under windows: pattern {..} gives an error
  # cygwin works
  # s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")  
  s.executables = ["setup_config_gen", "setup_init_dsl", "setup_analyze_dat"]
  s.default_executable = "setup_config_gen"
  s.require_paths = ["lib"]

end
