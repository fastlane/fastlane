module FastlaneCore
  class Interface
    class FastlaneException < StandardError
      def prefix
        '[FASTLANE_EXCEPTION]'
      end

      def caused_by_calling_ui_method?(method_name: nil)
        return false if backtrace.nil? || backtrace[0].nil? || method_name.nil?
        first_frame = backtrace[0]
        if first_frame.include?(method_name) && first_frame.include?('interface.rb')
          true
        else
          false
        end
      end

      def trim_backtrace(method_name: nil)
        if caused_by_calling_ui_method?(method_name: method_name)
          backtrace.drop(2)
        else
          backtrace
        end
      end

      def could_contain_pii?
        caused_by_calling_ui_method?
      end

      def crash_report_message
        return '' if could_contain_pii?
        exception.message
      end
    end
  end
end
