module SetupConfiguration

  class SetupCodeBinding < Generator::TemplateBinding

    def initialize
      super
      @longest = nil
    end

    def parameters
      #TODO use set or something similar
      suite.parameters.select() { |p| p.param? }
    end

    #
    # Offset for setup parameter numbers. This offset is added to a parameter number when evaluated in controller.
    #
    def parameter_offset
      1300
    end

    def key(symbol)
      s = symbol.to_s
      delimiter = '_'
      s.split(delimiter).collect() { |splitter| splitter.capitalize }.join(delimiter).ljust(longest_key_length)
    end

    private

    def longest_key_length
      # find the length of the longest word
      unless @longest
        longest = parameters.inject(0) do |memo, param|
          [memo, param.key.to_s.length].max
        end
        @longest = longest + 5
      end
      @longest
    end
    
  end
end