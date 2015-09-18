require 'google/api_client'

module Supply
  class Client
    # Connecting with Google
    attr_accessor :auth_client
    attr_accessor :api_client
    attr_accessor :android_publisher

    # Editing something
    # Reference to the entry we're currently editing. Might be nil if don't have one open
    attr_accessor :current_edit
    # Package name of the currently edited element
    attr_accessor :current_package_name

    # Initializes the auth_client and api_client using the specified information
    # @param path_to_key: The path to your p12 file
    # @param issuer: Email addresss for oauth
    # @param passphrase: Passphrase for the p12 file
    def initialize(path_to_key: nil, issuer: nil, passphrase: nil)
      passphrase ||= "notasecret"

      key = Google::APIClient::KeyUtils.load_from_pkcs12(File.expand_path(path_to_key), passphrase)

      begin
        self.auth_client = Signet::OAuth2::Client.new(
          token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
          audience: 'https://accounts.google.com/o/oauth2/token',
          scope: 'https://www.googleapis.com/auth/androidpublisher',
          issuer: issuer,
          signing_key: key
        )
      rescue => ex
        Helper.log.fatal ex
        raise "Authentification unsuccessful, make sure to pass a valid key file".red
      end

      Helper.log.debug "Fetching a new access token from Google..."

      self.auth_client.fetch_access_token!

      self.api_client = Google::APIClient.new(
        application_name: "fastlane - supply",
        application_version: Supply::VERSION
      )

      self.android_publisher = api_client.discovered_api('androidpublisher', 'v2')
    end

    # Begin modifying a certain package
    def begin_edit(package_name: nil)
      raise "You currently have an active edit" if @current_edit

      self.current_edit = api_client.execute(
        api_method: android_publisher.edits.insert,
        parameters: { 'packageName' => package_name },
        authorization: auth_client
      )

      if current_edit.error?
        error_message = current_edit.error_message
        self.current_edit = nil
        raise error_message
      end

      self.current_package_name = package_name
    end

    # Get a list of all languages - returns the list
    # make sure to have an active edit
    def listings
      ensure_active_edit!

      result = api_client.execute(
        api_method: android_publisher.edits.listings.list,
        parameters: {
            'editId' => current_edit.data.id,
            'packageName' => current_package_name
        },
        authorization: auth_client
      )

      raise result.error_message if result.error? && result.status != 404

      return result.data.listings.collect do |row|
        Listing.new(self, row.language, row)
      end
    end

    private

    def ensure_active_edit!
      raise "You need to have an active edit, make sure to call `begin_edit`" unless @current_edit
    end
  end
end
