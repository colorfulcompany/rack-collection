module Rack
  class MaintenanceMode
    class MaintenancePageApp
      def initialize(app, options = {})
        @options = options
      end

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
