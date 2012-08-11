# encoding: utf-8
module SetupConfiguration

  module Legacy

    class ParameterExtractor

      INI_LINE_SPLIT_PATTERN=','

      def initialize(p, importer=nil)
        @params = p
        @importer = importer
      end

      def extract
        @params.each do |key, value|
          cat_regexp = /TAB((\d\d?)([abc]))/
          if key =~ cat_regexp then
            unless value.empty?
              cat_level=key.scan(cat_regexp).flatten[0]
              cat_number=key.scan(cat_regexp).flatten[1].to_i

              deps = param_dependencies("#{cat_level}")
              types = machine_types("#{cat_level}")
              options = param_options("#{cat_level}") # may be nil
              roles = roles("#{cat_level}") # may be nil

              cat = @importer.category_by_number(cat_number)
              value.split(INI_LINE_SPLIT_PATTERN).each_with_index do |param_number, index|

                #check for multiple defined parameters (in different categories)
                #warn and skip
                if @importer.param_by_number(param_number)
                  $stderr.puts("WARNING: parameter '#{ @importer.param_key(param_number)}' with number '#{param_number}' multiple defined. Duplicate found in category '#{@importer.category_name(cat_number)}'.")
                  parameter = ParameterReference.new(@importer.param_key(param_number))
                  cat.parameter << parameter
                else
                  key = @importer.param_key(param_number)
                  parameter = Parameter.new(key, param_number)
                  parameter.depends_on(deps[index])
                  parameter.for_machine_type(types[index].to_i)
                  parameter.options = options[index].to_i if options
                  parameter.roles = roles[index].to_i if roles
                  cat.parameter << parameter
                end
              end

            end
          end
        end

      end

      # key = 2CF#{level}
      def param_dependencies(level)
        split(@params["2CF#{level}"])
      end

      # key = 1CF#{level}
      def machine_types(level)
        split(@params["1CF#{level}"])
      end

      # key = 3CF#{level}
      # may return nil
      def param_options(level)
        split(@params["3CF#{level}"])
      end

      # key = 4CF#{level}
      # may return nil
      def roles(level)
        split(@params["4CF#{level}"])
      end

      def split(pars)
        pars.split(INI_LINE_SPLIT_PATTERN) if pars
      end

    end

  end
end
