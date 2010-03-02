module SetupConfiguration

  module Legacy

    class Parameter < SetupConfiguration::Parameter
      def initialize(number)
        @number=number
      end

      def extended?
        dep? || type?
      end

      def dep?
        @dependency != :none
      end

      def type?
        @machine_type != 0
      end

    end
    
  end
end
    