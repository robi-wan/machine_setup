module SetupConfiguration

  module Legacy

    class LanguageContext

      attr_reader :lang_abbr
      attr_reader :output

      def initialize(name, lang, helper)
        @lang=lang
        @helper=helper
        @lang_abbr= SetupConfiguration::Translation.language_abbreviation(lang)
        @output = SetupConfiguration::Translation.translation_file(name, @lang_abbr)
      end

      def category_name(cat)
        @helper.category_name_raw(@lang, cat)
      end

      def parameter_name(param)
        @helper.param_name(@lang, param)
      end


      def parameter_description(param)
      #TODO escape ($$ into \n)
        @helper.parameter_description(@lang, param.to_i)
      end

      def categories
        @helper.categories.sort
      end

    end

  end

end
