module Fastlane
  module Actions
    class BundleInstallAction < Action
      # rubocop:disable Metrics/PerceivedComplexity
      def self.run(params)
        if gemfile_exists?(params)
          cmd = ['bundle install']

          cmd << "--binstubs #{params[:binstubs]}" if params[:binstubs]
          cmd << "--clean" if params[:clean]
          cmd << "--full-index" if params[:full_index]
          cmd << "--gemfile #{params[:gemfile]}" if params[:gemfile]
          cmd << "--jobs #{params[:jobs]}" if params[:jobs]
          cmd << "--local" if params[:local]
          cmd << "--deployment" if params[:deployment]
          cmd << "--no-cache" if params[:no_cache]
          cmd << "--no_prune" if params[:no_prune]
          cmd << "--path #{params[:path]}" if params[:path]
          cmd << "--system" if params[:system]
          cmd << "--quiet" if params[:quiet]
          cmd << "--retry #{params[:retry]}" if params[:retry]
          cmd << "--shebang" if params[:shebang]
          cmd << "--standalone #{params[:standalone]}" if params[:standalone]
          cmd << "--trust-policy" if params[:trust_policy]
          cmd << "--without #{params[:without]}" if params[:without]
          cmd << "--with #{params[:with]}" if params[:with]
          cmd << "--frozen" if params[:frozen]
          cmd << "--redownload" if params[:redownload]

          return sh(cmd.join(' '))
        else
          UI.message("No Gemfile found")
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity

      def self.gemfile_exists?(params)
        possible_gemfiles = ['Gemfile', 'gemfile']
        possible_gemfiles.insert(0, params[:gemfile]) if params[:gemfile]
        possible_gemfiles.each do |gemfile|
          gemfile = File.absolute_path(gemfile)
          return true if File.exist?(gemfile)
          UI.message("Gemfile not found at: '#{gemfile}'")
        end
        return false
      end

      def self.description
        'This action runs `bundle install` (if available)'
      end

      def self.is_supported?(platform)
        true
      end

      def self.author
        ["birmacher", "koglinjg"]
      end

      def self.example_code
        nil
      end

      def self.category
        :misc
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :binstubs,
                                       env_name: "FL_BUNDLE_INSTALL_BINSTUBS",
                                       description: "Generate bin stubs for bundled gems to ./bin",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :clean,
                                       env_name: "FL_BUNDLE_INSTALL_CLEAN",
                                       description: "Run bundle clean automatically after install",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :full_index,
                                       env_name: "FL_BUNDLE_INSTALL_FULL_INDEX",
                                       description: "Use the rubygems modern index instead of the API endpoint",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :gemfile,
                                       env_name: "FL_BUNDLE_INSTALL_GEMFILE",
                                       description: "Use the specified gemfile instead of Gemfile",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :jobs,
                                       env_name: "FL_BUNDLE_INSTALL_JOBS",
                                       description: "Install gems using parallel workers",
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :local,
                                       env_name: "FL_BUNDLE_INSTALL_LOCAL",
                                       description: "Do not attempt to fetch gems remotely and use the gem cache instead",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :deployment,
                                       env_name: "FL_BUNDLE_INSTALL_DEPLOYMENT",
                                       description: "Install using defaults tuned for deployment and CI environments",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :no_cache,
                                       env_name: "FL_BUNDLE_INSTALL_NO_CACHE",
                                       description: "Don't update the existing gem cache",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :no_prune,
                                       env_name: "FL_BUNDLE_INSTALL_NO_PRUNE",
                                       description: "Don't remove stale gems from the cache",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_BUNDLE_INSTALL_PATH",
                                       description: "Specify a different path than the system default ($BUNDLE_PATH or $GEM_HOME). Bundler will remember this value for future installs on this machine",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :system,
                                       env_name: "FL_BUNDLE_INSTALL_SYSTEM",
                                       description: "Install to the system location ($BUNDLE_PATH or $GEM_HOME) even if the bundle was previously installed somewhere else for this application",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :quiet,
                                       env_name: "FL_BUNDLE_INSTALL_QUIET",
                                       description: "Only output warnings and errors",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :retry,
                                       env_name: "FL_BUNDLE_INSTALL_RETRY",
                                       description: "Retry network and git requests that have failed",
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :shebang,
                                       env_name: "FL_BUNDLE_INSTALL_SHEBANG",
                                       description: "Specify a different shebang executable name than the default (usually 'ruby')",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :standalone,
                                       env_name: "FL_BUNDLE_INSTALL_STANDALONE",
                                       description: "Make a bundle that can work without the Bundler runtime",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :trust_policy,
                                       env_name: "FL_BUNDLE_INSTALL_TRUST_POLICY",
                                       description: "Sets level of security when dealing with signed gems. Accepts `LowSecurity`, `MediumSecurity` and `HighSecurity` as values",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :without,
                                       env_name: "FL_BUNDLE_INSTALL_WITHOUT",
                                       description: "Exclude gems that are part of the specified named group",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :with,
                                       env_name: "FL_BUNDLE_INSTALL_WITH",
                                       description: "Include gems that are part of the specified named group",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :frozen,
                                       env_name: "FL_BUNDLE_INSTALL_FROZEN",
                                       description: "Don't allow the Gemfile.lock to be updated after install",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :redownload,
                                       env_name: "FL_BUNDLE_INSTALL_REDOWNLOAD",
                                       description: "Force download every gem, even if the required versions are already available locally",
                                       type: Boolean,
                                       default_value: false)
        ]
      end
    end
  end
end
