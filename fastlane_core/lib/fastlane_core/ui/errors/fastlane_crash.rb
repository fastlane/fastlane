require_relative 'fastlane_exception'

module FastlaneCore
  class Interface
    class FastlaneCrash < FastlaneException
      def prefix
        '[FASTLANE_CRASH]'
      end

      def trimmed_backtrace
        trim_backtrace(method_name: 'crash!')
      end

      def could_contain_pii?
        caused_by_calling_ui_method?(method_name: 'crash!')
      end
    end
  end
end
