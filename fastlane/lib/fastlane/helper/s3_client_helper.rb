module Fastlane
  module Helper
    class S3ClientHelper
      def initialize(s3_access_key, s3_secret_access_key, s3_region)
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
          @client = AWS::S3.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key,
            region: s3_region
          )
        else
          @client = AWS::S3.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key
          )
        end
      end

      def upload_file(bucket, file_name, file_data, acl)
        obj = client.buckets[bucket].objects.create(file_name, file_data, acl: acl)

        # When you enable versioning on a S3 bucket,
        # writing to an object will create an object version
        # instead of replacing the existing object.
        # http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3/ObjectVersion.html
        if obj.kind_of?(AWS::S3::ObjectVersion)
          obj = obj.object
        end

        # Return public url
        obj.public_url.to_s
      end

      def download_file(bucket, file_name)
        client.buckets[bucket].objects[filename]
      end

      def delete_file(bucket, file_name)
        client.buckets[bucket].objects[filename].delete
      end

      def bucket(bucket_name)
        client.buckets[bucket_name]
      end

      private

      attr_reader :client

      # @return true if loading the AWS SDK from the 'aws-sdk' gem yields the expected v1 API, or false otherwise
      def load_from_original_gem_name
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

      def load_from_v1_gem_name
        Actions.verify_gem!('aws-sdk-v1')
        require 'aws-sdk-v1'
      end

      def v1_sdk_module_present?
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
    end
  end
end
