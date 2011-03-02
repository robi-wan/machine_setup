# encoding: windows-1252

module SetupConfiguration

  module Generator

    class TemplateBinding

      attr_accessor :suite
      attr_accessor :output

      def categories
        #TODO maybe cache these values for better performance...?
        suite.categories.keys().sort()
      end

      # Support templating of member data.
      def get_binding
        binding
      end

      def find_param_by_number(number)
        self.suite.find_param_by_number(number)
      end

    end
  end
end