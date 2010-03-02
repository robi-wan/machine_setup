module SetupConfiguration

  module Legacy

    class Category
      include Enumerable

      attr_accessor :number
      attr_accessor :name
      attr_accessor :parameter

      def initialize()
        @parameter = []
      end

      def <=>(parameter)
        self.number <=> parameter.number
      end

    end
  end
end
