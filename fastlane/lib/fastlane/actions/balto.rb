module Fastlane
  module Actions
    module SharedValues
      BALTO_DOWNLOAD_URL = :BALTO_DOWNLOAD_URL
      BALTO_NUMBER = :BALTO_NUMBER
      BALTO_BUILD_INFO = :BALTO_BUILD_INFO
    end

    module BaltoHelper
      require 'net/http'
      require 'uri'
      require 'json'

      module_function

      ENDPOINT = "https://balto-api.herokuapp.com"
      API_PATH = "/api/v1"
      UPLOAD_PATH = "/builds/upload"
      USER_AGENT_STRING = "fastlane-balto"

      def upload_url
        URI.join(ENDPOINT, File.join(API_PATH, UPLOAD_PATH))
      end

      def upload_stream(f, params)
        MultipartFormBuilder.new(f, params).to_stream
      end

      def upload(params)
        url = upload_url
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        https.set_debug_output $stderr if params[:debug]
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE if params[:disable_ssl_verify]

        https.start do |h|
          req = Net::HTTP::Post.new(url.request_uri)
          File.open(params[:ipa_path], 'rb') do |f|
            stream = upload_stream(f, params)
            if params[:use_post_stream]
              req["Transfer-Encoding"] = "chunked"
              req.body_stream = stream
            else
              req.body = stream.read_all
            end
            req["Content-Type"] = stream.content_type
            req["User-Agent"] = USER_AGENT_STRING
            h.request(req)
          end
        end
      end

      def parse_response(response)
        return nil unless response.code == "200"

        data = JSON.parse(response.body, { symbolize_names: true })
        data[:build]
      end

      class FormDataStream
        attr_accessor :readers, :size, :content_type

        def initialize(content_type, readers)
          @content_type = content_type
          @readers = readers
          @size = readers.map(&:size).inject(:+)
        end

        def read_all
          return readers.map(&:read).join
        end

        def read(length = nil, outbuf = "")
          return read_all if length.nil?

          readers.each do |reader|
            next if reader.eof?
            return reader.read(length, outbuf)
          end
          return readers.last.read(length, outbuf)
        end

        def eof?
          readers.last.eof?
        end
      end

      class MultipartFormBuilder
        # "balto" as ascii
        BOUNDARY = "62616c746f"
        ALLOWED_REQUEST_NAMES = [:user_token, :project_token, :package, :ready_for_review, :release_note]

        attr_accessor :ipa_path, :params, :package

        def self.content_type
          "multipart/form-data; boundary=#{BOUNDARY}"
        end

        def initialize(package, params)
          @package = package
          @ipa_path = params[:ipa_path]
          @params = params.dup.select do |k, v|
            ALLOWED_REQUEST_NAMES.include?(k)
          end
        end

        def content_type
          self.class.content_type
        end

        def text_form(name, value)
          "Content-Disposition: form-data; name=\"#{name}\"\r\n\r\n#{value}"
        end

        def file_form_part(name, filename:'filename.ipa')
          "Content-Disposition: form-data; name=\"#{name}\"; filename=\"#{filename}\"\r\nContent-Transfer-Encoding: binary"
        end

        def form_boundary
          "--#{BOUNDARY}"
        end

        def to_stream
          data = params.map { |name, value| [form_boundary, text_form(name, value)].join("\r\n") }.join("\r\n")
          data += "\r\n"
          data += [form_boundary, file_form_part(:package.to_s, filename: File.basename(ipa_path))].join("\r\n")
          data += "\r\n\r\n"
          last = "\r\n#{form_boundary}--\r\n"

          return FormDataStream.new(content_type, [StringIO.new(data), package, StringIO.new(last)])
        end
      end
    end

    class BaltoAction < Action
      extend BaltoHelper

      def self.run(params)
        UI.message "Upload a package:#{params[:ipa_path]} to Balto project:#{params[:project_token]}"

        response = upload(params.values)
        UI.user_error! "Failed to make a request to Balto. #{response.message}." unless response.code == "200"

        parsed_response = parse_response(response)
        UI.user_error! "Error when trying to upload package to Balto: #{response.body}" if parsed_response.nil?

        Actions.lane_context[SharedValues::BALTO_BUILD_INFO] = parsed_response
        Actions.lane_context[SharedValues::BALTO_DOWNLOAD_URL] = parsed_response[:download_url]
        Actions.lane_context[SharedValues::BALTO_NUMBER] = parsed_response[:numbering]

        UI.success "Successfully made a request to Balto."
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload a build to Balto platform. https://www.balto.io/"
      end

      def self.details
        "Take your app quality to the next level with the ultimate feedback tool."
      end

      def self.available_options
        [
          # Balto API Parameters
          FastlaneCore::ConfigItem.new(key: :user_token,
                                       env_name: "FL_BALTO_USER_TOKEN",
                                       description: "Balto User Token",
                                       verify_block: proc do |value|
                                         UI.user_error!("No User token for BaltoAction given, pass using `user_token: 'token'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_token,
                                       env_name: "FL_BALTO_PROJECT_TOKEN",
                                       description: "Balto Project Token",
                                       verify_block: proc do |value|
                                         UI.user_error!("No Project token for BaltoAction given, pass using `project_token: 'token'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :release_note,
                                       env_name: "FL_BALTO_RELEASE_NOTE",
                                       description: "Release note for Balto Distribution app",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ready_for_review,
                                       env_name: "FL_BALTO_READY_FOR_REVIEW",
                                       description: "This defines who will receive the app. 0 is \"Only me.\" 1 is \"All project members.\" Default is 1",
                                       is_string: false,
                                       default_value: 1),

          # BaltoAction's paramters
          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "FL_BALTO_IPA_PATH",
                                       description: "IPA filepath to upload to Balto",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         UI.user_error!("IPA file was not found") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :use_post_stream,
                                       env_name: "FL_BALTO_USE_POST_STREAM",
                                       description: "This is whether or not to use stream for efficiently uploading form data",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :disable_ssl_verify,
                                       env_name: "FL_BALTO_DISABLE_SSL_VERIFY",
                                       description: "Turn off ssl verification",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :debug,
                                       env_name: "FL_BALTO_DEBUG",
                                       description: "Make detailed output to stderr",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.output
        [
          ['BALTO_DOWNLOAD_URL', 'The newly generated download url for this build package'],
          ['BALTO_NUMBER', 'the assigned number to this build package by balto automatically'],
          ['BALTO_BUILD_INFO', 'Contains all key values from the Balto API']
        ]
      end

      def self.authors
        ["roothybrid7"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
