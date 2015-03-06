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
        arch: "-arch",
        alltargets: "-alltargets",
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
        cli_args = Array[]

        # Supported ENV vars
        build_path = ENV["BUILD_PATH"]
        scheme     = ENV["SCHEME"]
        workspace  = ENV["WORKSPACE"]

        # Append slash to build path, if needed
        unless build_path.end_with? "/"
          build_path += "/"
        end

        if params = params.first
          # Operation bools
          archiving = params.key? :archive
          exporting = params.key? :export_archive
          testing = params.key? :test

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
            # If not passed, check for archive scheme & workspace env vars
            params[:scheme] ||= scheme
            params[:workspace] ||= workspace

            # If not passed, construct archive path from env vars
            params[:archive_path] ||= "#{build_path}#{params[:scheme]}.xcarchive"
          end

          if archiving
            # Cache path for later xcodebuild calls
            Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE] = params[:archive_path]
          end

          # Maps parameter hash to CLI args
          hash_args = hash_to_cli_args(params)

          if (hash_args)
            cli_args += hash_args
          end
        end

        # Joins args into space delimited string
        cli_args = cli_args.join(" ")

        output_format = testing && !archiving ? "--test" : "--simple"

        Actions.sh "xcodebuild #{cli_args} | xcpretty #{output_format} --color"
      end

      def self.hash_to_cli_args(hash)
        # Maps nice developer param names to CLI arguments
        hash.map do |k, v|
          v ||= ""
          if arg = ARGS_MAP[k]
            value = (v != true && v.to_s.length > 0 ? "\"#{v}\"" : "")
            "#{arg} #{value}".strip
          elsif k == :keychain && v.to_s.length > 0
            # If keychain is specified, append as OTHER_CODE_SIGN_FLAGS
            "OTHER_CODE_SIGN_FLAGS=\"--keychain #{v}\""
          end
        end.compact
      end
    end
  end
end