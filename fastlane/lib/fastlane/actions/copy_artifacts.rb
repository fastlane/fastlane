module Fastlane
  module Actions
    class CopyArtifactsAction < Action
      def self.run(params)
        # we want to make sure that our target folder exist already
        target_folder_command = 'mkdir -p ' + params[:target_path]
        Actions.sh(target_folder_command)

        # construct the main command that will do the copying/moving for us
        base_command = params[:keep_original] ? 'cp' : 'mv'
        options = []
        options << '-f'
        options << '-r' if params[:keep_original] # we only want the -r flag for the cp command, which we get when the user asks to keep the original
        options << params[:artifacts].map { |e| e.tr(' ', '\ ') }
        options << params[:target_path]

        command = ([base_command] + options).join(' ')

        # if we don't want to fail on missing files, then we need to swallow the error from our command, by ORing with the nil command, guaranteeing a 0 status code
        command += ' || :' unless params[:fail_on_missing]

        # call our command
        Actions.sh(command)

        Helper.log.info 'Build artifacts sucesfully copied!'.green
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Small action to save your build artifacts. Useful when you use reset_git_repo"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :keep_original,
                                       description: "Set this to true if you want copy, rather than move, semantics",
                                       is_string: false,
                                       optional: true,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :target_path,
                                       description: "The directory in which you want your artifacts placed",
                                       is_string: false,
                                       optional: false,
                                       default_value: 'artifacts'),
          FastlaneCore::ConfigItem.new(key: :artifacts,
                                       description: "An array of file patterns of the files/folders you want to preserve",
                                       is_string: false,
                                       optional: false,
                                       default_value: []),
          FastlaneCore::ConfigItem.new(key: :fail_on_missing,
                                       description: "Fail when a source file isn't found",
                                       is_string: false,
                                       optional: true,
                                       default_value: false)
        ]
      end

      def self.authors
        ["lmirosevic"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
