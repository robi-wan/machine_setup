module SetupConfiguration::Generator
  @output_path=""

  def output_path
    @output_path
  end

  def output_path=(out)
    @output_path=out
  end

  # todo move to SetupConfiguration
  def description_ranges()
    [(0..199), (200..599), (600..1299)]
  end

  # todo move to SetupConfiguration
  def parameter_range()
    Range.new(description_ranges().first().first(), description_ranges().last().last())
  end

  class ParameterTemplateBinding
    attr_accessor :lang
    attr_accessor :parameter_range
    attr_accessor :output

    def initialize(lang, range, output)
      @lang=lang
      @parameter_range=range
      @output=output
    end

    def lang_name()
      SetupConfiguration::Translation.language_name(lang)
    end

#    def name(number)
#      #todo use suite as singleton!
#      p=SetupConfiguration::SuiteGenerator.instance.suite.find_param_by_number(number)
#      if p
#        key=p.name
#        name,comment=SetupConfiguration::Translation::Translator.new().translate(key, @lang)
#        name
#      else
#        ""
#      end
#
#    end
#
#    def description(number)
#      #todo use suite as singleton!
#      p=SetupConfiguration::SuiteGenerator.instance.suite.find_param_by_number(number)
#      if p
#        key=p.key
#        name,comment=SetupConfiguration::Translation::Translator.new().translate(key, @lang)
#        escape(comment)
#      else
#        ""
#      end
#    end
#
#    def translate(number)
#      #todo use suite as singleton!
#      p=SetupConfiguration::SuiteGenerator.instance.suite.find_param_by_number(number)
#      if p
#        key=p.key
#        name,comment=SetupConfiguration::Translation::Translator.new().translate(key, @lang)
#        escape(comment)
#      else
#        ""
#      end
#    end


    def name(number)
      p_name= translate(number) { |name, desc| name }
      p_name= p_name.empty? ? "placeholder for mps3.exe" : p_name
      p_name.gsub(/\[/, '(').gsub(/\]/, ')')
    end

    def description(number)
      translate(number) do |name, desc|
        escape(desc)
      end
    end

    def translate(number, &extractor)
      #todo use suite as singleton!
      p=SetupConfiguration::SuiteGenerator.instance.suite.find_param_by_number(number)
      if p
        key=p.key
        translation = SetupConfiguration::Translation::Translator.new().translate(key, @lang)
        if extractor
          extractor.call( translation)
        else
          translation
        end
      else
        ""
      end
    end

    def escape(message)
      message.gsub(/\n\s?/, '§§')
    end

    # Support templating of member data.
    def get_binding
      binding
    end

  end

#           [:de, "deutsch", (0..199), "deutsch1.lng"],
#          [:de, "deutsch", (200..599), "deutsch2.lng"],
#          [:de, "deutsch", (600..1299), "deutsch3.lng"],
#          [:en, "english", (0..199), "english1.lng"],
#          [:en, "english", (200..599), "english2.lng"],
#          [:en, "english", (600..1299), "english3.lng"],
  def description_bindings()
    SetupConfiguration::Translation.languages().collect() do |lang|
      description_ranges().collect() do |range|
        # constructs the output file names
        out= "#{SetupConfiguration::Translation.language_name(lang)}#{description_ranges().index(range)+1}.lng"
        ParameterTemplateBinding.new(lang, range, out)
      end
    end.flatten()
  end

#  DESCRIPTION_TEMPLATE=%q{
#    [<%= lang_name.upcase %>]
#    <%# Zeilenumbrüche werden mit '§§' dargestellt -> escapen! %>
#    <% parameter_range.each do |number| %>
#    HILFEPARAM<%= number %>=<%= description(number) %>
#    <% end %>
#  }.gsub(/^\s*/, '')

  def description_template
    %q{
    [<%= lang_name.upcase %>]
    <%# Zeilenumbrüche werden mit '§§' dargestellt -> escapen! %>
    <% parameter_range.each do |number| %>
    HILFEPARAM<%= number %>=<%= description(number) %>
    <% end %>
  }.gsub(/^\s*/, '')
  end

  def parameter_bindings()
    SetupConfiguration::Translation.languages().collect() do |lang|
      # constructs the output file names
      out= "#{SetupConfiguration::Translation.language_name(lang)}.lng"
      ParameterTemplateBinding.new(lang, parameter_range(), out)
    end
  end

  def parameter_template(lang)
    template=File.join(File.dirname(__FILE__), "templates", "#{lang.to_s}.lng.erb")
    if File.file?(template)
      File.read(template)
    else
      puts "WARNING: Template file #{template} expected but not found"
    end
  end

end


class SetupConfiguration::SuiteGenerator
  include Singleton
  include SetupConfiguration::Generator
  attr_accessor :suite
  attr_accessor :do_not_run

  def initialize
    self.do_not_run = false
    self.suite = SetupConfiguration::Suite.new
    at_exit do
      puts "todo: generate mps3.ini output!"
      puts "todo: set output folder!"
      puts "todo: suite shall be singleton output!"
      puts "todo: deutsch.lng == INI-Datei : keine eckigen Klammern[]!"
      puts "todo: deutsch.lng == hinter jedem Parameter muss irgendetwas stehen!"

      description_bindings().each() do |bind|
        rhtml = ERB.new(description_template, nil, "<>")

        File.open(File.join(output_path, bind.output), "w") do |f|
          f << rhtml.result(bind.get_binding)
        end
      end

      # extras:
      # -every PARAMETER key needs a value!
      # -use Windows line terminators CRLF - \r\n
      # - do not use [] - output is an INI-file
      parameter_bindings().each() do |bind|
        template = parameter_template(bind.lang_name())
        if template then
          rhtml = ERB.new( template, nil, "<>")

          File.open(File.join(output_path, bind.output), "w") do |f|
            f << rhtml.result(bind.get_binding)
          end
        else
          puts "WARNING: No template found. Generation of #{bind.output} aborted."
        end
      end

    end
  end

  def self.do_not_run
    self.instance.do_not_run=true
  end

  def self.suite_eval(name, &block)
    self.instance.suite.name=name
    self.instance.suite.instance_eval(&block)
    self.instance.suite.validate_params()
  end

  def self.generate
    return "no output" if self.instance.do_not_run

    description_bindings().each() do |bind|
      rhtml = ERB.new(DESCRIPTION_TEMPLATE, 0, "<>")

      File.open(bind.output, "w") do |f|
        f << rhtml.result(bind.get_binding)
      end
    end

  end
end

