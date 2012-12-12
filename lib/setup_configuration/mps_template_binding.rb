# encoding: windows-1252

module SetupConfiguration

  module Generator

    class MPSTemplateBinding < TemplateBinding

      def initialize
        yield self if block_given?
        @max_number_parameters_per_tab=50
      end

      def languages
        Translation.language_names
      end

      def settings
        self.suite.settings
      end

      def param_infos(category_key)
        parameters=suite.categories[category_key]
        depends, machine_type, number, options, roles=[], [], [], [], []
        parameters.each() do |param|
          machine_type << param.machine_type
          number << param.number
          depends << depends_on(param.dependency)
          options << param.options
          roles << param.roles
        end
        #TODO compute value for max_number_parameters_per_tab of value maximum_numbers_per_category
        bundle = [depends, machine_type, number, options, roles].collect() { |arr| arr.in_groups_of(@max_number_parameters_per_tab, false) }
        bundle = sanitize(bundle)
        bundle.collect(){ |v| v.collect(){ |arr| prepare(arr) } }
      end

      private

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

      def sanitize(bundle)
        count_params = bundle.first.flatten.length
        if count_params <= @max_number_parameters_per_tab
          bundle
        else
          depends, machine_type, number, options, roles = *bundle
          # iterating with each_cons(2) would be much nicer, but how do I get the index for shifting...
          length = number.length
          number.each_with_index() do |param_num, index|
            if index < length-1
              next_number_dup = number[index+1].dup
              # use next_number_dup for iteration as we are changing number[index+1]
              # iterate second array until the parameter group ends
              next_number_dup.each() do |second|
                group = param_group?(param_num.last, second)
                if group
                  bundle.each() do |member|
                    member[index] << member[index+1].shift
                  end
                else
                  break
                end
              end
            end
          end

          bundle
        end
      end

      # Does these two parameters belong to the same "parameter group"?
      # The definition of a parameter group (as needed for working around 'grouping bug' in new setup editor):
      # Two parameters shall be grouped together if:
      # - two 'physical' consecutive parameters have also consecutive parameter numbers
      #   and
      # - these two parameters have the same dependency
      #   or
      #   the second parameter depends on the first parameter
      def param_group?(last, first)
        p1 = find_param_by_number(last)
        p2 = find_param_by_number(first)
        # parameters have sequenced numbers
        result = (p1.number - p2.number).abs.eql?(1)
        # parameters have same dependency or second parameter depends on first parameter
        result && ( p1.dependency.eql?(p2.dependency) || p2.dependency.eql?(p1.key))
      end

    end
  end
end