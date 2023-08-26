require 'fastlane/erb_template_helper'
require 'fastlane/helper/s3_client_helper'
require 'ostruct'
require 'uri'
require 'cgi'

module Fastlane
  module Actions
    module SharedValues
      # Using ||= because these MAY be defined by the the
      # preferred aws_s3 plugin
      S3_IPA_OUTPUT_PATH ||= :S3_IPA_OUTPUT_PATH
      S3_DSYM_OUTPUT_PATH ||= :S3_DSYM_OUTPUT_PATH
      S3_PLIST_OUTPUT_PATH ||= :S3_PLIST_OUTPUT_PATH
      S3_HTML_OUTPUT_PATH ||= :S3_HTML_OUTPUT_PATH
      S3_VERSION_OUTPUT_PATH ||= :S3_VERSION_OUTPUT_PATH
    end

    class S3Action < Action
      def self.run(config)
        UI.user_error!("Please use the `aws_s3` plugin instead. Install using `fastlane add_plugin aws_s3`.")
      end

      def self.description
        "Generates a plist file and uploads all to AWS S3"
      end

      def self.details
        [
          "Upload a new build to Amazon S3 to distribute the build to beta testers.",
          "Works for both Ad Hoc and Enterprise signed applications. This step will generate the necessary HTML, plist, and version files for you.",
          "It is recommended to **not** store the AWS access keys in the `Fastfile`. The uploaded `version.json` file provides an easy way for apps to poll if a new update is available."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "",
                                       description: ".ipa file for the build ",
                                       optional: true,
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :dsym,
                                       env_name: "",
                                       description: "zipped .dsym package for the build ",
                                       optional: true,
                                       default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH],
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :upload_metadata,
                                       env_name: "",
                                       description: "Upload relevant metadata for this build",
                                       optional: true,
                                       default_value: true,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :plist_template_path,
                                       env_name: "",
                                       description: "plist template path",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :plist_file_name,
                                       env_name: "",
                                       description: "uploaded plist filename",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :html_template_path,
                                       env_name: "",
                                       description: "html erb template path",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :html_file_name,
                                       env_name: "",
                                       description: "uploaded html filename",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_template_path,
                                       env_name: "",
                                       description: "version erb template path",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_file_name,
                                       env_name: "",
                                       description: "uploaded version filename",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :access_key,
                                       env_name: "S3_ACCESS_KEY",
                                       description: "AWS Access Key ID ",
                                       sensitive: true,
                                       optional: true,
                                       default_value: ENV['AWS_ACCESS_KEY_ID'],
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :secret_access_key,
                                       env_name: "S3_SECRET_ACCESS_KEY",
                                       description: "AWS Secret Access Key ",
                                       sensitive: true,
                                       optional: true,
                                       default_value: ENV['AWS_SECRET_ACCESS_KEY'],
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :bucket,
                                       env_name: "S3_BUCKET",
                                       description: "AWS bucket name",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: ENV['AWS_BUCKET_NAME'],
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :region,
                                       env_name: "S3_REGION",
                                       description: "AWS region (for bucket creation) ",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: ENV['AWS_REGION'],
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "S3_PATH",
                                       description: "S3 'path'. Values from Info.plist will be substituted for keys wrapped in {}  ",
                                       optional: true,
                                       default_value: 'v{CFBundleShortVersionString}_b{CFBundleVersion}/'),
          FastlaneCore::ConfigItem.new(key: :source,
                                       env_name: "S3_SOURCE",
                                       description: "Optional source directory e.g. ./build ",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :acl,
                                       env_name: "S3_ACL",
                                       description: "Uploaded object permissions e.g public_read (default), private, public_read_write, authenticated_read ",
                                       optional: true,
                                       default_value: "public_read")
        ]
      end

      def self.output
        [
          ['S3_IPA_OUTPUT_PATH', 'Direct HTTP link to the uploaded ipa file'],
          ['S3_DSYM_OUTPUT_PATH', 'Direct HTTP link to the uploaded dsym file'],
          ['S3_PLIST_OUTPUT_PATH', 'Direct HTTP link to the uploaded plist file'],
          ['S3_HTML_OUTPUT_PATH', 'Direct HTTP link to the uploaded HTML file'],
          ['S3_VERSION_OUTPUT_PATH', 'Direct HTTP link to the uploaded Version file']
        ]
      end

      def self.author
        "joshdholtz"
      end

      def self.is_supported?(platform)
        false
      end

      def self.example_code
        [
          's3',
          's3(
            # All of these are used to make Shenzhen\'s `ipa distribute:s3` command
            access_key: ENV["S3_ACCESS_KEY"],               # Required from user.
            secret_access_key: ENV["S3_SECRET_ACCESS_KEY"], # Required from user.
            bucket: ENV["S3_BUCKET"],                       # Required from user.
            ipa: "AppName.ipa",                             # Optional if you use `ipa` to build
            dsym: "AppName.app.dSYM.zip",                   # Optional if you use `ipa` to build
            path: "v{CFBundleShortVersionString}_b{CFBundleVersion}/", # This is actually the default.
            upload_metadata: true,                          # Upload version.json, plist and HTML. Set to false to skip uploading of these files.
            version_file_name: "app_version.json",          # Name of the file to upload to S3. Defaults to "version.json"
            version_template_path: "path/to/erb"            # Path to an ERB to configure the structure of the version JSON file
          )'
        ]
      end

      def self.category
        :deprecated
      end

      def self.deprecated_notes
        [
          "Please use the `aws_s3` plugin instead.",
          "Install using `fastlane add_plugin aws_s3`."
        ].join("\n")
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
