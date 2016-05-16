require 'aws-sdk-v1'

module Fastlane
  module Actions
    module SharedValues
      UPLOAD_FOLDER_TO_S3_RESULT = :UPLOAD_FOLDER_TO_S3_RESULT
    end

    class UploadFolderToS3Action < Action
      def self.run(params)
        base_local_path   = params[:local_path]
        base_remote_path  = params[:remote_path]
        s3_region         = params[:region]
        s3_bucket         = params[:bucket]

        awscreds = {
          access_key_id:      params[:access_key_id],
          secret_access_key:  params[:secret_access_key],
          region:             s3_region
        }

        result  = ""
        bucket  = valid_bucket awscreds, s3_bucket
        files   = files_at_path base_local_path

        files.each do |file|
          local_path  = base_local_path  + file
          s3_path     = base_remote_path + file

          obj = write_file_to_bucket(local_path, bucket, s3_path)

          if obj.exists? == false
            result = "Error while uploadin file #{local_path}"
            Actions.lane_context[SharedValues::UPLOAD_FOLDER_TO_S3_RESULT] = result
            return result
          end
        end

        Actions.lane_context[SharedValues::UPLOAD_FOLDER_TO_S3_RESULT] = result
        result
      end

      def self.files_at_path(path)
        files = Dir.glob(path + "/**/*")

        files.each do |file|
          if File.directory?(file)
            files.remove file
          else
            file.slice! path
          end
        end
      end

      def self.write_file_to_bucket(local_path, bucket, s3_path)
        obj = bucket.objects[s3_path]
        obj.write(file: local_path, content_type: content_type_for_file(local_path))
        obj
      end

      def self.valid_s3(awscreds, s3_bucket)
        s3 = AWS::S3.new(awscreds)

        if s3.buckets[s3_bucket].location_constraint != awscreds[:region]
          s3 = AWS::S3.new(awscreds.merge(region: s3.buckets[s3_bucket].location_constraint))
        end

        s3
      end

      def self.valid_bucket(awscreds, s3_bucket)
        s3 = valid_s3 awscreds, s3_bucket
        s3.buckets[s3_bucket]
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload a folder, and all its content, to a S3 bucket."
      end

      def self.details
        [
          "If you want to use regex to exclude some files, please contribute to this action.",
          "Else, just do like me and from your artifacts/builds/product folder,",
          "create the subset you want to upload in another folder and upload it using this action."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :access_key_id,
                                       env_name: "FL_UPLOAD_FOLDER_TO_S3_ACCESS_KEY_ID",
                                       description: "Access key ID",
                                       verify_block: proc do |value|
                                         UI.user_error!("No Access key ID for UploadFolderToS3Action given, pass using `access_key_id: 'token'`") unless (value and not value.empty?)
                                       end),

          FastlaneCore::ConfigItem.new(key: :secret_access_key,
                                      env_name: "FL_UPLOAD_FOLDER_TO_S3_SECRET_ACCESS_KEY",
                                      description: "Secret access key",
                                      verify_block: proc do |value|
                                        UI.user_error!("No Secret access key for UploadFolderToS3Action given, pass using `secret_access_key: 'token'`") unless (value and not value.empty?)
                                      end),

          FastlaneCore::ConfigItem.new(key: :region,
                                      env_name: "FL_UPLOAD_FOLDER_TO_S3_REGION",
                                      description: "The region",
                                      verify_block: proc do |value|
                                        UI.user_error!("No region for UploadFolderToS3Action given, pass using `region: 'token'`") unless (value and not value.empty?)
                                      end),

          FastlaneCore::ConfigItem.new(key: :bucket,
                                      env_name: "FL_UPLOAD_FOLDER_TO_S3_BUCKET",
                                      description: "Bucket",
                                      verify_block: proc do |value|
                                        UI.user_error!("No bucket for UploadFolderToS3Action given, pass using `bucket: 'token'`") unless (value and not value.empty?)
                                      end),

          FastlaneCore::ConfigItem.new(key: :local_path,
                                      env_name: "FL_UPLOAD_FOLDER_TO_S3_LOCAL_PATH",
                                      description: "Path to local folder to upload",
                                      verify_block: proc do |value|
                                        UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                      end),

          FastlaneCore::ConfigItem.new(key: :remote_path,
                                       env_name: "FL_UPLOAD_FOLDER_TO_S3_REMOTE_PATH",
                                       description: "The remote base path",
                                       default_value: "")
        ]
      end

      def self.output
        [
          ['UPLOAD_FOLDER_TO_S3_RESULT', 'An empty string if everything is fine, a short description of the error otherwise'],
        ]
      end

      def self.return_value
        [
          "The return value is an empty string if everything went fine,",
          "or an explanation of the error encountered."
        ].join("\n")
      end

      def self.authors
        ["teriiehina"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.content_type_for_file(file)
        file_extension = File.extname(file)

        extensions_to_type = {
          ".html" => "text/html",
          ".png"  => "image/png",
          ".jpg"  => "text/jpeg",
          ".gif"  => "image/gif",
          ".log"  => "text/plain",
          ".css"  => "text/css",
          ".js"   => "application/javascript"
        }

        if extensions_to_type[file_extension].nil?
          "application/octet-stream"
        else
          extensions_to_type[file_extension]
        end
      end
    end
  end
end
