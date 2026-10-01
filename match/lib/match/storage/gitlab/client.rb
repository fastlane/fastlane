require 'net/http/post/multipart'
require 'securerandom'

require_relative '../../module'
require_relative './secure_file'

module Match
  module Storage
    class GitLab
      class Client
        def initialize(api_v4_url:, project_id:, job_token: nil, private_token: nil)
          @job_token      = job_token
          @private_token  = private_token
          @api_v4_url     = api_v4_url
          @project_id     = project_id

          UI.important("JOB_TOKEN and PRIVATE_TOKEN both defined, using JOB_TOKEN to execute this job.") if @job_token && @private_token
        end

        def base_url
          return "#{@api_v4_url}/projects/#{CGI.escape(@project_id)}/secure_files"
        end

        def authentication_key
          if @job_token
            return "JOB-TOKEN"
          elsif @private_token
            return "PRIVATE-TOKEN"
          end
        end

        def authentication_value
          if @job_token
            return @job_token
          elsif @private_token
            return @private_token
          end
        end

        def files
          @files ||= begin
            url = URI.parse(base_url)
            # 100 is maximum number of Secure files available on GitLab https://docs.gitlab.com/ee/api/secure_files.html
            url.query = [url.query, "per_page=100"].compact.join('&')

            request = Net::HTTP::Get.new(url.request_uri)

            res = execute_request(url, request)

            data = []

            JSON.parse(res.body).each do |file|
              data << SecureFile.new(client: self, file: file)
            end

            data
          end
        end

        def find_file_by_name(name)
          files.select { |secure_file| secure_file.file.name == name }.first
        end

        def upload_file(current_file, target_file)
          url = URI.parse(base_url)

          File.open(current_file) do |file|
            request = Net::HTTP::Post::Multipart.new(
              url.path,
              "file" => UploadIO.new(file, "application/octet-stream"),
              "name" => target_file
            )

            execute_request(url, request, target_file)
          end
        end

        def execute_request(url, request, target_file = nil)
          request[authentication_key] = authentication_value

          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = url.instance_of?(URI::HTTPS)

          begin
            response = http.request(request)
          rescue Errno::ECONNREFUSED, SocketError => message
            UI.user_error!("GitLab connection error: #{message}")
          end

          unless response.kind_of?(Net::HTTPSuccess)
            handle_response_error(response, target_file)
          end

          response
        end

        def handle_response_error(response, target_file = nil)
          error_prefix      = "GitLab storage error:"
          file_debug_string = "File: #{target_file}" unless target_file.nil?
          api_debug_string  = "API: #{@api_v4_url}"
          debug_info        = "(#{[file_debug_string, api_debug_string].compact.join(', ')})"

          begin
            parsed = JSON.parse(response.body)
          rescue JSON::ParserError
          end

          if parsed && parsed["message"] && (parsed["message"]["name"] == ["has already been taken"])
            error_handler = :error
            error = "#{target_file} already exists in GitLab project #{@project_id}, file not uploaded"
          else
            error_handler = :user_error!
            error = "#{response.code}: #{response.body}"
          end
          error_message = [error_prefix, error, debug_info].join(' ')

          UI.send(error_handler, error_message)
        end

        def prompt_for_access_token
          unless authentication_key
            @private_token = UI.input("Please supply a GitLab personal or project access token: ")
          end
        end
      end
    end
  end
end
