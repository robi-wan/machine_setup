module SetupConfiguration

  module Generator
    @output_path=''

    def output_path
      @output_path
    end

    def output_path=(out)
      @output_path=out
    end

    def output(bind, template)
      if template
        rhtml = Erubis::Eruby.new(template)

        File.open(File.join(output_path, bind.output), 'w') do |f|
          f << rhtml.result(bind.get_binding)
        end
      else
        $stderr.puts "WARNING: No template found. Generation of #{bind.output} aborted."
      end
    end

    #           [:de, "deutsch", (0..199), "deutsch1.lng"],
    #          [:de, "deutsch", (200..599), "deutsch2.lng"],
    #          [:de, "deutsch", (600..1299), "deutsch3.lng"],
    #          [:en, "english", (0..199), "english1.lng"],
    #          [:en, "english", (200..599), "english2.lng"],
    #          [:en, "english", (600..1299), "english3.lng"],
    def description_bindings
      Translation.languages().collect() do |lang|
        SetupConfiguration.description_ranges().collect() do |range|
          # constructs the output file names
          out= "#{Translation.language_name(lang)}#{SetupConfiguration.description_ranges().index(range)+1}.lng"
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

    def parameter_bindings
      Translation.languages().collect() do |lang|
        # constructs the output file names
        out= "#{Translation.language_name(lang)}.lng"
        ParameterTemplateBinding.new(lang, SetupConfiguration.parameter_range(), out)
      end
    end

    def parameter_template(lang)
      find_template("#{lang.to_s}.lng.erb")
    end

    def mps_template
      find_template('mps3.ini.erb')
    end

    def mps_binding
      MPSTemplateBinding.new do |mps|
        mps.output='mps3.ini'
      end
    end

    def find_template(name)
      template=File.join(File.dirname(__FILE__), 'templates', name)
      if File.file?(template)
        File.read(template)
      else
        $stderr.puts "WARNING: Template file #{template} expected but not found"
      end
    end

  end #module Generator
  
end#module SetupConfiguration