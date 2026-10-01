module Fastlane
  module Helper
    class DotenvHelper
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
      # then override with all specified extra environments
      def self.load_dot_envs_from(env_cl_param, base_path)
        require 'dotenv'

        # Making sure the default '.env' and '.env.default' get loaded
        env_file = File.join(base_path, '.env')
        env_default_file = File.join(base_path, '.env.default')
        Dotenv.load(env_file, env_default_file)

        return unless env_cl_param

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::ENVIRONMENT] = env_cl_param

        # multiple envs?
        envs = env_cl_param.split(",")

        # Loads .env file for the environment(s) passed in through options
        envs.each do |env|
          env_file = File.join(base_path, ".env.#{env}")
          UI.success("Loading from '#{env_file}'")
          Dotenv.overload(env_file)
        end
      end
    end
  end
end
