require_relative 'lane_manager_base.rb'

module Fastlane
  class SwiftLaneManager < LaneManagerBase
    # @param lane_name The name of the lane to execute
    # @param parameters [Hash] The parameters passed from the command line to the lane
    # @param env Dot Env Information
    def self.cruise_lane(lane, parameters = nil, env = nil)
      UI.user_error!("lane must be a string") unless lane.kind_of?(String) or lane.nil?
      UI.user_error!("parameters must be a hash") unless parameters.kind_of?(Hash) or parameters.nil?

      # xcodeproj has a bug in certain versions that causes it to change directories
      # and not return to the original working directory
      # https://github.com/CocoaPods/Xcodeproj/issues/426
      # Setting this environment variable causes xcodeproj to work around the problem
      ENV["FORK_XCODE_WRITING"] = "true"

      load_dot_env(env)

      started = Time.now
      e = nil
      begin
        self.ensure_runner_built!
        socket_thread = self.start_socket_thread
        sleep(0.250) while socket_thread[:ready].nil?
        # wait on socket_thread to be in ready state, then start the runner thread
        runner_thread = self.cruise_swift_lane_in_thread(lane, parameters)

        runner_thread.join
        socket_thread.join
      rescue Exception => ex # rubocop:disable Lint/RescueException
        # We also catch Exception, since the implemented action might send a SystemExit signal
        # (or similar). We still want to catch that, since we want properly finish running fastlane
        # Tested with `xcake`, which throws a `Xcake::Informative` object

        print_lane_context
        UI.error ex.to_s if ex.kind_of?(StandardError) # we don't want to print things like 'system exit'
        e = ex
      end

      duration = ((Time.now - started) / 60.0).round

      finish_fastlane(nil, duration, e)
    end

    def self.cruise_swift_lane_in_thread(lane, parameters = nil)
      parameter_string = ""
      parameters.each do |key, value|
        parameter_string += " #{key} #{value}"
      end

      return Thread.new do
        Actions.sh(%(#{FastlaneCore::FastlaneFolder.swift_runner_path} lane #{lane}#{parameter_string} > /dev/null))
      end
    end

    def self.start_socket_thread
      require 'fastlane/server/socket_server'
      require 'fastlane/server/socket_server_action_command_executor'

      return Thread.new do
        command_executor = SocketServerActionCommandExecutor.new
        server = Fastlane::SocketServer.new(command_executor: command_executor)
        server.start
      end
    end

    def self.ensure_runner_built!
      if FastlaneCore::FastlaneFolder.swift_runner_built?
        runner_last_modified_age = File.mtime(FastlaneCore::FastlaneFolder.swift_runner_path).to_i
        fastfile_last_modified_age = File.mtime(FastlaneCore::FastlaneFolder.fastfile_path).to_i

        if runner_last_modified_age < fastfile_last_modified_age
          # It's older than the Fastfile, so build it again
          self.build_runner!
        end
      else
        # Runner isn't built yet, so build it
        self.build_runner!
      end
    end

    def self.build_runner!
      require 'fastlane_core'
      require 'gym'
      require 'gym/generators/build_command_generator'

      project_options = {
          project: FastlaneCore::FastlaneFolder.swift_runner_project_path,
          skip_archive: true
        }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, project_options)
      build_command = Gym::BuildCommandGenerator.generate

      FastlaneCore::CommandExecutor.execute(
        command: build_command,
        print_all: false,
        print_command: !Gym.config[:silent],
        error: proc do |output|
          ErrorHandler.handle_build_error(output)
        end
      )
    end
  end
end
