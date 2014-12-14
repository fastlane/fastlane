require 'pty'
require 'shellwords'
require 'fastlane/password_manager'


module Deliver
  # The TransporterInputError occurs when you passed wrong inputs to the {Deliver::ItunesTransporter}
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
    RETURN_VALUE_REGEX = />\sDBG-X:\sReturning\s+(\d+)/

    private_constant :ERROR_REGEX, :WARNING_REGEX, :OUTPUT_REGEX, :RETURN_VALUE_REGEX

    # This will be called from the Deliverfile, and disables the logging of the transporter output
    def self.hide_transporter_output
      @@hide_transporter_output = true
    end

    # Returns a new instance of the iTunesTransporter.
    # If no username or password given, it will be taken from
    # the #{Fastlane::PasswordManager}
    def initialize(user = nil, password = nil)
      @user = (user || Fastlane::PasswordManager.shared_manager.username)
      @password = (password || Fastlane::PasswordManager.shared_manager.password)
    end

    # Downloads the latest version of the app metadata package from iTC.
    # @param app [Deliver::App] The app you want to download the data for
    # @param dir [String] the path to the package file
    # @return (Bool) True if everything worked fine
    # @raise [Deliver::TransporterTransferError] when something went wrong
    #   when transfering
    # @raise [Deliver::TransporterInputError] when passing wrong inputs
    def download(app, dir = nil)
      dir ||= "/tmp"
      raise TransporterInputError.new("No valid Deliver::App given") unless app.kind_of?Deliver::App

      Helper.log.info "Going to download app metadata from iTunesConnect"
      dir ||= app.get_metadata_directory
      command = build_download_command(@user, @password, app.apple_id, dir)

      result = execute_transporter(command)

      itmsp_path = [dir, "#{app.apple_id}.itmsp"].join('/')
      if result and File.directory?itmsp_path
        Helper.log.info "Successfully downloaded the latest package from iTunesConnect.".green
      else
        Helper.log.fatal "Could not download metadata from iTunes Connect. Do you have special characters in your password (Like ' or \")?"
      end

      result
    end

    # Uploads the modified package back to iTunesConnect
    # @param app [Deliver::App] The app you want to download the data for
    # @param dir [String] the path in which the package file is located
    # @return (Bool) True if everything worked fine
    # @raise [Deliver::TransporterTransferError] when something went wrong
    #   when transfering
    # @raise [Deliver::TransporterInputError] when passing wrong inputs
    def upload(app, dir)
      raise TransporterInputError.new("No valid Deliver::App given") unless app.kind_of?Deliver::App

      dir ||= app.get_metadata_directory
      dir += "/#{app.apple_id}.itmsp"

      Helper.log.info "Going to upload updated app to iTunesConnect"

      command = build_upload_command(@user, @password, dir)
      result = execute_transporter(command)

      if result
        Helper.log.info "Successfully uploaded package to iTunesConnect. It might take a few minutes until it's visible online.".green
      end

      result
    end

    private
      def execute_transporter(command)
        @errors = []
        @warnings = []

        if defined?@@hide_transporter_output
          # Show a one time message instead
          Helper.log.info "Waiting for iTunes Connect transporter to be finished.".green
          Helper.log.info "If you want upload/download logs to be enabled, remove 'hide_transporter_output' from your Deliverfile."
          Helper.log.info "iTunes Transporter progress...".green
        end

        begin
          PTY.spawn(command) do |stdin, stdout, pid|
            stdin.each do |line|
              parse_line(line) # this is where the parsing happens
            end
          end
        rescue => ex
          Helper.log.fatal(ex.to_s)
          @errors << ex.to_s
        end

        if @warnings.count > 0
          Helper.log.warn(@warnings.join("\n"))
        end

        if @errors.count > 0
          Helper.log.error(@errors.join("\n"))
        end

        true
      end

      def parse_line(line)
        # Taken from https://github.com/sshaw/itunes_store_transporter/blob/master/lib/itunes/store/transporter/output_parser.rb

        output_done = false
        if line =~ ERROR_REGEX
          @errors << $1
          Helper.log.error "[Transporter Error Output]: #{$1}".red

          # Check if it's a login error
          if $1.include?"Your Apple ID or password was entered incorrectly" or
             $1.include?"This Apple ID has been locked for security reasons"

            Fastlane::PasswordManager.shared_manager.password_seems_wrong
          elsif $1.include?"Redundant Binary Upload. There already exists a binary upload with build"
            Helper.log.fatal $1
            Helper.log.fatal "You have to change the build number of your app to upload your ipa file"
          end

          output_done = true
        elsif line =~ WARNING_REGEX
          @warnings << $1
          Helper.log.warn "[Transporter Warning Output]: #{$1}".yellow
          output_done = true
        end

        if line =~ RETURN_VALUE_REGEX
          if $1.to_i != 0
            Helper.log.fatal "Transporter transfer failed.".red
            Helper.log.warn(@warnings.join("\n").yellow)
            Helper.log.error(@errors.join("\n").red)
            raise "Return status of iTunes Transporter was #{$1}: #{@errors.join('\n')}".red
          else
            Helper.log.info "iTunes Transporter successfully finished its job".green
          end
        end

        if not defined?@@hide_transporter_output and line =~ OUTPUT_REGEX
          # General logging for debug purposes
          unless output_done
            Helper.log.debug "[Transporter Output]: #{$1}"
          end
        end
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
        Shellwords.escape(password)
      end

  end
end
