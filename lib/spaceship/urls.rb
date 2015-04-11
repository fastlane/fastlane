module Spaceship
  class Client
    ######## GENERAL ########
    PROTOCOL_VERSION = "QH65B2"

    ######## LOGIN ########
    # URL that contains the "Sign In" button, which is required to log in successfully
    URL_LOGIN_LANDING_PAGE = "https://developer.apple.com/devcenter/ios/index.action" # Dev Portal

    # Used to send the username + password to generate a valid session
    URL_AUTHENTICATE = "https://idmsa.apple.com/IDMSWebAuth/authenticate" # Mixed - Dev Portal

    ######## Select Team ########
    # A list of all teams for the given Apple ID
    URL_LIST_TEAMS = "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/listTeams.action" # Xcode

    ######## Certificates ########
    # List of all certificates, including push certificates and code signing identities
    # There must be parameters for the teamId and the types to use
    URL_LIST_CERTIFICATES = "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/account/ios/certificate/listCertRequests.action?certificateStatus=0&" # Dev Portal

    ######## Provisioning Profiles ########
    # Lists all available provisioning profiles
    URL_LIST_PROVISIONING_PROFILES = "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/ios/listProvisioningProfiles.action" # Xcode

    # Download a specific provisioning profile
    URL_DOWNLOAD_PROVISIONING_PROFILE = "https://developer.apple.com/account/ios/profile/profileContentDownload.action?displayId=" # Dev Portal

    # Create a new provisioning profile
    URL_CREATE_PROVISIONING_PROFILE = "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/account/ios/profile/createProvisioningProfile.action?teamId=" # Dev Portal

    # Request with a list of provisioning profiles, which we don't use. We need this request just for the CSRF values
    URL_GET_CSRF_VALUES = "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/account/ios/profile/listProvisioningProfiles.action?teamId=" # Dev Portal

    ######## Device Management ########
    # List all devices enabled for this Apple ID
    URL_LIST_DEVICES = "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/ios/listDevices.action" # Xcode

    ######## App IDs ########
    # List all available App IDs
    URL_APP_IDS = "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/account/ios/identifiers/listAppIds.action" # Dev Portal
  end
end