require_relative 'lane_manager_base.rb'
require_relative 'swift_runner_upgrader.rb'

module Fastlane
  class SwiftLaneManager < LaneManagerBase
    # @param lane_name The name of the lane to execute
    # @param parameters [Hash] The parameters passed from the command line to the lane
    def self.cruise_lane(lane, parameters = nil, disable_runner_upgrades: false, swift_server_port: nil)
      UI.user_error!("lane must be a string") unless lane.kind_of?(String) || lane.nil?
      UI.user_error!("parameters must be a hash") unless parameters.kind_of?(Hash) || parameters.nil?

      # Sets environment variable and lane context for lane name
      ENV["FASTLANE_LANE_NAME"] = lane
      Actions.lane_context[Actions::SharedValues::LANE_NAME] = lane

      started = Time.now
      e = nil
      begin
        display_upgraded_message = false
        if disable_runner_upgrades
          UI.verbose("disable_runner_upgrades is true, not attempting to update the FastlaneRunner project".yellow)
        elsif Helper.ci?
          UI.verbose("Running in CI, not attempting to update the FastlaneRunner project".yellow)
        else
          display_upgraded_message = self.ensure_runner_up_to_date_fastlane!
        end

        self.ensure_runner_built!
        swift_server_port ||= 2000
        socket_thread = self.start_socket_thread(port: swift_server_port)
        sleep(0.250) while socket_thread[:ready].nil?
        # wait on socket_thread to be in ready state, then start the runner thread
        self.cruise_swift_lane_in_thread(lane, parameters, swift_server_port)

        socket_thread.value
      rescue Exception => ex # rubocop:disable Lint/RescueException
        e = ex
      end
      # If we have a thread exception, drop that in the exception
      # won't ever have a situation where e is non-nil, and socket_thread[:exception] is also non-nil
      e ||= socket_thread[:exception]

      unless e.nil?
        print_lane_context

        # We also catch Exception, since the implemented action might send a SystemExit signal
        # (or similar). We still want to catch that, since we want properly finish running fastlane
        # Tested with `xcake`, which throws a `Xcake::Informative` object
        UI.error(e.to_s) if e.kind_of?(StandardError) # we don't want to print things like 'system exit'
      end

      skip_message = false

      # if socket_thread is nil, we were probably debugging, or something else weird happened
      exit_reason = :cancelled if socket_thread.nil?

      # normal exit means we have a reason
      exit_reason ||= socket_thread[:exit_reason]

      if exit_reason == :cancelled && e.nil?
        skip_message = true
      end

      duration = ((Time.now - started) / 60.0).round

      finish_fastlane(nil, duration, e, skip_message: skip_message)

      if display_upgraded_message
        UI.message("We updated your FastlaneRunner project during this run to make it compatible with your current version of fastlane.".yellow)
        UI.message("Please make sure to check the changes into source control.".yellow)
      end
    end

    def self.display_lanes
      self.ensure_runner_built!
      return_value = Actions.sh(%(#{FastlaneCore::FastlaneFolder.swift_runner_path} lanes))
      if FastlaneCore::Globals.verbose?
        UI.message("runner output: ".yellow + return_value)
      end
    end

    def self.cruise_swift_lane_in_thread(lane, parameters = nil, swift_server_port)
      if parameters.nil?
        parameters = {}
      end

      parameter_string = ""
      parameters.each do |key, value|
        parameter_string += " #{key} #{value}"
      end

      if FastlaneCore::Globals.verbose?
        parameter_string += " logMode verbose"
      end

      parameter_string += " swiftServerPort #{swift_server_port}"

      return Thread.new do
        if FastlaneCore::Globals.verbose?
          return_value = Actions.sh(%(#{FastlaneCore::FastlaneFolder.swift_runner_path} lane #{lane}#{parameter_string}))
          UI.message("runner output: ".yellow + return_value)
        else
          Actions.sh(%(#{FastlaneCore::FastlaneFolder.swift_runner_path} lane #{lane}#{parameter_string} > /dev/null))
        end
      end
    end

    def self.swap_paths_in_target(file_refs_to_swap: nil, expected_path_to_replacement_path_tuples: nil)
      made_project_updates = false
      file_refs_to_swap.each do |file_ref|
        expected_path_to_replacement_path_tuples.each do |preinstalled_config_relative_path, user_config_relative_path|
          next unless file_ref.path == preinstalled_config_relative_path

          file_ref.path = user_config_relative_path
          made_project_updates = true
        end
      end
      return made_project_updates
    end

    # Find all the config files we care about (Deliverfile, Gymfile, etc), and build tuples of what file we'll look for
    # in the Xcode project, and what file paths we'll need to swap (since we have to inject the user's configs)
    #
    # Return a mapping of what file paths we're looking => new file pathes we'll need to inject
    def self.collect_tool_paths_for_replacement(all_user_tool_file_paths: nil, look_for_new_configs: nil)
      new_user_tool_file_paths = all_user_tool_file_paths.select do |user_config, preinstalled_config_relative_path, user_config_relative_path|
        if look_for_new_configs
          File.exist?(user_config)
        else
          !File.exist?(user_config)
        end
      end

      # Now strip out the fastlane-relative path and leave us with xcodeproj relative paths
      new_user_tool_file_paths = new_user_tool_file_paths.map do |user_config, preinstalled_config_relative_path, user_config_relative_path|
        if look_for_new_configs
          [preinstalled_config_relative_path, user_config_relative_path]
        else
          [user_config_relative_path, preinstalled_config_relative_path]
        end
      end
      return new_user_tool_file_paths
    end

    # open and return the swift project
    def self.runner_project
      runner_project_path = FastlaneCore::FastlaneFolder.swift_runner_project_path
      require 'xcodeproj'
      project = Xcodeproj::Project.open(runner_project_path)
      return project
    end

    # return the FastlaneRunner build target
    def self.target_for_fastlane_runner_project(runner_project: nil)
      fastlane_runner_array = runner_project.targets.select do |target|
        target.name == "FastlaneRunner"
      end

      # get runner target
      runner_target = fastlane_runner_array.first
      return runner_target
    end

    def self.target_source_file_refs(target: nil)
      return target.source_build_phase.files.to_a.map(&:file_ref)
    end

    def self.first_time_setup
      setup_message = ["fastlane is now configured to use a swift-based Fastfile (Fastfile.swift) 🦅"]
      setup_message << "To edit your new Fastfile.swift, type: `open #{FastlaneCore::FastlaneFolder.swift_runner_project_path}`"

      # Go through and link up whatever we generated during `fastlane init swift` so the user can edit them easily
      self.link_user_configs_to_project(updated_message: setup_message.join("\n"))
    end

    def self.link_user_configs_to_project(updated_message: nil)
      tool_files_folder = FastlaneCore::FastlaneFolder.path

      # All the tools that could have <tool name>file.swift their paths, and where we expect to find the user's tool files.
      all_user_tool_file_paths = TOOL_CONFIG_FILES.map do |tool_name|
        [
          File.join(tool_files_folder, "#{tool_name}.swift"),
          "../#{tool_name}.swift",
          "../../#{tool_name}.swift"
        ]
      end

      # Tool files the user now provides
      new_user_tool_file_paths = collect_tool_paths_for_replacement(all_user_tool_file_paths: all_user_tool_file_paths, look_for_new_configs: true)

      # Tool files we provide AND the user doesn't provide
      user_tool_files_possibly_removed = collect_tool_paths_for_replacement(all_user_tool_file_paths: all_user_tool_file_paths, look_for_new_configs: false)

      fastlane_runner_project = self.runner_project
      runner_target = target_for_fastlane_runner_project(runner_project: fastlane_runner_project)
      target_file_refs = target_source_file_refs(target: runner_target)

      # Swap in all new user supplied configs into the project
      project_modified = swap_paths_in_target(
        file_refs_to_swap: target_file_refs,
        expected_path_to_replacement_path_tuples: new_user_tool_file_paths
      )

      # Swap out any configs the user has removed, inserting fastlane defaults
      project_modified = swap_paths_in_target(
        file_refs_to_swap: target_file_refs,
        expected_path_to_replacement_path_tuples: user_tool_files_possibly_removed
      ) || project_modified

      if project_modified
        fastlane_runner_project.save
        updated_message ||= "Updated #{FastlaneCore::FastlaneFolder.swift_runner_project_path}"
        UI.success(updated_message)
      else
        UI.success("FastlaneSwiftRunner project is up-to-date")
      end

      return project_modified
    end

    def self.start_socket_thread(port: nil)
      require 'fastlane/server/socket_server'
      require 'fastlane/server/socket_server_action_command_executor'

      return Thread.new do
        command_executor = SocketServerActionCommandExecutor.new
        server = Fastlane::SocketServer.new(command_executor: command_executor, port: port)
        server.start
      end
    end

    def self.ensure_runner_built!
      UI.verbose("Checking for new user-provided tool configuration files")
      # if self.link_user_configs_to_project returns true, that means we need to rebuild the runner
      runner_needs_building = self.link_user_configs_to_project

      if FastlaneCore::FastlaneFolder.swift_runner_built?
        runner_last_modified_age = File.mtime(FastlaneCore::FastlaneFolder.swift_runner_path).to_i
        fastfile_last_modified_age = File.mtime(FastlaneCore::FastlaneFolder.fastfile_path).to_i

        if runner_last_modified_age < fastfile_last_modified_age
          # It's older than the Fastfile, so build it again
          UI.verbose("Found changes to user's Fastfile.swift, setting re-build runner flag")
          runner_needs_building = true
        end
      else
        # Runner isn't built yet, so build it
        UI.verbose("No runner found, setting re-build runner flag")
        runner_needs_building = true
      end

      if runner_needs_building
        self.build_runner!
      end
    end

    # do we have the latest FastlaneSwiftRunner code from the current version of fastlane?
    def self.ensure_runner_up_to_date_fastlane!
      upgraded = false
      upgrader = SwiftRunnerUpgrader.new

      upgrade_needed = upgrader.upgrade_if_needed!(dry_run: true)
      if upgrade_needed
        UI.message("It looks like your `FastlaneSwiftRunner` project is not up-to-date".green)
        UI.message("If you don't update it, fastlane could fail".green)
        UI.message("We can try to automatically update it for you, usually this works 🎈 🐐".green)
        user_wants_upgrade = UI.confirm("Should we try to upgrade just your `FastlaneSwiftRunner` project?")

        UI.important("Ok, if things break, you can try to run this lane again and you'll be prompted to upgrade another time") unless user_wants_upgrade

        if user_wants_upgrade
          upgraded = upgrader.upgrade_if_needed!
          UI.success("Updated your FastlaneSwiftRunner project with the newest runner code") if upgraded
          self.build_runner! if upgraded
        end
      end

      return upgraded
    end

    def self.build_runner!
      UI.verbose("Building FastlaneSwiftRunner")
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
        print_command: !Gym.config[:silent]
      )
    end
  end
end
