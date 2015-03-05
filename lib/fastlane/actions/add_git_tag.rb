module Fastlane
  module Actions
    # Adds a git tag to the current commit
    class AddGitTagAction
      def self.run(params)
        params = params.first

        grouping  = (params && params[:grouping]) || 'builds'
        prefix    = (params && params[:prefix]) || ''

        lane_name = Actions.lane_context[Actions::SharedValues::LANE_NAME]
        build_version = Actions.lane_context[Actions::SharedValues::BUILD_NUMBER]

        Actions.sh("git tag #{grouping}/#{lane_name}/#{prefix}#{build_version}")

        Helper.log.info 'Added git tag 🎯.'
      end
    end
  end
end
