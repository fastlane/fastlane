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
        UI.success("Successfully added \"#{params[:path]}\" 💾.")
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Directly add the given file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The file you want to add",
                                       is_string: false,
                                       verify_block: proc do |value|
                                         if value.kind_of?(String)
                                           UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                         else
                                           value.each do |x|
                                             UI.user_error!("Couldn't find file at path '#{x}'") unless File.exist?(x)
                                           end
                                         end
                                       end)
        ]
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

      def self.example_code
        [
          'git_add(path: "./version.txt")',
          'git_add(path: ["./version.txt", "./changelog.txt"])'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
