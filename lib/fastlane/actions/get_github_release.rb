module Fastlane
  module Actions
    module SharedValues
      GET_GITHUB_RELEASE_INFO = :GET_GITHUB_RELEASE_INFO
    end

    class GetGithubReleaseAction < Action
      def self.run(params)
        Helper.log.info "Verifying release on GitHub (#{params[:url]}: #{params[:version]})"
        require 'excon'
        result = JSON.parse(Excon.get("https://api.github.com/repos/#{params[:url]}/releases").body)
        result.each do |current|
          if current['tag_name'] == params[:version]
            # Found it
            if current['body'].to_s.length > 0
              Actions.lane_context[SharedValues::GET_GITHUB_RELEASE_INFO] = current
              Helper.log.info "Version is already live on GitHub.com 🚁"
              return current
            else
              raise "No release notes found for #{params[:version]}"
            end
          end 
        end

        raise "Couldn't find release #{params[:version]}, please create one: https://github.com/#{params[:url]}/releases/new".red
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This will verify if a given release version is avialable on GitHub"
      end

      def self.details
        "It's useful to verify the user already provided "
      end

      def self.output
        [
          ['GET_GITHUB_RELEASE_INFO', 'Contains all the information about this release']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "FL_GET_GITHUB_RELEASE_URL",
                                       description: "The path to your repo, e.g. 'KrauseFx/fastlane'",
                                       verify_block: Proc.new do |value|
                                          raise "Please only pass the path, e.g. 'KrauseFx/fastlane'".red if value.include?"github.com"
                                          raise "Please only pass the path, e.g. 'KrauseFx/fastlane'".red if value.split('/').count != 2
                                       end),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_GET_GITHUB_RELEASE_VERSION",
                                       description: "The version tag of the release to check")
        ]
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end