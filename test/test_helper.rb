if RUBY_VERSION > '1.9'
  gem 'test-unit'
  require 'test/unit'
end
require 'shoulda'

require File.dirname(__FILE__) + '/../lib/setup_configuration'
