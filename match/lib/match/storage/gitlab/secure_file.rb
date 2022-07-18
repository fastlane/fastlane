require 'open-uri'

require_relative '../../module'

module Match
  module Storage
    class GitLab
      class SecureFile
        attr_reader :client, :file

        def initialize(file:, client:)
          @file   = OpenStruct.new(file)
          @client = client
        end

        def file_url
          "#{@client.base_url}/#{@file.id}"
        end

        def create_subfolders(working_directory)
          FileUtils.mkdir_p("#{working_directory}/#{destination_file_path}")
        end

        def destination_file_path
          filename = @file.name.split('/').last

          @file.name.gsub(filename, '').gsub(%r{^/}, '')
        end

        def valid_checksum?(file)
          Digest::SHA256.hexdigest(File.read(file)) == @file.checksum
        end

        def download(working_directory)
          url = URI("#{file_url}/download")

          begin
            destination_file = "#{working_directory}/#{@file.name}"

            create_subfolders(working_directory)
            File.open(destination_file, "wb") do |saved_file|
              URI.open(url, "rb", { @client.authentication_key => @client.authentication_value }) do |data|
                saved_file.write(data.read)
              end

              FileUtils.chmod('u=rw,go-r', destination_file)
            end

            UI.crash!("Checksum validation failed for #{@file.name}") unless valid_checksum?(destination_file)
          rescue OpenURI::HTTPError => msg
            UI.error("Unable to download #{@file.name} - #{msg}")
          end
        end

        def delete
          url = URI(file_url)

          request = Net::HTTP::Delete.new(url.request_uri)

          @client.execute_request(url, request)
        end
      end
    end
  end
end
