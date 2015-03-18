module Fastlane
  module Actions
    module SharedValues
      XCODEBUILD_ARCHIVE = :XCODEBUILD_ARCHIVE
    end

    # xcodebuild man page:
    # https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html

    class XcodebuildAction
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
        destination: "-destination",
        export_archive: "-exportArchive",
        export_format: "-exportFormat",
        export_installer_identity: "-exportInstallerIdentity",
        export_path: "-exportPath",
        export_profile: "-exportProvisioningProfile",
        export_signing_identity: "-exportSigningIdentity",
        export_with_original_signing_identity: "-exportWithOriginalSigningIdentity",
        project: "-project",
        result_bundle_path: "-resultBundlePath",
        scheme: "-scheme",
        sdk: "-sdk",
        skip_unavailable_actions: "-skipUnavailableActions",
        target: "-target",
        workspace: "-workspace",
        xcconfig: "-xcconfig"
      }

      def self.run(params)
        unless Helper.test?
          raise "xcodebuild not installed".red if `which xcodebuild`.length == 0
        end

        # The args we will build with
        xcodebuild_args = Array[]

        # Supported ENV vars
        build_path = ENV["XCODE_BUILD_PATH"] || nil
        scheme     = ENV["XCODE_SCHEME"]
        workspace  = ENV["XCODE_WORKSPACE"]
        project    = ENV["XCODE_PROJECT"]

        # Append slash to build path, if needed
        if build_path && !build_path.end_with?("/")
          build_path += "/"
        end

        if params = params.first
          # Operation bools
          archiving = params.key? :archive
          exporting = params.key? :export_archive
          testing   = params.key? :test

          if exporting
            # If not passed, retrieve path from previous xcodebuild call
            params[:archive_path] ||= Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE]

            # Default to ipa as export format
            params[:export_format] ||= "ipa"

            # If not passed, construct export path from env vars
            params[:export_path] ||= "#{build_path}#{scheme}"

            # Store IPA path for later deploy steps (i.e. Crashlytics)
            Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = params[:export_path] + "." + params[:export_format].downcase
          else
            # If not passed, check for archive scheme & workspace/project env vars
            params[:scheme] ||= scheme
            params[:workspace] ||= workspace
            params[:project] ||= project
          end

          if archiving
            # If not passed, construct archive path from env vars
            params[:archive_path] ||= "#{build_path}#{params[:scheme]}.xcarchive"

            # Cache path for later xcodebuild calls
            Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE] = params[:archive_path]
          end

          # Maps parameter hash to CLI args
          if hash_args = hash_to_args(params)
            xcodebuild_args += hash_args
          end
        end

        # Joins args into space delimited string
        xcodebuild_args = xcodebuild_args.join(" ")

        # Default args
        xcpretty_args = [ "--color" ]

        # Stdout format
        if testing && !archiving
          xcpretty_args.push "--test"
        else
          xcpretty_args.push "--simple"
        end

        if testing
          # Test report file format
          if params[:report_formats]
            report_formats = params[:report_formats].map do |format|
              "--report #{format}"
            end.sort().join(" ")

            xcpretty_args.push report_formats

            # Test report file path
            if params[:report_path]
              xcpretty_args.push "--output \"#{params[:report_path]}\""
            elsif build_path
              xcpretty_args.push "--output \"#{build_path}report\""
            end

            # Save screenshots flag
            if params[:report_formats].include?("html") && params[:report_screenshots]
              xcpretty_args.push "--screenshots"
            end
          end
        end

        xcpretty_args = xcpretty_args.sort.join(" ")

        Actions.sh "set -o pipefail && xcodebuild #{xcodebuild_args} | xcpretty #{xcpretty_args}"
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
            v.map{|setting,value| "#{setting}=\"#{value}\""}.join(' ')
          elsif k == :keychain && v.to_s.length > 0
            # If keychain is specified, append as OTHER_CODE_SIGN_FLAGS
            "OTHER_CODE_SIGN_FLAGS=\"--keychain #{v}\""
          end
        end.compact.sort
      end
    end

    class XcarchiveAction
      def self.run(params)
        params_hash = params.first || {}
        params_hash[:archive] = true
        XcodebuildAction.run([params_hash])
      end
    end

    class XcbuildAction
      def self.run(params)
        params_hash = params.first || {}
        params_hash[:build] = true
        XcodebuildAction.run([params_hash])
      end
    end

    class XccleanAction
      def self.run(params)
        params_hash = params.first || {}
        params_hash[:clean] = true
        XcodebuildAction.run([params_hash])
      end
    end

    class XcexportAction
      def self.run(params)
        params_hash = params.first || {}
        params_hash[:export_archive] = true
        XcodebuildAction.run([params_hash])
      end
    end

    class XctestAction
      def self.run(params)
        params_hash = params.first || {}
        params_hash[:test] = true
        XcodebuildAction.run([params_hash])
      end
    end
  end
end
