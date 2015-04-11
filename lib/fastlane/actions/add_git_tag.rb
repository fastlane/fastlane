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
    end
  end
end
