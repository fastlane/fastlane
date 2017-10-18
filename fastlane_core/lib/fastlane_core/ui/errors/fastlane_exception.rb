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

      def includes_method_missing?
        return false if backtrace.nil? || backtrace[1].nil?
        second_frame = backtrace[1]
        second_frame.include?('method_missing') && second_frame.include?('ui.rb')
      end

      def trim_backtrace(method_name: nil)
        if caused_by_calling_ui_method?(method_name: method_name)
          if includes_method_missing?
            drop_count = 2
          else
            drop_count = 1
          end
          backtrace.drop(drop_count)
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
