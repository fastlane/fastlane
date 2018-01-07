# rubocop:disable all
module Fastlane
  module Actions
    module SharedValues
      XCODEBUILD_ARCHIVE = :XCODEBUILD_ARCHIVE
      XCODEBUILD_DERIVED_DATA_PATH = :XCODEBUILD_DERIVED_DATA_PATH
    end

    # xcodebuild man page:
    # https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html

    class XcodebuildAction < Action
      ARGS_MAP = {
        # actions
        analyze: "analyze",
        archive: "archive",
        build: "build",
        clean: "clean",
        install: "install",
        installsrc: "installsrc",
        test: "test",

        # parameters
        alltargets: "-alltargets",
        arch: "-arch",
        archive_path: "-archivePath",
        configuration: "-configuration",
        derivedDataPath: "-derivedDataPath",
        destination_timeout: "-destination-timeout",
        dry_run: "-dry-run",
        enableAddressSanitizer: "-enableAddressSanitizer",
        enableThreadSanitizer: "-enableThreadSanitizer",
        enableCodeCoverage: "-enableCodeCoverage",
        export_archive: "-exportArchive",
        export_format: "-exportFormat",
        export_installer_identity: "-exportInstallerIdentity",
        export_options_plist: "-exportOptionsPlist",
        export_path: "-exportPath",
        export_profile: "-exportProvisioningProfile",
        export_signing_identity: "-exportSigningIdentity",
        export_with_original_signing_identity: "-exportWithOriginalSigningIdentity",
        hide_shell_script_environment: "-hideShellScriptEnvironment",
        jobs: "-jobs",
        parallelize_targets: "-parallelizeTargets",
        project: "-project",
        result_bundle_path: "-resultBundlePath",
        scheme: "-scheme",
        sdk: "-sdk",
        skip_unavailable_actions: "-skipUnavailableActions",
        target: "-target",
        toolchain: "-toolchain",
        workspace: "-workspace",
        xcconfig: "-xcconfig"
      }

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.example_code
        [
          'xcodebuild(
            archive: true,
            archive_path: "./build-dir/MyApp.xcarchive",
            scheme: "MyApp",
            workspace: "MyApp.xcworkspace"
          )'
        ]
      end

      def self.category
        :building
      end

      def self.run(params)
        unless Helper.test?
          UI.user_error!("xcodebuild not installed") if `which xcodebuild`.length == 0
        end

        # The args we will build with
        xcodebuild_args = Array[]

        # Supported ENV vars
        build_path    = ENV["XCODE_BUILD_PATH"] || nil
        scheme        = ENV["XCODE_SCHEME"]
        workspace     = ENV["XCODE_WORKSPACE"]
        project       = ENV["XCODE_PROJECT"]
        buildlog_path = ENV["XCODE_BUILDLOG_PATH"]

        # Set derived data path.
        params[:derivedDataPath] ||= ENV["XCODE_DERIVED_DATA_PATH"]
        Actions.lane_context[SharedValues::XCODEBUILD_DERIVED_DATA_PATH] = params[:derivedDataPath]

        # Append slash to build path, if needed
        if build_path && !build_path.end_with?("/")
          build_path += "/"
        end

        # By default we use xcpretty
        raw_buildlog = false

        # By default we don't pass the utf flag
        xcpretty_utf = false

        if params
          # Operation bools
          archiving    = params.key? :archive
          exporting    = params.key? :export_archive
          testing      = params.key? :test
          xcpretty_utf = params[:xcpretty_utf]

          if params.key? :raw_buildlog
            raw_buildlog = params[:raw_buildlog]
          end

          if exporting
            # If not passed, retrieve path from previous xcodebuild call
            params[:archive_path] ||= Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE]

            # If not passed, construct export path from env vars
            if params[:export_path].nil?
              ipa_filename = scheme ? scheme : File.basename(params[:archive_path], ".*")
              params[:export_path] = "#{build_path}#{ipa_filename}"
            end

            # Default to ipa as export format
            export_format = params[:export_format] || "ipa"

            # Store IPA path for later deploy steps (i.e. Crashlytics)
            Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = params[:export_path] + "." + export_format.downcase
          else
            # If not passed, check for archive scheme & workspace/project env vars
            params[:scheme] ||= scheme
            params[:workspace] ||= workspace
            params[:project] ||= project

            # If no project or workspace was passed in or set as an environment
            # variable, attempt to autodetect the workspace.
            if params[:project].to_s.empty? && params[:workspace].to_s.empty?
              params[:workspace] = detect_workspace
            end
          end

          if archiving
            # If not passed, construct archive path from env vars
            params[:archive_path] ||= "#{build_path}#{params[:scheme]}.xcarchive"

            # Cache path for later xcodebuild calls
            Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE] = params[:archive_path]
          end

          if params.key? :enable_address_sanitizer
            params[:enableAddressSanitizer] = params[:enable_address_sanitizer] ? 'YES' : 'NO'
          end
          if params.key? :enable_thread_sanitizer
            params[:enableThreadSanitizer] = params[:enable_thread_sanitizer] ? 'YES' : 'NO'
          end
          if params.key? :enable_code_coverage
            params[:enableCodeCoverage] = params[:enable_code_coverage] ? 'YES' : 'NO'
          end

          # Maps parameter hash to CLI args
          params = export_options_to_plist(params)
          if hash_args = hash_to_args(params)
            xcodebuild_args += hash_args
          end

          buildlog_path ||= params[:buildlog_path]
        end

        # By default we put xcodebuild.log in the Logs folder
        buildlog_path ||= File.expand_path("#{FastlaneCore::Helper.buildlog_path}/fastlane/xcbuild/#{Time.now.strftime('%F')}/#{Process.pid}")

        # Joins args into space delimited string
        xcodebuild_args = xcodebuild_args.join(" ")

        # Default args
        xcpretty_args = []

        # Formatting style
        if params && params[:output_style]
          output_style = params[:output_style]
          UI.user_error!("Invalid output_style #{output_style}") unless [:standard, :basic].include?(output_style)
        else
          output_style = :standard
        end

        case output_style
        when :standard
          xcpretty_args << '--color' unless Helper.colors_disabled?
        when :basic
          xcpretty_args << '--no-utf'
        end

        if testing
          if params[:reports]
            # New report options format
            reports = params[:reports].reduce("") do |arguments, report|
              report_string = "--report #{report[:report]}"

              if report[:output]
                report_string << " --output \"#{report[:output]}\""
              elsif report[:report] == 'junit'
                report_string << " --output \"#{build_path}report/report.xml\""
              elsif report[:report] == 'html'
                report_string << " --output \"#{build_path}report/report.html\""
              elsif report[:report] == 'json-compilation-database'
                report_string << " --output \"#{build_path}report/report.json\""
              end

              if report[:screenshots]
                report_string << " --screenshots"
              end

              unless arguments == ""
                arguments << " "
              end

              arguments << report_string
            end

            xcpretty_args.push reports

          elsif params[:report_formats]
            # Test report file format
            report_formats = params[:report_formats].map do |format|
              "--report #{format}"
            end.sort.join(" ")

            xcpretty_args.push report_formats

            # Save screenshots flag
            if params[:report_formats].include?("html") && params[:report_screenshots]
              xcpretty_args.push "--screenshots"
            end

            xcpretty_args.sort!

            # Test report file path
            if params[:report_path]
              xcpretty_args.push "--output \"#{params[:report_path]}\""
            elsif build_path
              xcpretty_args.push "--output \"#{build_path}report\""
            end
          end
        end

        # Stdout format
        if testing && !archiving
          xcpretty_args << (params[:xcpretty_output] ? "--#{params[:xcpretty_output]}" : "--test")
        else
          xcpretty_args << (params[:xcpretty_output] ? "--#{params[:xcpretty_output]}" : "--simple")
        end

        xcpretty_args = xcpretty_args.join(" ")

        xcpretty_command = ""
        xcpretty_command = "| xcpretty #{xcpretty_args}" unless raw_buildlog
        unless raw_buildlog
          xcpretty_command = "#{xcpretty_command} --utf" if xcpretty_utf
        end

        pipe_command = "| tee '#{buildlog_path}/xcodebuild.log' #{xcpretty_command}"

        FileUtils.mkdir_p buildlog_path
        UI.message("For a more detailed xcodebuild log open #{buildlog_path}/xcodebuild.log")

        output_result = ""

        # In some cases the simulator is not booting up in time
        # One way to solve it is to try to rerun it for one more time
        begin
          output_result = Actions.sh "set -o pipefail && xcodebuild #{xcodebuild_args} #{pipe_command}"
        rescue => ex
          exit_status = $?.exitstatus

          raise_error = true
          if exit_status.eql? 65
            iphone_simulator_time_out_error = /iPhoneSimulator: Timed out waiting/

            if (iphone_simulator_time_out_error =~ ex.message) != nil
              raise_error = false

              UI.important("First attempt failed with iPhone Simulator error: #{iphone_simulator_time_out_error.source}")
              UI.important("Retrying once more...")
              output_result = Actions.sh "set -o pipefail && xcodebuild #{xcodebuild_args} #{pipe_command}"
            end
          end

          raise ex if raise_error
        end

        # If raw_buildlog and some reports had to be created, create xcpretty reports from the build log
        if raw_buildlog && xcpretty_args.include?('--report')
          output_result = Actions.sh "set -o pipefail && cat '#{buildlog_path}/xcodebuild.log' | xcpretty #{xcpretty_args} > /dev/null"
        end

        output_result
      end

      def self.export_options_to_plist(hash)
        # Extract export options parameters from input options
        if hash.has_key?(:export_options_plist) && hash[:export_options_plist].is_a?(Hash)
          export_options = hash[:export_options_plist]

          # Normalize some values
          export_options[:teamID] = CredentialsManager::AppfileConfig.try_fetch_value(:team_id) if !export_options[:teamID] && CredentialsManager::AppfileConfig.try_fetch_value(:team_id)
          export_options[:onDemandResourcesAssetPacksBaseURL] = URI.escape(export_options[:onDemandResourcesAssetPacksBaseURL]) if export_options[:onDemandResourcesAssetPacksBaseURL]
          if export_options[:manifest]
            export_options[:manifest][:appURL] = URI.escape(export_options[:manifest][:appURL]) if export_options[:manifest][:appURL]
            export_options[:manifest][:displayImageURL] = URI.escape(export_options[:manifest][:displayImageURL]) if export_options[:manifest][:displayImageURL]
            export_options[:manifest][:fullSizeImageURL] = URI.escape(export_options[:manifest][:fullSizeImageURL]) if export_options[:manifest][:fullSizeImageURL]
            export_options[:manifest][:assetPackManifestURL] = URI.escape(export_options[:manifest][:assetPackManifestURL]) if export_options[:manifest][:assetPackManifestURL]
          end

          # Saves options to plist
          path = "#{Tempfile.new('exportOptions').path}.plist"
          File.write(path, export_options.to_plist)
          hash[:export_options_plist] = path
        end
        hash
      end

      def self.hash_to_args(hash)
        # Remove nil value params
        hash = hash.delete_if { |_, v| v.nil? }

        # Maps nice developer param names to CLI arguments
        hash.map do |k, v|
          v ||= ""
          if arg = ARGS_MAP[k]
            value = (v != true && v.to_s.length > 0 ? "\"#{v}\"" : "")
            "#{arg} #{value}".strip
          elsif k == :build_settings
            v.map {|setting, val| "#{setting}=\"#{val}\""}.join(' ')
          elsif k == :destination
            [*v].collect { |dst| "-destination \"#{dst}\"" }.join(' ')
          elsif k == :keychain && v.to_s.length > 0
            # If keychain is specified, append as OTHER_CODE_SIGN_FLAGS
            "OTHER_CODE_SIGN_FLAGS=\"--keychain #{v}\""
          elsif k == :xcargs && v.to_s.length > 0
            # Add more xcodebuild arguments
            "#{v}"
          end
        end.compact
      end

      def self.detect_workspace
        workspace = nil
        workspaces = Dir.glob("*.xcworkspace")

        if workspaces.length > 1
          UI.important("Multiple workspaces detected.")
        end

        unless workspaces.empty?
          workspace = workspaces.first
          UI.important("Using workspace \"#{workspace}\"")
        end

        return workspace
      end

      def self.description
        "Use the `xcodebuild` command to build and sign your app"
      end

      def self.available_options
        [
          ['archive', 'Set to true to build archive'],
          ['archive_path', 'The path to archive the to. Must contain `.xcarchive`'],
          ['workspace', 'The workspace to use'],
          ['scheme', 'The scheme to build'],
          ['build_settings', 'Hash of additional build information'],
          ['xcargs', 'Pass additional xcodebuild options'],
          ['output_style', 'Set the output format to one of: :standard (Colored UTF8 output, default), :basic (black & white ASCII output)'],
          ['buildlog_path', 'The path where the xcodebuild.log will be created, by default it is created in ~/Library/Logs/fastlane/xcbuild'],
          ['raw_buildlog', 'Set to true to see xcodebuild raw output. Default value is false'],
          ['xcpretty_output', 'specifies the output type for xcpretty. eg. \'test\', or \'simple\''],
          ['xcpretty_utf', 'Specifies xcpretty should use utf8 when reporting builds. This has no effect when raw_buildlog is specified.']
        ]
      end

      def self.details
        "**Note**: `xcodebuild` is a complex command, so it is recommended to use [gym](https://docs.fastlane.tools/actions/gym/) for building your ipa file and [scan](https://docs.fastlane.tools/actions/scan/) for testing your app instead."
      end

      def self.author
        "dtrenz"
      end
    end

    class XcarchiveAction < Action
      def self.run(params)
        params_hash = params || {}
        params_hash[:archive] = true
        XcodebuildAction.run(params_hash)
      end

      def self.description
        "Archives the project using `xcodebuild`"
      end

      def self.example_code
        [
          'xcarchive'
        ]
      end

      def self.category
        :building
      end

      def self.author
        "dtrenz"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.available_options
        [
          ['archive_path', 'The path to archive the to. Must contain `.xcarchive`'],
          ['workspace', 'The workspace to use'],
          ['scheme', 'The scheme to build'],
          ['build_settings', 'Hash of additional build information'],
          ['xcargs', 'Pass additional xcodebuild options'],
          ['output_style', 'Set the output format to one of: :standard (Colored UTF8 output, default), :basic (black & white ASCII output)'],
          ['buildlog_path', 'The path where the xcodebuild.log will be created, by default it is created in ~/Library/Logs/fastlane/xcbuild'],
          ['raw_buildlog', 'Set to true to see xcodebuild raw output. Default value is false'],
          ['xcpretty_output', 'specifies the output type for xcpretty. eg. \'test\', or \'simple\''],
          ['xcpretty_utf', 'Specifies xcpretty should use utf8 when reporting builds. This has no effect when raw_buildlog is specified.']
        ]
      end
    end

    class XcbuildAction < Action
      def self.run(params)
        params_hash = params || {}
        params_hash[:build] = true
        XcodebuildAction.run(params_hash)
      end

      def self.example_code
        [
          'xcbuild'
        ]
      end

      def self.category
        :building
      end

      def self.description
        "Builds the project using `xcodebuild`"
      end

      def self.author
        "dtrenz"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.available_options
        [
          ['archive', 'Set to true to build archive'],
          ['archive_path', 'The path to archive the to. Must contain `.xcarchive`'],
          ['workspace', 'The workspace to use'],
          ['scheme', 'The scheme to build'],
          ['build_settings', 'Hash of additional build information'],
          ['xcargs', 'Pass additional xcodebuild options'],
          ['output_style', 'Set the output format to one of: :standard (Colored UTF8 output, default), :basic (black & white ASCII output)'],
          ['buildlog_path', 'The path where the xcodebuild.log will be created, by default it is created in ~/Library/Logs/fastlane/xcbuild'],
          ['raw_buildlog', 'Set to true to see xcodebuild raw output. Default value is false'],
          ['xcpretty_output', 'specifies the output type for xcpretty. eg. \'test\', or \'simple\''],
          ['xcpretty_utf', 'Specifies xcpretty should use utf8 when reporting builds. This has no effect when raw_buildlog is specified.']
        ]
      end
    end

    class XccleanAction < Action
      def self.run(params)
        params_hash = params || {}
        params_hash[:clean] = true
        XcodebuildAction.run(params_hash)
      end

      def self.description
        "Cleans the project using `xcodebuild`"
      end

      def self.example_code
        [
          'xcclean'
        ]
      end

      def self.category
        :building
      end

      def self.author
        "dtrenz"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.available_options
        [
          ['archive', 'Set to true to build archive'],
          ['archive_path', 'The path to archive the to. Must contain `.xcarchive`'],
          ['workspace', 'The workspace to use'],
          ['scheme', 'The scheme to build'],
          ['build_settings', 'Hash of additional build information'],
          ['xcargs', 'Pass additional xcodebuild options'],
          ['output_style', 'Set the output format to one of: :standard (Colored UTF8 output, default), :basic (black & white ASCII output)'],
          ['buildlog_path', 'The path where the xcodebuild.log will be created, by default it is created in ~/Library/Logs/fastlane/xcbuild'],
          ['raw_buildlog', 'Set to true to see xcodebuild raw output. Default value is false'],
          ['xcpretty_output', 'specifies the output type for xcpretty. eg. \'test\', or \'simple\''],
          ['xcpretty_utf', 'Specifies xcpretty should use utf8 when reporting builds. This has no effect when raw_buildlog is specified.']
        ]
      end
    end

    class XcexportAction < Action
      def self.run(params)
        params_hash = params || {}
        params_hash[:export_archive] = true
        XcodebuildAction.run(params_hash)
      end

      def self.description
        "Exports the project using `xcodebuild`"
      end

      def self.example_code
        [
          'xcexport'
        ]
      end

      def self.category
        :building
      end

      def self.author
        "dtrenz"
      end

      def self.available_options
        [
          ['archive', 'Set to true to build archive'],
          ['archive_path', 'The path to archive the to. Must contain `.xcarchive`'],
          ['workspace', 'The workspace to use'],
          ['scheme', 'The scheme to build'],
          ['build_settings', 'Hash of additional build information'],
          ['xcargs', 'Pass additional xcodebuild options'],
          ['output_style', 'Set the output format to one of: :standard (Colored UTF8 output, default), :basic (black & white ASCII output)'],
          ['buildlog_path', 'The path where the xcodebuild.log will be created, by default it is created in ~/Library/Logs/fastlane/xcbuild'],
          ['raw_buildlog', 'Set to true to see xcodebuild raw output. Default value is false'],
          ['xcpretty_output', 'specifies the output type for xcpretty. eg. \'test\', or \'simple\''],
          ['xcpretty_utf', 'Specifies xcpretty should use utf8 when reporting builds. This has no effect when raw_buildlog is specified.']
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end

    class XctestAction < Action
      def self.run(params)
        UI.important("Have you seen the new 'scan' tool to run tests? https://docs.fastlane.tools/actions/scan/")
        params_hash = params || {}
        params_hash[:build] = true
        params_hash[:test] = true

        XcodebuildAction.run(params_hash)
      end

      def self.example_code
        [
          'xctest(
            destination: "name=iPhone 7s,OS=10.0"
          )'
        ]
      end

      def self.category
        :building
      end

      def self.description
        "Runs tests on the given simulator"
      end

      def self.available_options
        [
          ['archive', 'Set to true to build archive'],
          ['archive_path', 'The path to archive the to. Must contain `.xcarchive`'],
          ['workspace', 'The workspace to use'],
          ['scheme', 'The scheme to build'],
          ['build_settings', 'Hash of additional build information'],
          ['xcargs', 'Pass additional xcodebuild options'],
          ['destination', 'The simulator to use, e.g. "name=iPhone 5s,OS=8.1"'],
          ['destination_timeout', 'The timeout for connecting to the simulator, in seconds'],
          ['enable_code_coverage', 'Turn code coverage on or off when testing. eg. true|false. Requires Xcode 7+'],
          ['output_style', 'Set the output format to one of: :standard (Colored UTF8 output, default), :basic (black & white ASCII output)'],
          ['buildlog_path', 'The path where the xcodebuild.log will be created, by default it is created in ~/Library/Logs/fastlane/xcbuild'],
          ['raw_buildlog', 'Set to true to see xcodebuild raw output. Default value is false'],
          ['xcpretty_output', 'specifies the output type for xcpretty. eg. \'test\', or \'simple\''],
          ['xcpretty_utf', 'Specifies xcpretty should use utf8 when reporting builds. This has no effect when raw_buildlog is specified.']
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.author
        "dtrenz"
      end
    end
  end
end
# rubocop:enable all
