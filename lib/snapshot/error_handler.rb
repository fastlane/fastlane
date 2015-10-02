module Snapshot
  # This classes methods are called when something goes wrong in the building process
  class ErrorHandler
    class TestsFailedException < StandardError
    end

    class << self
      # @param [Array] The output of the errored build (line by line)
      # This method should raise an exception in any case, as the return code indicated a failed build
      def handle_test_error(output, return_code)
        # The order of the handling below is import

        if return_code == 65
          raise TestsFailedException.new("Tests failed - check out the log above".red)
        end

        case output
        when /com\.apple\.CoreSimulator\.SimError/
          print "The simulator failed to launch - retrying..."
        end
      end

      private

      # Just to make things easier
      def print(text)
        Helper.log.error text.red
      end
    end
  end
end
