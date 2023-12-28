require_relative 'lane_manager_base.rb'

module Fastlane
  class LaneManager < LaneManagerBase
    # @param platform The name of the platform to execute
    # @param lane_name The name of the lane to execute
    # @param parameters [Hash] The parameters passed from the command line to the lane
    # @param A custom Fastfile path, this is used by fastlane.ci
    def self.cruise_lane(platform, lane, parameters = nil, fastfile_path = nil)
      UI.user_error!("lane must be a string") unless lane.kind_of?(String) || lane.nil?
      UI.user_error!("platform must be a string") unless platform.kind_of?(String) || platform.nil?
      UI.user_error!("parameters must be a hash") unless parameters.kind_of?(Hash) || parameters.nil?

      ff = Fastlane::FastFile.new(fastfile_path || FastlaneCore::FastlaneFolder.fastfile_path)

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

      if !platform && lane
        # Either, the user runs a specific lane in root or want to auto complete the available lanes for a platform
        # e.g. `fastlane ios` should list all available iOS actions
        if ff.is_platform_block?(lane)
          platform = lane
          lane = nil
        end
      end

      platform, lane = choose_lane(ff, platform) unless lane

      started = Time.now
      e = nil
      begin
        ff.runner.execute(lane, platform, parameters)
      rescue NameError => ex
        print_lane_context
        print_error_line(ex)
        e = ex
      rescue Exception => ex # rubocop:disable Lint/RescueException
        # We also catch Exception, since the implemented action might send a SystemExit signal
        # (or similar). We still want to catch that, since we want properly finish running fastlane
        # Tested with `xcake`, which throws a `Xcake::Informative` object

        print_lane_context
        print_error_line(ex)
        UI.error(ex.to_s) if ex.kind_of?(StandardError) # we don't want to print things like 'system exit'
        e = ex
      end

      # After running the lanes, since skip_docs might be somewhere in-between
      Fastlane::DocsGenerator.run(ff) unless skip_docs?

      duration = ((Time.now - started) / 60.0).round
      finish_fastlane(ff, duration, e)

      return ff
    end

    def self.skip_docs?
      Helper.test? || FastlaneCore::Env.truthy?("FASTLANE_SKIP_DOCS")
    end

    # Lane chooser if user didn't provide a lane
    # @param platform: is probably nil, but user might have called `fastlane android`, and only wants to list those actions
    def self.choose_lane(ff, platform)
      available = []

      # nil is the key for lanes that are not under a specific platform
      lane_platforms = [nil] + Fastlane::SupportedPlatforms.all
      lane_platforms.each do |p|
        available += ff.runner.lanes[p].to_a.reject { |lane| lane.last.is_private }
      end

      if available.empty?
        UI.user_error!("It looks like you don't have any lanes to run just yet. Check out how to get started here: https://github.com/fastlane/fastlane 🚀")
      end

      rows = []
      available.each_with_index do |lane, index|
        rows << [index + 1, lane.last.pretty_name, lane.last.description.join("\n")]
      end

      rows << [0, "cancel", "No selection, exit fastlane!"]

      require 'terminal-table'

      table = Terminal::Table.new(
        title: "Available lanes to run",
        headings: ['Number', 'Lane Name', 'Description'],
        rows: FastlaneCore::PrintTable.transform_output(rows)
      )

      UI.message("Welcome to fastlane! Here's what your app is set up to do:")

      puts(table)

      fastlane_command = Helper.bundler? ? "bundle exec fastlane" : "fastlane"
      i = UI.input("Which number would you like to run?")

      i = i.to_i - 1
      if i >= 0 && available[i]
        selection = available[i].last.pretty_name
        UI.important("Running lane `#{selection}`. Next time you can do this by directly typing `#{fastlane_command} #{selection}` 🚀.")
        platform = selection.split(' ')[0]
        lane_name = selection.split(' ')[1]

        unless lane_name # no specific platform, just a root lane
          lane_name = platform
          platform = nil
        end

        return platform, lane_name # yeah
      else
        UI.user_error!("Run `#{fastlane_command}` the next time you need to build, test or release your app 🚀")
      end
    end
  end
end
