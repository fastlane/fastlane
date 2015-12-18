require 'credentials_manager/version'

module CredentialsManager
  class CLI
    REQUIRED_PARAMS = %i(username password)

    def initialize(args)
      @args = args
      @options = {}

      parse
      validate
    end

    def execute
      puts @options
    end

    private

    # Parse the option list
    def parse
      OptionParser.new do |opts|
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
      end.parse!(@args)
    end

    # Ensure that all required paramters are present
    def validate
      # Required parameters that were not specified
      diff = REQUIRED_PARAMS - @options.keys

      unless diff.empty?
        diff.each { |key| raise OptionParser::MissingArgument, key.to_s }
      end
    end
  end
end
