# encoding: windows-1252

module SetupConfiguration

  module Generator

    class ParameterTemplateBinding < TemplateBinding
      attr_accessor :lang
      attr_accessor :parameter_range

      def initialize(lang, range, output)
        @lang=lang
        @parameter_range=range
        @output=output
        @translator = Translation::Translator.new()
      end

      def lang_name
        Translation.language_name(lang)
      end


      def cat_name(cat)
        name, desc=@translator.translate(cat.name, @lang)
        $stderr.puts("WARNING: missing translation for key #{@lang}.#{cat.name}.#{Translation::Translator::NAME}") if name.eql?(cat.name.to_s)
        name
      end

      def name(number)
        p_name= translate(number) { |name, desc| name }
        if find_param_by_number(number) && p_name.eql?(find_param_by_number(number).key.to_s)
          $stderr.puts("WARNING: missing translation for key #{@lang}.#{find_param_by_number(number).key.to_s}.#{Translation::Translator::NAME}")
        end
        p_name.empty? ? "placeholder for mps3.exe" : p_name
      end

      def description(number)
        translate(number) do |name, desc|
          $stderr.puts("WARNING: missing translation for key #{@lang}.#{find_param_by_number(number).key.to_s}.#{Translation::Translator::COMMENT}") if desc.empty?
          escape(desc)
        end
      end

      def translate(number, &extractor)
        p=find_param_by_number(number)
        if p
          key=p.key
          translation = @translator.translate(key, @lang)
          if extractor
            extractor.call(*translation)
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
      # \302\247 - oktale Darstellung von § (Paragraphenzeichen)
      #
      def escape(message)
        message.gsub(/\n\s?/, '§§')
      end

    end
  end
end