# encoding: windows-1252

module SetupConfiguration

  module Generator

    class MPSTemplateBinding < TemplateBinding

      def initialize
        yield self
      end

      def languages
        Translation.language_names
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
        [depends, machine_type, number].collect() { |arr| (arr.in_groups_of(max_number_parameters_per_tab, false)).collect() { |a| prepare(a) } }
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
            $stderr.puts "ERROR: parameter with key '#{key}' not found."
            # depends on no other parameter
            -1
          end
        end
      end

    end
  end
end