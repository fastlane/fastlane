require 'pty'

require 'ios_deploy_kit/password_manager'


module IosDeployKit
  class ItunesTransporter
    ERROR_REGEX = />\s*ERROR:\s+(.+)/  
    WARNING_REGEX = />\s*WARN:\s+(.+)/
    OUTPUT_REGEX = />\s+(.+)/
    
    def initialize(user = nil, password = nil)
      @user = (user || PasswordManager.new.username)
      @password = (password || PasswordManager.new.password)
    end

    def download(app, dir = nil)
      raise "No valid IosDeployKit::App given" unless app.kind_of?IosDeployKit::App

      dir ||= app.get_metadata_directory
      command = build_download_command(@user, @password, app.apple_id, dir)

      self.execute_transporter(command)
    end

    def upload(app, dir)
      raise "No valid IosDeployKit::App given" unless app.kind_of?IosDeployKit::App

      dir ||= app.get_metadata_directory
      dir += "/#{app.apple_id}.itmsp"
      
      command = build_upload_command(@user, @password, app.apple_id, dir)

      result = self.execute_transporter(command)

      Helper.log.info("Successfully uploaded package to iTunesConnect. It might take a few minutes until it's visible online.")

      result
    end

    def execute_transporter(command)
      # Taken from https://github.com/sshaw/itunes_store_transporter/blob/master/lib/itunes/store/transporter/output_parser.rb

      errors = []
      warnings = []

      begin
        PTY.spawn(command) do |stdin, stdout, pid|
          stdin.each do |line|
            if line =~ ERROR_REGEX
              errors << $1
            elsif line =~ WARNING_REGEX
              warnings << $1
            end

            if line =~ OUTPUT_REGEX
              # General logging for debug purposes
              Helper.log.debug "[Transpoter Output]: #{$1}"
            end
          end
        end
      rescue Exception => ex
        Helper.log.fatal(ex.to_s)
        errors << ex.to_s
      end

      if errors.count > 0
        Helper.log.debug(caller)
        raise errors.join("\n") 
      end

      true
    end

    private
      def build_download_command(username, password, apple_id, destination = "/tmp")
        [
          Helper.transporter_path,
          "-m lookupMetadata",
          "-u \"#{username}\"",
          "-p '#{escaped_password(password)}'",
          "-apple_id #{apple_id}",
          "-destination '#{destination}'"
        ].join(' ')
      end

      def build_upload_command(username, password, apple_id, source = "/tmp")
        [
          Helper.transporter_path,
          "-m upload",
          "-u \"#{username}\"",
          "-p '#{escaped_password(password)}'",
          "-f '#{source}'"
        ].join(' ')
      end

      def escaped_password(password)
        password.gsub('$', '\\$')
      end

  end
end