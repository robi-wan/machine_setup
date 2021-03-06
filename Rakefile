require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "machine_setup"
    gem.executables = %W{setup_config_gen setup_init_dsl setup_analyze_dat}
    gem.summary = %Q{Generating configuration for machine setup parameters.}
    gem.description = %Q{Helps generating configuration files for machine setup parameters.}
    gem.email = "robi-wan@suy"+'u.de'
    gem.homepage = "http://github.com/robi-wan/machine_setup"
    gem.authors = ["robi-wan"]
    gem.add_runtime_dependency "i18n", "~> 0.6"
    gem.add_runtime_dependency "inifile", "~> 2.0"
    gem.add_runtime_dependency "erubis", "~> 2.7"
    gem.add_development_dependency "shoulda"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "machine_setup #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
