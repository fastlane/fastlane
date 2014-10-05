require 'pty'

require 'ios_deploy_kit/password_manager'


module IosDeployKit
  # The TransporterInputError occurs when you passed wrong inputs to the {IosDeployKit::ItunesTransporter}
  class TransporterInputError < StandardError 
  end
  # The TransporterTransferError occurs when some error happens
  # while uploading or downloading something from/to iTC
  class TransporterTransferError < StandardError
  end

  class ItunesTransporter
    ERROR_REGEX = />\s*ERROR:\s+(.+)/  
    WARNING_REGEX = />\s*WARN:\s+(.+)/
    OUTPUT_REGEX = />\s+(.+)/

    private_constant :ERROR_REGEX, :WARNING_REGEX, :OUTPUT_REGEX
    
    # Returns a new instance of the iTunesTranspoter.
    # If no username or password given, it will be taken from
    # the #{IosDeployKit::PasswordManager}
    def initialize(user = nil, password = nil)
      @user = (user || PasswordManager.new.username)
      @password = (password || PasswordManager.new.password)
    end

    # Downloads the latest version of the app metadata package from iTC.
    # @param app [IosDeployKit::App] The app you want to download the data for
    # @param dir [String] the path to the package file
    # @return (Bool) True if everything worked fine
    # @raise [IosDeployKit::TransporterTransferError] when something went wrong 
    #   when transfering
    # @raise [IosDeployKit::TransporterInputError] when passing wrong inputs
    def download(app, dir = nil)
      raise TransporterInputError.new("No valid IosDeployKit::App given") unless app.kind_of?IosDeployKit::App

      dir ||= app.get_metadata_directory
      command = build_download_command(@user, @password, app.apple_id, dir)

      execute_transporter(command)
    end

    # Uploads the modified package back to iTunesConnect
    # @param app [IosDeployKit::App] The app you want to download the data for
    # @param dir [String] the path in which the package file is located
    # @return (Bool) True if everything worked fine
    # @raise [IosDeployKit::TransporterTransferError] when something went wrong 
    #   when transfering
    # @raise [IosDeployKit::TransporterInputError] when passing wrong inputs
    def upload(app, dir)
      raise TransporterInputError.new("No valid IosDeployKit::App given") unless app.kind_of?IosDeployKit::App

      dir ||= app.get_metadata_directory
      dir += "/#{app.apple_id}.itmsp"
      
      command = build_upload_command(@user, @password, dir)

      result = execute_transporter(command)

      Helper.log.info("Successfully uploaded package to iTunesConnect. It might take a few minutes until it's visible online.")

      result
    end

    private
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
          raise TransporterTransferError.new(errors.join("\n"))
        end

        true
      end

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

      def build_upload_command(username, password, source = "/tmp")
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