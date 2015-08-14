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
        ["set -o pipefail &&"]
      end

      # Path to the project or workspace as parameter
      # This will also include the scheme (if given)
      # @return [Array] The array with all the components to join
      def project_path_array
        config = Gym.config
        proj = []
        proj << "-workspace '#{config[:workspace]}'" if config[:workspace]
        proj << "-scheme '#{config[:scheme]}'" if config[:scheme]
        proj << "-project '#{config[:project]}'" if config[:project]

        return proj if proj.count > 0
        raise "No project/workspace found"
      end

      def options
        config = Gym.config

        options = []
        options += project_path_array
        options << "-configuration '#{config[:configuration]}'" if config[:configuration]
        options << "-sdk '#{config[:sdk]}'" if config[:sdk]
        options << "-destination '#{config[:destination]}'" if config[:destination]
        options << "-xcconfig '#{config[:xcconfig]}'" if config[:xcconfig]
        options << "-archivePath '#{archive_path}'"
        options << config[:xcargs] if config[:xcargs]

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
          day = Time.now.strftime("%F") # e.g. 2015-08-07

          @build_path = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}/")
          FileUtils.mkdir_p @build_path
        end
        @build_path
      end

      def archive_path
        unless @archive_path
          file_name = [Gym.config[:output_name], Time.now.strftime("%F %H.%M.%S")] # e.g. 2015-08-07 14.49.12
          @archive_path = File.join(build_path, file_name.join(" ") + ".xcarchive")
        end
        return @archive_path
      end
    end
  end
end
