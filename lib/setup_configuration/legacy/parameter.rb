module SetupConfiguration

  module Legacy

    class Parameter < SetupConfiguration::Parameter

      def extended?
        dep? || type? || roles? || options?
      end

      def dep?
        @dependency != :none
      end

      def type?
        @machine_type != 0
      end

      def roles?
        @roles != 0
      end

      def roles=(r)
        @roles = r
      end

      def options?
        @options != 0
      end

      def options=(o)
        @options = o
      end

      def param?
        true
      end

    end
    
  end
end
    