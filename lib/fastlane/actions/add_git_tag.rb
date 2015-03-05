module Fastlane
  module Actions
    # Adds a git tag to the current commit
    class AddGitTagAction
      def self.run(params)
        params = params.first

        grouping      = (params && params[:grouping]) || 'builds'
        prefix        = (params && params[:prefix]) || ''
        build_number  = (params && params[:build_number]) || Actions.lane_context[Actions::SharedValues::BUILD_NUMBER]
        
        lane_name     = Actions.lane_context[Actions::SharedValues::LANE_NAME]

        Actions.sh("git tag #{grouping}/#{lane_name}/#{prefix}#{build_number}")

        Helper.log.info 'Added git tag 🎯.'
      end
    end
  end
end
