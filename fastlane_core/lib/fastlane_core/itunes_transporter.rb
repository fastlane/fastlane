require 'pty'
require 'shellwords'
require 'credentials_manager/account_manager'

module FastlaneCore
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

    SKIP_ERRORS = ["ERROR: An exception has occurred: Scheduling automatic restart in 1 minute"]

    private_constant :ERROR_REGEX, :WARNING_REGEX, :OUTPUT_REGEX, :RETURN_VALUE_REGEX, :SKIP_ERRORS

    # This will be called from the Deliverfile, and disables the logging of the transporter output
    def self.hide_transporter_output
      @hide_transporter_output = true

      @hide_transporter_output = false if $verbose
    end

    # Returns a new instance of the iTunesTransporter.
    # If no username or password given, it will be taken from
    # the #{CredentialsManager::AccountManager}
    def initialize(user = nil, password = nil)
      data = CredentialsManager::AccountManager.new(user: user, password: password)
      @user = data.user
      @password = data.password
    end

    # Downloads the latest version of the app metadata package from iTC.
    # @param app_id [Integer] The unique App ID
    # @param dir [String] the path in which the package file should be stored
    # @return (Bool) True if everything worked fine
    # @raise [Deliver::TransporterTransferError] when something went wrong
    #   when transfering
    def download(app_id, dir = nil)
      dir ||= "/tmp"

      UI.message("Going to download app metadata from iTunes Connect")
      command = build_download_command(@user, @password, app_id, dir)
      UI.verbose(build_download_command(@user, 'YourPassword', app_id, dir)) if $verbose

      result = execute_transporter(command)

      itmsp_path = File.join(dir, "#{app_id}.itmsp")
      if result and File.directory? itmsp_path
        UI.success("Successfully downloaded the latest package from iTunes Connect.")
      else
        handle_error(@password)
      end

      result
    end

    # Uploads the modified package back to iTunes Connect
    # @param app_id [Integer] The unique App ID
    # @param dir [String] the path in which the package file is located
    # @return (Bool) True if everything worked fine
    # @raise [Deliver::TransporterTransferError] when something went wrong
    #   when transfering
    def upload(app_id, dir)
      dir = File.join(dir, "#{app_id}.itmsp")

      UI.message("Going to upload updated app to iTunes Connect")
      UI.success("This might take a few minutes, please don't interrupt the script")

      command = build_upload_command(@user, @password, dir)
      UI.verbose(build_upload_command(@user, 'YourPassword', dir)) if $verbose

      result = execute_transporter(command)

      if result
        UI.success("-" * 102)
        UI.success("Successfully uploaded package to iTunes Connect. It might take a few minutes until it's visible online.")
        UI.success("-" * 102)

        FileUtils.rm_rf(dir) unless Helper.is_test? # we don't need the package any more, since the upload was successful
      else
        handle_error(@password)
      end

      result
    end

    private

    def handle_error(password)
      # rubocop:disable Style/CaseEquality
      unless /^[0-9a-zA-Z\.\$\_]*$/ === password
        UI.error("Password contains special characters, which may not be handled properly by iTMSTransporter. If you experience problems uploading to iTunes Connect, please consider changing your password to something with only alphanumeric characters.")
      end
      # rubocop:enable Style/CaseEquality
      UI.error("Could not download/upload from iTunes Connect! It's probably related to your password or your internet connection.")
    end

    def execute_transporter(command)
      @errors = []
      @warnings = []

      if defined?@hide_transporter_output
        # Show a one time message instead
        UI.success("Waiting for iTunes Connect transporter to be finished.")
        UI.success("iTunes Transporter progress... this might take a few minutes...")
      end

      begin
        PTY.spawn(command) do |stdin, stdout, pid|
          stdin.each do |line|
            parse_line(line) # this is where the parsing happens
          end
        end
      rescue => ex
        UI.error(ex.to_s)
        @errors << ex.to_s
      end

      if @warnings.count > 0
        UI.important(@warnings.join("\n"))
      end

      if @errors.count > 0
        UI.error(@errors.join("\n"))
        return false
      end

      true
    end

    def parse_line(line)
      # Taken from https://github.com/sshaw/itunes_store_transporter/blob/master/lib/itunes/store/transporter/output_parser.rb

      output_done = false

      re = Regexp.union(SKIP_ERRORS)
      if line.match(re)
        # Those lines will not be handle like errors or warnings

      elsif line =~ ERROR_REGEX
        @errors << $1
        UI.error("[Transporter Error Output]: #{$1}")

        # Check if it's a login error
        if $1.include? "Your Apple ID or password was entered incorrectly" or
           $1.include? "This Apple ID has been locked for security reasons"

          unless Helper.is_test?
            CredentialsManager::AccountManager.new(user: @user).invalid_credentials
            UI.error("Please run this tool again to apply the new password")
          end
        elsif $1.include? "Redundant Binary Upload. There already exists a binary upload with build"
          UI.error($1)
          UI.error("You have to change the build number of your app to upload your ipa file")
        end

        output_done = true
      elsif line =~ WARNING_REGEX
        @warnings << $1
        UI.important("[Transporter Warning Output]: #{$1}")
        output_done = true
      end

      if line =~ RETURN_VALUE_REGEX
        if $1.to_i != 0
          UI.error("Transporter transfer failed.")
          UI.important(@warnings.join("\n"))
          UI.error(@errors.join("\n"))
          UI.crash!("Return status of iTunes Transporter was #{$1}: #{@errors.join('\n')}")
        else
          UI.success("iTunes Transporter successfully finished its job")
        end
      end

      if !defined?@hide_transporter_output and line =~ OUTPUT_REGEX
        # General logging for debug purposes
        unless output_done
          UI.verbose("[Transporter]: #{$1}")
        end
      end
    end

    def build_download_command(username, password, apple_id, destination = "/tmp")
      [
        '"' + Helper.transporter_path + '"',
        "-m lookupMetadata",
        "-u \"#{username}\"",
        "-p #{password.shellescape}",
        "-apple_id #{apple_id}",
        "-destination '#{destination}'"
      ].join(' ')
    end

    def build_upload_command(username, password, source = "/tmp")
      [
        '"' + Helper.transporter_path + '"',
        "-m upload",
        "-u \"#{username}\"",
        "-p #{password.shellescape}",
        "-f '#{source}'",
        ENV["DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS"], # that's here, because the user might overwrite the -t option
        "-t 'Signiant'",
        "-k 100000"
      ].join(' ')
    end
  end
end
