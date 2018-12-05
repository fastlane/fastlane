module Fastlane
  module Actions
    class CleanCocoapodsCacheAction < Action
      def self.run(params)
        Actions.verify_gem!('cocoapods')

        cmd = ['pod cache clean']

        cmd << params[:name].to_s if params[:name]
        cmd << '--all'

        Actions.sh(cmd.join(' '))
      end

      def self.description
        'Remove the cache for pods'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "FL_CLEAN_COCOAPODS_CACHE_DEVELOPMENT",
                                       description: "Pod name to be removed from cache",
                                       optional: true,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("You must specify pod name which should be removed from cache") if value.to_s.empty?
                                       end)
        ]
      end

      def self.authors
        ["alexmx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'clean_cocoapods_cache',
          'clean_cocoapods_cache(name: "CACHED_POD")'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
