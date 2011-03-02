# encoding: windows-1252

module SetupConfiguration

  class SetupCodeGenerator
    include Generator

    def generate(suite, output_path)
      setup_code=SetupCodeBinding.new
      setup_code.output="LOGCODE#{suite.name.to_s.upcase}SETUP.EXP"
      setup_code.suite=suite
      self.output_path=output_path
      output(setup_code, template)
    end

    :private

    def template
      find_template("logcodesetup.exp.erb")
    end

  end

end