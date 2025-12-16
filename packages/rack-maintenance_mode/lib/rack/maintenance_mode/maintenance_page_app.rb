module Rack
  class MaintenanceMode
    class MaintenancePageApp
      #
      # @param [#call] app
      # @param [Hash] options
      #
      def initialize(app, options = {})
        @options = options
      end

      #
      # @param [Hash] env
      # @return [Array(Integer, Hash, Array<String>)]
      #
      def call(env)
        file = @options[:file]

        if file && ::File.exist?(file)
          [503, {}, [::File.read(file)]]
        else
          [503, {}, ["MaintenancePage"]]
        end
      end
    end
  end
end
