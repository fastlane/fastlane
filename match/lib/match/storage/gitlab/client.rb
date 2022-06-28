
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
          files.select{|secure_file| secure_file.file.name == name}.first
        end

        def upload_file(current_file, target_file)
          url = URI.parse(base_url)

          File.open(current_file) do |file|
            request = Net::HTTP::Post::Multipart.new(
              url.path,
              "file" => UploadIO.new(file, "application/octet-stream"),
              "name" => target_file
            )

            execute_request(url, request)
          end
        end

        def execute_request(url, request)
          request[authentication_key] = authentication_value

          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = url.instance_of?(URI::HTTPS)
          http.request(request)
        end
      end
    end
  end
end
