module Fastlane
  class LaneManager
    # @param platform The name of the platform to execute
    # @param lane_name The name of the lane to execute
    # @param parameters [Hash] The parameters passed from the command line to the lane
    # @param env Dot Env Information
    def self.cruise_lane(platform, lane, parameters = nil, env = nil)
      UI.user_error!("lane must be a string") unless lane.kind_of?(String) or lane.nil?
      UI.user_error!("platform must be a string") unless platform.kind_of?(String) or platform.nil?
      UI.user_error!("parameters must be a hash") unless parameters.kind_of?(Hash) or parameters.nil?

      ff = Fastlane::FastFile.new(Fastlane::FastlaneFolder.fastfile_path)

      is_platform = false
      begin
        is_platform = ff.is_platform_block?(lane)
      rescue # rescue, because this raises an exception if it can't be found at all
      end

      unless is_platform
        # maybe the user specified a default platform
        # We'll only do this, if the lane specified isn't a platform, as we want to list all platforms then

        # Make sure that's not a lane without a platform
        unless ff.runner.available_lanes.include?(lane)
          platform ||= Actions.lane_context[Actions::SharedValues::DEFAULT_PLATFORM]
        end
      end

      if !platform and lane
        # Either, the user runs a specific lane in root or want to auto complete the available lanes for a platform
        # e.g. `fastlane ios` should list all available iOS actions
        if ff.is_platform_block?(lane)
          platform = lane
          lane = nil
        end
      end

      platform, lane = choose_lane(ff, platform) unless lane

      # xcodeproj has a bug in certain versions that causes it to change directories
      # and not return to the original working directory
      # https://github.com/CocoaPods/Xcodeproj/issues/426
      # Setting this environment variable causes xcodeproj to work around the problem
      ENV["FORK_XCODE_WRITING"] = "true" unless platform == 'android'

      load_dot_env(env)

      started = Time.now
      e = nil
      begin
        ff.runner.execute(lane, platform, parameters)
      rescue Exception => ex # rubocop:disable Lint/RescueException
        # We also catch Exception, since the implemented action might send a SystemExit signal
        # (or similar). We still want to catch that, since we want properly finish running fastlane
        # Tested with `xcake`, which throws a `Xcake::Informative` object

        UI.important 'Variable Dump:'.yellow
        UI.message Actions.lane_context
        UI.error ex.to_s if ex.kind_of?(StandardError) # we don't want to print things like 'system exit'
        e = ex
      end

      # After running the lanes, since skip_docs might be somewhere in-between
      Fastlane::DocsGenerator.run(ff) unless ENV["FASTLANE_SKIP_DOCS"]

      duration = ((Time.now - started) / 60.0).round

      finish_fastlane(ff, duration, e)

      return ff
    end

    # All the finishing up that needs to be done
    def self.finish_fastlane(ff, duration, error)
      ff.runner.did_finish

      # Finished with all the lanes
      Fastlane::JUnitGenerator.generate(Fastlane::Actions.executed_actions)
      print_table(Fastlane::Actions.executed_actions)

      Fastlane::PluginUpdateManager.show_update_status

      if error
        UI.error 'fastlane finished with errors'
        raise error
      elsif duration > 5
        UI.success "fastlane.tools just saved you #{duration} minutes! 🎉"
      else
        UI.success 'fastlane.tools finished successfully 🎉'
      end
    end

    # Print a table as summary of the executed actions
    def self.print_table(actions)
      return if actions.count == 0

      require 'terminal-table'

      rows = []
      actions.each_with_index do |current, i|
        is_error_step = !current[:error].to_s.empty?

        name = current[:name][0..60]
        name = name.red if is_error_step
        index = i + 1
        index = "💥" if is_error_step
        rows << [index, name, current[:time].to_i]
      end

      puts ""
      puts Terminal::Table.new(
        title: "fastlane summary".green,
        headings: ["Step", "Action", "Time (in s)"],
        rows: rows
      )
      puts ""
    end

    # Lane chooser if user didn't provide a lane
    # @param platform: is probably nil, but user might have called `fastlane android`, and only wants to list those actions
    def self.choose_lane(ff, platform)
      available = ff.runner.lanes[platform].to_a.reject { |lane| lane.last.is_private }
      if available.empty?
        UI.user_error! "It looks like you don't have any lanes to run just yet. Check out how to get started here: https://github.com/fastlane/fastlane 🚀"
      end

      rows = []
      available.each_with_index do |lane, index|
        rows << [index + 1, lane.last.pretty_name, lane.last.description.join("\n")]
      end

      rows << [0, "cancel", "No selection, exit fastlane!"]

      table = Terminal::Table.new(
        title: "Available lanes to run",
        headings: ['Number', 'Lane Name', 'Description'],
        rows: rows
      )

      UI.message "Welcome to fastlane! Here's what your app is setup to do:"

      puts table

      i = UI.input "Which number would you like run?"

      i = i.to_i - 1
      if i >= 0 && available[i]
        selection = available[i].last.pretty_name
        UI.important "Running lane `#{selection}`. Next time you can do this by directly typing `fastlane #{selection}` 🚀."
        platform = selection.split(' ')[0]
        lane_name = selection.split(' ')[1]

        unless lane_name # no specific platform, just a root lane
          lane_name = platform
          platform = nil
        end

        return platform, lane_name # yeah
      else
        UI.user_error! "Run `fastlane` the next time you need to build, test or release your app 🚀"
      end
    end

    def self.load_dot_env(env)
      return if Dir.glob("**/*.env*", File::FNM_DOTMATCH).count == 0
      require 'dotenv'

      Actions.lane_context[Actions::SharedValues::ENVIRONMENT] = env if env

      # Making sure the default '.env' and '.env.default' get loaded
      env_file = File.join(Fastlane::FastlaneFolder.path || "", '.env')
      env_default_file = File.join(Fastlane::FastlaneFolder.path || "", '.env.default')
      Dotenv.load(env_file, env_default_file)

      # Loads .env file for the environment passed in through options
      if env
        env_file = File.join(Fastlane::FastlaneFolder.path || "", ".env.#{env}")
        UI.success "Loading from '#{env_file}'"
        Dotenv.overload(env_file)
      end
    end
  end
end
