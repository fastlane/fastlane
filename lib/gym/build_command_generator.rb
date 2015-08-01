module Gym
  # Responsible for building the fully working xcodebuild command
  class BuildCommandGenerator
    class << self
      def generate
        parts = prefix
        parts << "xcodebuild"
        parts += options
        parts += actions
        parts += suffix
        parts += pipe

        parts
      end

      def prefix
        ["set -o pipefail && "]
      end

      # Path to the project or workspace as parameter
      def project_path_string
        config = Gym.config
        return "-workspace '#{config[:workspace]}'" if config[:workspace]
        return "-project '#{config[:project]}'" if config[:project]
        raise "No project/workspace found"
      end

      def options
        config = Gym.config

        options = []
        options << project_path_string
        options << "-configuration Release" # We need `Release` to export the DSYM file as well
        options << "-scheme '#{config[:scheme]}'" if config[:scheme]
        options << "-archivePath '#{archive_path}'"

        options
      end

      def actions
        config = Gym.config

        actions = []
        actions << :clean if config[:clean]
        actions << :archive

        actions
      end

      def suffix
        []
      end

      def pipe
        ["| xcpretty"]
      end

      # The path to set the Derived Data to
      def build_path
        unless @build_path
          @build_path = "/tmp/gym/#{Time.now.to_i}/"
          FileUtils.mkdir_p @build_path
        end
        @build_path
      end

      def archive_path
        File.join(build_path, "Archive.xcarchive")
      end
    end
  end
end
