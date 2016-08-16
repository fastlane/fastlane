module Fastlane
  module Actions
    module SharedValues
    end

    class FtpAction < Action
      def self.run(params)
        require 'net/ftp'
        if params[:upload]
          FtpAction.open(params, params[:upload][:dest])
          FtpAction.put(params)
        end
        if params[:download]
          FtpAction.get(params)
        end
      end

      def self.open(params, folder)
        Net::FTP.open(params[:host], params[:username], params[:password]) do |ftp|
          UI.success("Successfully connect to #{params[:host]}")
          ftp.passive = true
          parts = folder.split("/")
          growing_path = ""
          parts.each do |part|
            growing_path += "/" + part
            begin
              ftp.chdir(growing_path)
            rescue
              ftp.mkdir(part) unless File.exist?(growing_path)
              retry
            end
          end
          UI.success("FTP move in #{growing_path} on #{params[:host]}")
          ftp.close
        end
      end

      def self.put(params)
        Net::FTP.open(params[:host], params[:username], params[:password]) do |ftp|
          ftp.passive = true
          ftp.chdir(params[:upload][:dest])
          transferred = 0
          filesize = File.size(params[:upload][:src])
          ftp.putbinaryfile(params[:upload][:src], params[:upload][:src].split("/").last) do |data|
            transferred += data.size
            percent = ((transferred.to_f / filesize.to_f) * 100).to_i
            finished = ((transferred.to_f / filesize.to_f) * 30).to_i
            not_finished = 30 - finished
            print "\r"
            print "%3i %" % percent
            print "["
            finished.downto(1) { |n| print "=" }
            print ">"
            not_finished.downto(1) { |n| print " " }
            print "]"
          end
          print "\n"
          UI.success("Successfully uploaded #{params[:upload][:src]}")
          ftp.close
        end
      end

      def self.get(params)
        Net::FTP.open(params[:host], params[:username], params[:password]) do |ftp|
          ftp.passive = true
          ftp.getbinaryfile(params[:download][:src], params[:download][:dest]) do |data|
          end
          UI.success("Successfully download #{params[:download][:dest]}")
          ftp.close
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload and Download files via FTP"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "Transfer files via FTP, and create recursively folder for upload action"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :username,
          short_option: "-u",
          env_name: "FL_FTP_USERNAME",
          description: "Username",
          is_string: true),
          FastlaneCore::ConfigItem.new(key: :password,
          short_option: "-p",
          env_name: "FL_FTP_PASSWORD",
          description: "Password",
          optional: false,
          is_string: true),
          FastlaneCore::ConfigItem.new(key: :host,
          short_option: "-H",
          env_name: "FL_FTP_HOST",
          description: "Hostname",
          is_string: true),
          FastlaneCore::ConfigItem.new(key: :folder,
          short_option: "-f",
          env_name: "FL_FTP_FOLDER",
          description: "repository",
          is_string: true),
          FastlaneCore::ConfigItem.new(key: :upload,
          short_option: "-U",
          env_name: "FL_FTP_UPLOAD",
          description: "Upload",
          optional: true,
          is_string: false,
          type: Hash),
          FastlaneCore::ConfigItem.new(key: :download,
          short_option: "-D",
          env_name: "FL_FTP_DOWNLOAD",
          description: "Download",
          optional: true,
          is_string: false,
          type: Hash),
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["PoissonBallon"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
