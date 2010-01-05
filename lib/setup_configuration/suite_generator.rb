# encoding: utf-8

module SetupConfiguration::Generator
  @output_path=""

  def output_path
    @output_path
  end

  def output_path=(out)
    @output_path=out
  end

  class TemplateBinding

    attr_accessor :suite
    attr_accessor :output

    def categories
      suite.categories.keys()
    end

    # Support templating of member data.
    def get_binding
      binding
    end

  end

  class ParameterTemplateBinding < TemplateBinding
    attr_accessor :lang
    attr_accessor :parameter_range

    def initialize(lang, range, output)
      @lang=lang
      @parameter_range=range
      @output=output
    end

    def lang_name
      SetupConfiguration::Translation.language_name(lang)
    end

    def cat_name(key)
      name, desc=SetupConfiguration::Translation::Translator.new().translate(key, @lang)
      name
    end

    def name(number)
      p_name= translate(number) { |name, desc| name }
      p_name.empty? ? "placeholder for mps3.exe" : p_name
    end

    def description(number)
      translate(number) do |name, desc|
        escape(desc)
      end
    end

    def translate(number, &extractor)
      p=self.suite.find_param_by_number(number)
      if p
        key=p.key
        translation = SetupConfiguration::Translation::Translator.new().translate(key, @lang)
        if extractor
          extractor.call( *translation )
        else
          translation
        end
      else
        ""
      end
    end

    private

    #
    # Zeilenumbrüche werden mit '§§' dargestellt
    #
    def escape(message)
      message.gsub(/\n\s?/, '§§')
    end

  end

  class MPSTemplateBinding < TemplateBinding


    def languages
      SetupConfiguration::Translation.language_names.values
    end

    def settings
      self.suite.settings
    end

    def param_infos(category_key)
      parameters=suite.categories[category_key]
      depends, machine_type, number=[], [], []
      parameters.each() do |param|
        machine_type << param.machine_type
        number << param.number
        depends << depends_on(param.dependency)
      end
      #TODO compute value for max_number_parameters_per_tab of value maximum_numbers_per_category
      max_number_parameters_per_tab=50
      [depends, machine_type, number].collect(){ |arr| (arr%(max_number_parameters_per_tab)) .collect(){|a| prepare(a)}}
    end

    :private

    def prepare(array)
      array.join(',')
    end

    def depends_on(key)

      if :none.eql?(key) then
        -1
      else
        param=suite.find_param(key)
        if param
          param.number
        else
          puts "ERROR: parameter with key '#{key}' not found."
          # depends on no other parameter
          -1
        end
      end
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
      SetupConfiguration.description_ranges().collect() do |range|
        # constructs the output file names
        out= "#{SetupConfiguration::Translation.language_name(lang)}#{SetupConfiguration.description_ranges().index(range)+1}.lng"
        ParameterTemplateBinding.new(lang, range, out)
      end
    end.flatten()
  end

  def description_template
    %q{
    [<%= lang_name.upcase %>]
    <% parameter_range.each do |number| %>
    HILFEPARAM<%= number %>=<%= description(number) %>
    <% end %>
  }.gsub(/^\s*/, '')
  end

  def parameter_bindings()
    SetupConfiguration::Translation.languages().collect() do |lang|
      # constructs the output file names
      out= "#{SetupConfiguration::Translation.language_name(lang)}.lng"
      ParameterTemplateBinding.new(lang, SetupConfiguration.parameter_range(), out)
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

  def mps_template()
    template=File.join(File.dirname(__FILE__), "templates", "mps3.ini.erb")
    if File.file?(template)
      File.read(template)
    else
      puts "WARNING: Template file #{template} expected but not found"
    end
  end

  def mps_binding()
    mps=MPSTemplateBinding.new
    mps.output="mps3.ini"
    mps
  end


end



class SetupConfiguration::SetupCodeBinding < SetupConfiguration::Generator::TemplateBinding
  
  def initialize
    super
  end
  
  def parameters
    suite.parameters
  end
  
  #
  # Offset for setup parameter numbers. This offset is added to a parameter number when evaluated in controller.
  #
  def parameter_offset
    1300
  end
  
  def key(symbol)
    s=symbol.to_s
    delimiter='_'
    s.split(delimiter).collect(){|splitter| splitter.capitalize}.join(delimiter).ljust(longest_key_length)
  end
  
  :private

  def longest_key_length
    # find the length of the longest word
    unless @longest
     longest = parameters.inject(0) do |memo,param|
        memo >= param.key.to_s.length ? memo : param.key.to_s.length
     end
     @longest=longest + 5
    end
    @longest
  end
end

class SetupConfiguration::SetupCodeGenerator
  
  def generate(suite, output_path)
    setup_code=SetupConfiguration::SetupCodeBinding.new
    setup_code.output="LOGCODE#{suite.name.to_s.upcase}SETUP.EXP"
    setup_code.suite=suite
    
    if template then
      rhtml = ERB.new( template, nil, "<>")

      File.open(File.join(output_path, setup_code.output), "w") do |f|
        f << rhtml.result(setup_code.get_binding)
      end
    else
      puts "WARNING: No template found. Generation of #{setup_code.output} aborted."
    end
    
    
  end
  
  :private
  def template
    template=File.join(File.dirname(__FILE__), "templates", "logcodesetup.exp.erb")
    if File.file?(template)
      File.read(template)
    else
      puts "WARNING: Template file #{template} expected but not found"
    end
  end
  
end


class SetupConfiguration::SuiteGenerator
  include SetupConfiguration::Generator

  attr_accessor :suite
  attr_accessor :do_not_run

  def initialize
    self.do_not_run = false
    self.suite = SetupConfiguration::Suite.instance
  end

  def self.do_not_run
    self.do_not_run=true
  end

  def generate
    return "no output" if self.do_not_run

    description_bindings().each() do |bind|
      bind.suite=self.suite
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
      bind.suite=self.suite
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

    bind=mps_binding()
    bind.suite=self.suite
    mps_template=mps_template()
    if mps_template then
      rhtml = ERB.new( mps_template, nil, "<>")

      File.open(File.join(output_path, bind.output), "w") do |f|
        f << rhtml.result(bind.get_binding)
      end
    else
      puts "WARNING: No template found. Generation of #{bind.output} aborted."
    end

    SetupConfiguration::SetupCodeGenerator.new.generate(self.suite, output_path)
    
  end
end

