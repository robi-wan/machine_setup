# encoding: windows-1252

module SetupConfiguration

  class SuiteGenerator
    include Generator

    attr_accessor :suite
    attr_accessor :do_not_run

    def initialize
      self.do_not_run = false
      self.suite = Suite.instance
    end

    def self.do_not_run
      self.do_not_run=true
    end

    def generate
      return 'no output' if self.do_not_run

      description_bindings().each() do |bind|
        bind.suite=self.suite

        output(bind, description_template)
      end

      # extras:
      # -every PARAMETER key needs a value!
      # -use Windows line terminators CRLF - \r\n
      # - do not use []
      #- output is an INI-file
      parameter_bindings().each() do |bind|
        bind.suite=self.suite
        template = parameter_template(bind.lang_name())
        output(bind, template)
      end

      bind=mps_binding()
      bind.suite=self.suite
      mps_template=mps_template()
      output(bind, mps_template)

      SetupCodeGenerator.new.generate(self.suite, output_path)
    end

  end

end