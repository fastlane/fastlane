module Fastlane
  module Actions
    # Adds a git tag to the current commit
    class AddGitTagAction < Action
      def self.run(params)
        params = params.first

        specified_tag = (params && params[:tag])
        grouping      = (params && params[:grouping]) || 'builds'
        prefix        = (params && params[:prefix]) || ''
        build_number  = (params && params[:build_number]) || Actions.lane_context[Actions::SharedValues::BUILD_NUMBER]
        
        lane_name     = Actions.lane_context[Actions::SharedValues::LANE_NAME]

        tag = specified_tag || "#{grouping}/#{lane_name}/#{prefix}#{build_number}"

        Helper.log.info 'Adding git tag "#{tag}" 🎯.'
        Actions.sh("git tag #{tag}")
      end

      def self.description
        "This will add a git tag to the current branch."
      end

      def self.available_options
        [
          ['tag', 'Define your own tag text. This will replace all other parameters.'],
          ['grouping', 'Is used to keep your tags organised under one "folder". Defaults to "builds"'],
          ['prefix', 'Anything you want to put in front of the version number (e.g. "v").'],
          ['build_number', 'The build number. Defaults to the result of increment_build_number if you\'re using it']
        ]
      end

      def self.author
        "lmirosevic"
      end
    end
  end
end
