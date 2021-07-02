
module FastlaneCore
  module XcodebuildFormatter

    module Xcpretty
      def format
        formatter = ['xcpretty']

        if Helper.colors_disabled?
          formatter << "--no-color"
        end

        return formatter.join(' ')
      end
    end

    module Xcbeautify
      def format
        formatter = ['xcbeautify']

        if Helper.colors_disabled?
          formatter << "--disable-colored-output"
        end

        return formatter.join(' ')
      end
    end

  end
end