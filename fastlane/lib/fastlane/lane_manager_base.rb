module Fastlane
  # Base class for all LaneManager classes
  # Takes care of all common things like printing the lane description tables and loading .env files
  class LaneManagerBase
    def self.skip_docs?
      Helper.test? || FastlaneCore::Env.truthy?("FASTLANE_SKIP_DOCS")
    end

    # All the finishing up that needs to be done
    def self.finish_fastlane(ff, duration, error, skip_message: false)
      # Sometimes we don't have a fastfile because we're using Fastfile.swift
      unless ff.nil?
        ff.runner.did_finish
      end

      # Finished with all the lanes
      Fastlane::JUnitGenerator.generate(Fastlane::Actions.executed_actions)
      print_table(Fastlane::Actions.executed_actions)

      Fastlane::PluginUpdateManager.show_update_status

      if error
        UI.error('fastlane finished with errors') unless skip_message
        raise error
      elsif duration > 5
        UI.success("fastlane.tools just saved you #{duration} minutes! 🎉") unless skip_message
      else
        UI.success('fastlane.tools finished successfully 🎉') unless skip_message
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

      puts("")
      puts(Terminal::Table.new(
             title: "fastlane summary".green,
             headings: ["Step", "Action", "Time (in s)"],
             rows: FastlaneCore::PrintTable.transform_output(rows)
      ))
      puts("")
    end

    # @param env_cl_param [String] an optional list of dotenv environment names separated by commas, without space
    def self.load_dot_env(env_cl_param)
      base_path = find_dotenv_directory

      return unless base_path

      load_dot_envs_from(env_cl_param, base_path)
    end

    # finds the first directory of [fastlane, its parent] containing dotenv files
    def self.find_dotenv_directory
      path = FastlaneCore::FastlaneFolder.path
      search_paths = [path]
      search_paths << path + "/.." unless path.nil?
      search_paths.compact!
      search_paths.find do |dir|
        Dir.glob(File.join(dir, '*.env*'), File::FNM_DOTMATCH).count > 0
      end
    end

    # loads the dotenvs. First the .env and .env.default and
    # then override with all speficied extra environments
    def self.load_dot_envs_from(env_cl_param, base_path)
      require 'dotenv'

      # Making sure the default '.env' and '.env.default' get loaded
      env_file = File.join(base_path, '.env')
      env_default_file = File.join(base_path, '.env.default')
      Dotenv.load(env_file, env_default_file)

      return unless env_cl_param

      Actions.lane_context[Actions::SharedValues::ENVIRONMENT] = env_cl_param

      # multiple envs?
      envs = env_cl_param.split(",")

      # Loads .env file for the environment(s) passed in through options
      envs.each do |env|
        env_file = File.join(base_path, ".env.#{env}")
        UI.success("Loading from '#{env_file}'")
        Dotenv.overload(env_file)
      end
    end

    def self.print_lane_context
      return if Actions.lane_context.empty?

      if FastlaneCore::Globals.verbose?
        UI.important('Lane Context:'.yellow)
        UI.message(Actions.lane_context)
        return
      end

      # Print a nice table unless in FastlaneCore::Globals.verbose? mode
      rows = Actions.lane_context.collect do |key, content|
        [key, content.to_s]
      end

      require 'terminal-table'
      puts(Terminal::Table.new({
        title: "Lane Context".yellow,
        rows: FastlaneCore::PrintTable.transform_output(rows)
      }))
    end
  end
end
