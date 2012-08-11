# encoding: windows-1252
module SetupConfiguration

  module Legacy

    class Importer

      attr_reader :categories

      def initialize(folder, name, abbreviation)
        @folder=folder
        @name=name
        @abbreviation=abbreviation
        @mps3 = ::IniFile.load( File.join(@folder, 'mps3.ini'))
        @settings = SetupConfiguration::Setting.new
        @categories=[]
        @languages=[]
        @ini_files=Hash.new { |hash, key| hash[key] = ::IniFile.load( File.join(@folder, key), :comment => ';//') }
        init_settings()
        init_params()
      end

      def output(output_path=@folder)
        output_param(output_path)
        @languages.each() {|lang| output_language(output_path, lang)}
      end

      def output_language(output_path, lang)
        context = LanguageContext.new(@name, lang, self)

        template=File.join(File.dirname(__FILE__), "templates", "setup.param.language.yml.erb")
        input = File.read(template)
        eruby = Erubis::Eruby.new(input)
        
        File.open(File.join(output_path, context.output ), "w") do |f|
          f << eruby.evaluate(context)
        end

      end

      def output_param(output_path)
        template=File.join(File.dirname(__FILE__), "templates", "setup.param.erb")
        input = File.read(template)
        eruby = Erubis::Eruby.new(input)
        
        File.open(File.join(output_path, "#@name.#{Translation::FILE_EXTENSION}" ), "w") do |f|
          f << eruby.result(binding())
        end

      end


      include SetupConfiguration::SoftwareOptions
      def render_options(binary)
        options = compute_options(binary)
        render_symbols(options)
      end

      include SetupConfiguration::Roles
      def render_roles(binary)
        roles = compute_roles(binary)
        render_symbols(roles)
      end

      def render_symbols(symbols)
        symbols.collect(){|s| ":#{s}"}.join(", ")
      end

      def compute_machine_types(binary)
        # 60.to_s(2).chars.to_a.reverse.each_with_index { |s,i| puts s; puts i}
        result=[]
        if binary.eql?(0) then
          result << machine_type_by_number(binary).name
        else
          Fixnum.induced_from(binary).to_s(2).chars.to_a.reverse.each_with_index do |value, index|
            if value.eql?("1")
              result << machine_type_by_number(index+1).name
            end
          end
        end
        result.join(" + ")
      end

      def machine_type_by_number(number)
        @settings.machine_types.select() {|mt| mt.sequence_number.eql?(number)}.first
      end

      def init_settings()
        @settings.min(Range.new(sv('BEGIN_MIN'), sv('END_MIN')))
        @settings.max(Range.new(sv('BEGIN_MAX'), sv('END_MAX')))
        @settings.balance_min(Range.new(sv('BEGIN_WAAG_MIN'), sv('END_WAAG_MIN')))
        @settings.balance_max(Range.new(sv('BEGIN_WAAG_MAX'), sv('END_WAAG_MAX')))

        #machine types
        machine_types = @mps3['MASCHINENTYP']
        machine_type_regexp=/BEGIN_TYP(\d\d?)/
        machine_types.each do |k,v|
          number = k.scan(machine_type_regexp).flatten.first.to_i
          number = number + 1
          @settings.machine_type("machine_type_#{number}".to_sym, number, v.to_i)
        end

        #calculate ranges for machine types
        @settings.machine_types.each_with_index do |mt, index|
          ending=mt.range + 999
          if @settings.machine_types[index + 1]
            ending = @settings.machine_types[index + 1].range - 1
          end
          # this is really ugly
          mt.instance_variable_set( :@range, Range.new(mt.range, ending))
        end



        # languages
        lang = @mps3['SPRACHE']
        lang.each() do |k,v|
          if k =~ /SPRACHE\d\d?/
            @languages << v
          end
        end

      end

      def setting_value(key)
        minmax = @mps3['MINMAXWERTE']
        minmax[key].to_i
      end
      alias :sv :setting_value


      #todo preserve original parameter order
      def init_params()
        extractor = ParameterExtractor.new(@mps3['PARAMANZEIGE'], self)
        extractor.extract()

        # replace parameter numbers with parameter keys
        parameters.each() do |param|
          if param.param?
            p = param_by_number(param.dependency)
            param.depends_on(p ? p.key : :none)
          end
        end

        #get category names
        self.categories.each do |cat|
          cat.name = category_name(cat.number)
        end

      end

      # TODO extract into module
      def category_name_raw(lang, cat_number)
        ini= @ini_files["#{lang.downcase}.lng"]
        ini[lang.downcase]["TAB#{cat_number}"]
      end

      # TODO extract into module
      # Get the name of the category with the given number. Name is escaped and ready to use as a symbol
      # Language defaults to 'deutsch'.
      def category_name(number)
        key=category_name_raw('deutsch', number)
        # ensure uniqueness of category names so that they do not clash with parameter names
        # otherwise comments for parameters get lost (categories have no comments)
        "cat_#{escape(key)}"
      end

      def escape(key)
        key=key.gsub(/[^a-zäüöA-ZÄÜÖ0-9\s]/, '')
        key=key.gsub('ä', 'ae')
        key=key.gsub('ö', 'oe')
        key=key.gsub('ü', 'ue')
        key=key.gsub('Ä', 'Ae')
        key=key.gsub('Ö', 'Oe')
        key=key.gsub('Ü', 'Ue')
        key=key.gsub('ß', 'ss')
        key=key.split(' ').collect(){|splitter| splitter.downcase }
        #remove leading numbers
        #TODO this just works if first element is a number - extend for all leading elements...
        if key.first.to_i.to_s.eql?(key.first) then
          key.shift
        end
        
        key.join('_').to_sym
      end

      def param_name(lang, param_number)
        filename = "#{lang.downcase}.lng"
        key_ini= @ini_files[filename]
        key_ini[lang.downcase]["PARAM#{param_number}"]
      end

      def param_key(param_number)
        key=param_name('deutsch', param_number)
        #delete unwanted characters
        escape(key)
      end

      def parameter_description(lang, param_number)
        #determine number in description file name
        file_number=1
        SetupConfiguration.description_ranges().each_with_index() do |range, index|
          file_number= index + 1 if range.include?(param_number.to_i)
        end

        filename = lang.downcase << file_number.to_s << ".lng"
        key_ini= @ini_files[filename]
        desc=key_ini[lang.upcase]["HILFEPARAM#{param_number}"]
        escape_param_description(desc)
      end

      def escape_param_description(description)
        description unless description.eql?("not used")
      end

      def parameters
         @categories.collect(){|cat| cat.parameter }.flatten
      end

      def param_by_number(number)
        self.parameters().select(){|p| p.number.eql?(number)}.first
      end

      def category_by_number(number)
        cat = self.categories.select(){|c| c.number.eql?(number)}.first
        unless cat
          cat = Category.new
          cat.number = number
          self.categories << cat
        end
        cat
      end



    end

  end
end
