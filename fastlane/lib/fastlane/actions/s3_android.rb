require 'fastlane/erb_template_helper'

module Fastlane
  module Actions
    module SharedValues
      S3_APK_OUTPUT_PATH = :S3_APK_OUTPUT_PATH
      S3_APK_HTML_OUTPUT_PATH = :S3_APK_HTML_OUTPUT_PATH
    end

    S3_ANDROID_ARGS_MAP = {
      apk: '-f',
      access_key: '-a',
      secret_access_key: '-s',
      bucket: '-b',
      region: '-r',
      acl: '--acl',
      path: '-P'
    }

    class S3AndroidAction < Action
      def self.run(config)
        params = {}
        params[:apk] = config[:apk]
        params[:access_key] = config[:access_key]
        params[:secret_access_key] = config[:secret_access_key]
        params[:bucket] = config[:bucket]
        params[:region] = config[:region]
        params[:html_template_path] = config[:html_template_path]
        params[:acl] = config[:acl]
        params[:path] = config[:path]

        # Pulling parameters for other uses
        s3_region = params[:region]
        s3_access_key = params[:access_key]
        s3_secret_access_key = params[:secret_access_key]
        s3_bucket = params[:bucket]
        apk = params[:apk]
        s3_path = params[:path]
        acl = params[:acl].to_sym

        UI.user_error!("No S3 access key given, pass using `access_key: 'key'`") unless s3_access_key.to_s.length > 0
        UI.user_error!("No S3 secret access key given, pass using `secret_access_key: 'secret key'`") unless s3_secret_access_key.to_s.length > 0
        UI.user_error!("No S3 bucket given, pass using `bucket: 'bucket'`") unless s3_bucket.to_s.length > 0
        UI.user_error!("No APK file path given, pass using `apk: 'apk path'`") unless apk.to_s.length > 0

        html_template_path = params[:html_template_path]

        apk_version = self.get_version_from_apk(apk)

        s3_client = self.s3_client(s3_access_key, s3_secret_access_key, s3_region)
        bucket = s3_client.buckets[s3_bucket]

        apk_file_basename = File.basename(apk)
        apk_file_name = "#{s3_path}#{apk_file_basename}"
        apk_file_data = File.open(apk, 'rb')

        apk_url = self.upload_file(bucket, apk_file_name, apk_file_data, acl)

        # Setting action and environment variables
        Actions.lane_context[SharedValues::S3_APK_OUTPUT_PATH] = apk_url
        ENV[SharedValues::S3_APK_OUTPUT_PATH.to_s] = apk_url

        html_file_name = "#{s3_path}index.html"

        # grabs module
        eth = Fastlane::ErbTemplateHelper

        # Creates html from template
        if html_template_path && File.exist?(html_template_path)
          html_template = eth.load_from_path(html_template_path)
        else
          html_template = eth.load("s3_html_template")
        end

        html_render = eth.render(html_template, {
          apk_url: apk_url,
          apk_version: apk_version
        })

        html_url = self.upload_file(bucket, html_file_name, html_render, acl)

        Actions.lane_context[SharedValues::S3_APK_HTML_OUTPUT_PATH] = html_url
        ENV[SharedValues::S3_APK_HTML_OUTPUT_PATH.to_s] = html_url

        UI.success("Successfully uploaded apk file to '#{Actions.lane_context[SharedValues::S3_APK_OUTPUT_PATH]}'")

        return true
      end

      # @return true if loading the AWS SDK from the 'aws-sdk' gem yields the expected v1 API, or false otherwise
      def self.load_from_original_gem_name
        begin
          # We don't use `Actions.verify_gem!` here, because we want to silently be OK with this gem not being
          # present, in case the user has already migrated to 'aws-sdk-v1' (see #load_from_v1_gem_name)
          Gem::Specification.find_by_name('aws-sdk')
          require 'aws-sdk'
        rescue Gem::LoadError
          UI.verbose("The 'aws-sdk' gem is not present")
          return false
        end

        UI.verbose("The 'aws-sdk' gem is present")
        true
      end

      def self.load_from_v1_gem_name
        Actions.verify_gem!('aws-sdk-v1')
        require 'aws-sdk-v1'
      end

      def self.v1_sdk_module_present?
        begin
          # Here we'll make sure that the `AWS` module is defined. If it is, the gem is the v1.x API.
          Object.const_get("AWS")
        rescue NameError
          UI.verbose("Couldn't find the needed `AWS` module in the 'aws-sdk' gem")
          return false
        end

        UI.verbose("Found the needed `AWS` module in the 'aws-sdk' gem")
        true
      end

      def self.s3_client(s3_access_key, s3_secret_access_key, s3_region)
        # The AWS SDK API changed completely in v2.x. The most stable way to keep using the V1 API is to
        # require the 'aws-sdk-v1' gem directly. However, for those customers who are using the 'aws-sdk'
        # gem at v1.x, we don't want to break their setup which currently works.
        #
        # Therefore, we will attempt to load the v1 API from the original gem name, but go on to load
        # from the aws-sdk-v1 gem name if necessary
        loaded_original_gem = load_from_original_gem_name

        if !loaded_original_gem || !v1_sdk_module_present?
          load_from_v1_gem_name
          UI.verbose("Loaded AWS SDK v1.x from the `aws-sdk-v1` gem")
        else
          UI.verbose("Loaded AWS SDK v1.x from the `aws-sdk` gem")
        end

        if s3_region
          s3_client = AWS::S3.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key,
            region: s3_region
          )
        else
          s3_client = AWS::S3.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key
          )
        end
        s3_client
      end

      def self.upload_file(bucket, file_name, file_data, acl)
        obj = bucket.objects.create(file_name, file_data, acl: acl)

        # When you enable versioning on a S3 bucket,
        # writing to an object will create an object version
        # instead of replacing the existing object.
        # http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3/ObjectVersion.html
        if obj.kind_of? AWS::S3::ObjectVersion
          obj = obj.object
        end

        # Return public url
        obj.public_url.to_s
      end

      #
      # get version name from APK
      #
      def self.get_version_from_apk(path_to_apk)
        if ENV['ANDROID_HOME'].nil?
          UI.important("You must define your ANDROID_HOME in order to detect APK version name")
          return
        end

        # search for most recent aapt
        aapt_binary = Dir["#{ENV['ANDROID_HOME']}/build-tools/*/aapt"].last
        UI.verbose("aapt binary used : " + aapt_binary)

        # extract versionName='X.Y.Z' from APK
        get_version_cmd = aapt_binary + " dump badging " + path_to_apk

        # execute the command line
        get_version = `#{get_version_cmd}`

        # return only the X.Y.Z
        return get_version.scan(/versionName='(.*)\.(.*)\.(.*)' /).first.join(".")
      end

      def self.description
        "A simple plugin to upload APK to Amazon S3"
      end

      def self.output
        [
          ['S3_APK_OUTPUT_PATH', 'Direct HTTP link to the uploaded apk file']
        ]
      end

      def self.authors
        ["Jérôme Grondin"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "A simple plugin to upload APK to Amazon S3"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: "",
                                       description: ".apk file for the build ",
                                       optional: true,
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]),
          FastlaneCore::ConfigItem.new(key: :access_key,
                                       env_name: "S3_ACCESS_KEY",
                                       description: "AWS Access Key ID ",
                                       optional: true,
                                       default_value: ENV['AWS_ACCESS_KEY_ID']),
          FastlaneCore::ConfigItem.new(key: :secret_access_key,
                                       env_name: "S3_SECRET_ACCESS_KEY",
                                       description: "AWS Secret Access Key ",
                                       optional: true,
                                       default_value: ENV['AWS_SECRET_ACCESS_KEY']),
          FastlaneCore::ConfigItem.new(key: :bucket,
                                       env_name: "S3_BUCKET",
                                       description: "AWS bucket name",
                                       optional: true,
                                       default_value: ENV['AWS_BUCKET_NAME']),
          FastlaneCore::ConfigItem.new(key: :region,
                                       env_name: "S3_REGION",
                                       description: "AWS region (for bucket creation) ",
                                       optional: true,
                                       default_value: ENV['AWS_REGION']),
          FastlaneCore::ConfigItem.new(key: :path,
                                        env_name: "S3_PATH",
                                        description: "S3 'path'",
                                        optional: true,
                                        default_value: '/'),
          FastlaneCore::ConfigItem.new(key: :html_template_path,
                                        env_name: "",
                                        description: "html erb template path",
                                        optional: true),
          FastlaneCore::ConfigItem.new(key: :acl,
                                       env_name: "S3_ACL",
                                       description: "Uploaded object permissions e.g public_read (default), private, public_read_write, authenticated_read ",
                                       optional: true,
                                       default_value: "public_read")
        ]
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.category
        :beta
      end
    end
  end
end
