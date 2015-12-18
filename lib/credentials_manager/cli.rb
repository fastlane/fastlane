require 'credentials_manager/version'

module CredentialsManager
  class CLI
    VALID_COMMANDS = %i(add remove)

    REQUIRED_PARAMS = {
      add: %i(username password),
      remove: %i(username)
    }

    def initialize(args)
      @args = args
      @options = {}

      begin
        parse
        validate
      rescue => ex
        # If we have a missing argument, print out the help
        puts ex.message.capitalize
        puts parser
      end
    end

    # Perform actions based on data
    def execute
      case @command
      when :add
        CredentialsManager::AccountManager.new(
          user: @options[:username],
          password: @options[:password]
        ).add_to_keychain

        puts "Credential #{@options[:username]}:#{'*' * @options[:password].length} added to keychain."
      when :remove
        CredentialsManager::AccountManager.new(
          user: @options[:username]
        ).remove_from_keychain
      end
    end

    private

    # Generate the options parser
    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = 'Usage: fastlane-credentials [command] [-options]'

        opts.on('-u', '--username [username]', 'Set a username') do |username|
          @options[:username] = username
        end

        opts.on('-p', '--password [password]', 'Set a password') do |password|
          @options[:password] = password
        end

        opts.on_tail("-h", "--help", 'See program help.') do
          puts opts
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail("-v", "--version", 'Show version.') do
          puts ::CredentialsManager::VERSION
          exit
        end
      end
    end

    # Parse the option list
    def parse
      parser.parse!(@args)

      # First non-option argument
      command = @args.pop
      if command
        @command = command.to_sym
      else
        raise OptionParser::MissingArgument, 'command'
      end
    end

    # Perform all necessary validations
    def validate
      validate_command
      validate_options
    end

    # Ensure that the entered command is valid
    def validate_command
      unless VALID_COMMANDS.include? @command
        raise "#{@command} is not a valid command. Must be one of #{VALID_COMMANDS.join(', ')}"
      end
    end

    # Ensure that all required paramters are present
    def validate_options
      # Required parameters that were not specified
      diff = REQUIRED_PARAMS[@command] - @options.keys

      unless diff.empty?
        diff.each { |key| raise OptionParser::MissingArgument, key.to_s }
      end
    end
  end
end
