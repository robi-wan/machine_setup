class SetupConfiguration::SuiteGenerator
  include Singleton
  attr_accessor :suite
  attr_accessor :do_not_run

  def initialize
    self.do_not_run = false
    self.suite = SetupConfiguration::Suite.new
    at_exit do
      puts "todo: generate output!"
      #exit 1 unless suite.execute.succeeded?
    end
  end

  def self.do_not_run
    self.instance.do_not_run=true
  end

  def self.suite_eval(&block)
    self.instance.suite.instance_eval(&block)
    self.instance.suite.validate_params()
  end

  def self.generate
    return "no output" if self.instance.do_not_run
  end
end
