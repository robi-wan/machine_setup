filenames = Dir["#{File.dirname(__FILE__)}/core_ext/*.rb"].sort.map do |path|
  File.basename(path, '.rb')
end

filenames.each { |filename| require "setup_configuration/core_ext/#{filename}" }
