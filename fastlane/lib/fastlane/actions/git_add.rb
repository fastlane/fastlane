module Fastlane
  module Actions
    class GitAddAction < Action
      def self.run(params)
        if params[:path].kind_of?(String)
          paths = params[:path].shellescape
        else
          paths = params[:path].map(&:shellescape).join(' ')
        end

        result = Actions.sh("git add #{paths}")
        Helper.log.info "Successfully added \"#{params[:path]}\" 💾.".green
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Directly add the given file"
      end

      def self.details
        ""
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The file you want to add",
                                       is_string: false,
                                       verify_block: proc do |value|
                                         if value.kind_of?(String)
                                           raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                         else
                                           value.each do |x|
                                             raise "Couldn't find file at path '#{x}'".red unless File.exist?(x)
                                           end
                                         end
                                       end)
        ]
      end

      def self.output
      end

      def self.return_value
        nil
      end

      def self.authors
        ["4brunu"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
