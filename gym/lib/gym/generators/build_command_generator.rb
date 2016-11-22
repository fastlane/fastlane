require 'shellwords'

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
        UI.user_error!("No project/workspace found")
      end

      def options
        config = Gym.config

        options = []
        options += project_path_array
        options << "-sdk '#{config[:sdk]}'" if config[:sdk]
        options << "-toolchain '#{config[:toolchain]}'" if config[:toolchain]
        options << "-destination '#{config[:destination]}'" if config[:destination]
        options << "-xcconfig '#{config[:xcconfig]}'" if config[:xcconfig]
        options << "-archivePath #{archive_path.shellescape}"
        options << "-derivedDataPath '#{config[:derived_data_path]}'" if config[:derived_data_path]
        options << "-resultBundlePath '#{result_bundle_path}'" if config[:result_bundle]
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
        suffix << "CODE_SIGN_IDENTITY=#{Gym.config[:codesigning_identity].shellescape}" if Gym.config[:codesigning_identity]
        suffix
      end

      def pipe
        pipe = []
        pipe << "| tee #{xcodebuild_log_path.shellescape}"
        unless Gym.config[:disable_xcpretty]
          formatter = Gym.config[:xcpretty_formatter]
          pipe << "| xcpretty"
          pipe << " --test" if Gym.config[:xcpretty_test_format]
          pipe << " --no-color" if Helper.colors_disabled?
          pipe << " --formatter " if formatter
          pipe << formatter if formatter
          report_output_junit = Gym.config[:xcpretty_report_junit]
          report_output_html = Gym.config[:xcpretty_report_html]
          report_output_json = Gym.config[:xcpretty_report_json]
          if report_output_junit
            pipe << " --report junit --output "
            pipe << report_output_junit.shellescape
          elsif report_output_html
            pipe << " --report html --output "
            pipe << report_output_html.shellescape
          elsif report_output_json
            pipe << " --report json-compilation-database --output "
            pipe << report_output_json.shellescape
          end
        end
        pipe << "> /dev/null" if Gym.config[:suppress_xcode_output]

        pipe
      end

      def xcodebuild_log_path
        file_name = "#{Gym.project.app_name}-#{Gym.config[:scheme]}.log"
        containing = File.expand_path(Gym.config[:buildlog_path])
        FileUtils.mkdir_p(containing)

        return File.join(containing, file_name)
      end

      # The path where archive will be created
      def build_path
        unless Gym.cache[:build_path]
          Gym.cache[:build_path] = Gym.config[:build_path]
          unless Gym.cache[:build_path]
            day = Time.now.strftime("%F") # e.g. 2015-08-07
            Gym.cache[:build_path] = File.expand_path("~/Library/Developer/Xcode/Archives/#{day}/")
          end
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

      def result_bundle_path
        unless Gym.cache[:result_bundle_path]
          Gym.cache[:result_bundle_path] = File.join(Gym.config[:output_directory], Gym.config[:output_name]) + ".result"
        end
        return Gym.cache[:result_bundle_path]
      end
    end
  end
end
