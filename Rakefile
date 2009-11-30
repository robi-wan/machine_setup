require 'rake'

require 'rake/gempackagetask'

# Generate GEM ----------------------------------------------------------------------------

PKG_FILES = FileList[
  'R[a-zA-Z]*',
  'T[a-zA-Z]*',
  'bin/*',
  'lib/**/*'
] - [ 'test' ]

spec = Gem::Specification.new do |s|
  s.name = 'machine_setup'
  s.version = '0.0.1'
  s.author = "Robert Ziebarth"
  s.email = 'robi-wan@suyu.de'
  s.homepage = 'http://github.com/robi-wan/machine_setup/'
  s.summary = 'Generating configuration for machine setup parameters.'
  s.description = 'Helps generating configuration files for machine setup parameters.'

  s.files = PKG_FILES.to_a
  s.executables = %w(setup_config_gen.rb)
  s.default_executable = "setup_config_gen.rb"

  s.has_rdoc = false
  ##s.rdoc_options = ['--title', 'Setup Configuration API Documentation', '--main', 'README.rdoc']
  #s.extra_rdoc_files = %w(README.rdoc CHANGELOG)

    if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<i18n>)
    else
      s.add_dependency(%q<i18n>)
    end
  else
    s.add_dependency(%q<i18n>)
  end
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end
