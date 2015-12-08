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
        proj = Gym.project.xcodebuild_parameters
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
        suffix = []
        suffix << "CODE_SIGN_IDENTITY='#{Gym.config[:codesigning_identity]}'" if Gym.config[:codesigning_identity]
        suffix
      end

      def pipe
        pipe = []
        pipe << "| tee '#{xcodebuild_log_path}' | xcpretty"
        pipe << "> /dev/null" if Gym.config[:suppress_xcode_output]

        pipe
      end

      def xcodebuild_log_path
        file_name = "#{Gym.project.app_name}-#{Gym.config[:scheme]}.log"
        containing = File.expand_path(Gym.config[:buildlog_path])
        FileUtils.mkdir_p(containing)

        return File.join(containing, file_name)
      end

      # The path to set the Derived Data to
      def build_path
        unless Gym.cache[:build_path]
          day = Time.now.strftime("%F") # e.g. 2015-08-07

          Gym.cache[:build_path] = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}/")
          FileUtils.mkdir_p Gym.cache[:build_path]
        end
        Gym.cache[:build_path]
      end

      def archive_path
        Gym.cache[:archive_path] ||= Gym.config[:archive_path]
        unless Gym.cache[:archive_path]
          file_name = [Gym.config[:output_name], Time.now.strftime("%F %H.%M.%S")] # e.g. 2015-08-07 14.49.12
          Gym.cache[:archive_path] = File.join(build_path, file_name.join(" ") + ".xcarchive")
        end

        if File.extname(Gym.cache[:archive_path]) != ".xcarchive"
          Gym.cache[:archive_path] += ".xcarchive"
        end
        return Gym.cache[:archive_path]
      end
    end
  end
end
