module Fastlane
  module Actions
    class GitAddAction < Action
      def self.run(params)
        if params[:pathspec]
          paths = params[:pathspec]
          UI.success("Successfully added from \"#{paths}\" 💾.")
        elsif params[:path]
          if params[:path].kind_of?(String)
            paths = params[:path].shellescape
          else
            paths = params[:path].map(&:shellescape).join(' ')
          end
          UI.success("Successfully added \"#{paths}\" 💾.")
        else
          paths = "."
          UI.success("Successfully added all files 💾.")
        end

        result = Actions.sh("git add #{paths}", log: FastlaneCore::Globals.verbose?).chomp
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Directly add the given file or all files"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The file you want to add",
                                       is_string: false,
                                       conflicting_options: [:pathspec],
                                       optional: true,
                                       verify_block: proc do |value|
                                         if value.kind_of?(String)
                                           UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                         else
                                           value.each do |x|
                                             UI.user_error!("Couldn't find file at path '#{x}'") unless File.exist?(x)
                                           end
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :pathspec,
                                       description: "The pathspec you want to add files from",
                                       is_string: true,
                                       conflicting_options: [:path],
                                       optional: true)
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["4brunu", "antondomashnev"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'git_add',
          'git_add(path: "./version.txt")',
          'git_add(path: ["./version.txt", "./changelog.txt"])',
          'git_add(pathspec: "./Frameworks/*")',
          'git_add(pathspec: "*.txt")'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
