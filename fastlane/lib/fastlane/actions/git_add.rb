module Fastlane
  module Actions
    class GitAddAction < Action
      def self.run(params)
        if params[:pathspec]
          paths = params[:pathspec]
          UI.success("Successfully added from \"#{paths}\" 💾.")
        elsif params[:path]
          if params[:path].kind_of?(String)
            paths = params[:path]
          else
            paths = params[:path].join(' ')
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
                                       description: "The file(s) and path(s) you want to add",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :pathspec,
                                       description: "The pathspec you want to add files from",
                                       is_string: true,
                                       optional: true,
                                       deprecated: "Use --path instead")
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
          'git_add(path: "./Frameworks/*")',
          'git_add(path: ["*.h", "*.m"])'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
