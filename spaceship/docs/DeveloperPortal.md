Developer Portal API
====================

# Usage

To quickly play around with `spaceship` launch `irb` in your terminal and execute `require "spaceship"`.

## Login

*Note*: If you use both the Developer Portal and iTunes Connect API, you'll have to login on both, as the user might have different user credentials.

```ruby
Spaceship::Portal.login("felix@krausefx.com", "password")

Spaceship::Portal.select_team # call this method to let the user select a team
```

## Apps

```ruby
# Fetch all available apps
all_apps = Spaceship::Portal.app.all

# Find a specific app based on the bundle identifier
app = Spaceship::Portal.app.find("com.krausefx.app")

# Show the names of all your apps
Spaceship::Portal.app.all.collect do |app|
  app.name
end

# Create a new app
app = Spaceship::Portal.app.create!(bundle_id: "com.krausefx.app_name", name: "fastlane App")
```

### App Services

App Services are part of the application, however, they are one of the few things that can be changed about the app once it has been created.

Currently available services include (all require the `Spaceship::Portal.app_service.` prefix)

```
app_group.(on|off)
apple_pay.(on|off)
associated_domains.(on|off)
data_protection.(complete|unless_open|until_first_auth|off)
game_center.(on|off)
health_kit.(on|off)
home_kit.(on|off)
wireless_accessory.(on|off)
icloud.(on|off)
cloud_kit.(xcode5_compatible|cloud_kit)
in_app_purchase.(on|off)
inter_app_audio.(on|off)
passbook.(on|off)
push_notification.(on|off)
siri_kit.(on|off)
vpn_configuration.(on|off)
network_extension.(on|off)
hotspot.(on|off)
multipath.(on|off)
nfc_tag_reading.(on|off)
```

Examples:

```ruby
# Find a specific app based on the bundle identifier
app = Spaceship::Portal.app.find("com.krausefx.app")

# Get detail informations (e.g. see all enabled app services)
app.details

# Enable HealthKit, but make sure HomeKit is disabled
app.update_service(Spaceship::Portal.app_service.health_kit.on)
app.update_service(Spaceship::Portal.app_service.home_kit.off)
app.update_service(Spaceship::Portal.app_service.vpn_configuration.on)
app.update_service(Spaceship::Portal.app_service.passbook.off)
app.update_service(Spaceship::Portal.app_service.cloud_kit.cloud_kit)
```

## App Groups

```ruby
# Fetch all existing app groups
all_groups = Spaceship::Portal.app_group.all

# Find a specific app group, based on the identifier
group = Spaceship::Portal.app_group.find("group.com.example.application")

# Show the names of all the groups
Spaceship::Portal.app_group.all.collect do |group|
  group.name
end

# Create a new group
group = Spaceship::Portal.app_group.create!(group_id: "group.com.example.another",
                                        name: "Another group")

# Associate an app with this group (overwrites any previous associations)
# Assumes app contains a fetched app, as described above
app = app.associate_groups([group])
```

## Apple Pay Merchants

```ruby
# Fetch all existing merchants
all_merchants = Spaceship::Portal.merchant.all

# Find a specific merchant, based on the identifier
sandbox_merchant = Spaceship::Portal.merchant.find("merchant.com.example.application.sandbox")

# Show the names of all the merchants
Spaceship::Portal.merchant.all.collect do |merchant|
  merchant.name
end

# Create a new merchant
another_merchant = Spaceship::Portal.merchant.create!(bundle_id: "merchant.com.example.another", name: "Another merchant")

# Delete a merchant
another_merchant.delete!

# Associate an app with merchant/s (overwrites any previous associations)
# Assumes app contains a fetched app, as described above
app = app.associate_merchants([sandbox_merchant, production_merchant])
```

## Passbook

```ruby
# Fetch all existing passbooks
all_passbooks = Spaceship::Portal.passbook.all

# Find a specific passbook, based on the identifier
passbook = Spaceship::Portal.passbook.find("pass.com.example.passbook")

# Create a new passbook
passbook = Spaceship::Portal.passbook.create!(bundle_id: 'pass.com.example.passbook', name: 'Fastlane Passbook')

# Delete a passbook using his identifier
passbook = Spaceship::Portal.passbook.find("pass.com.example.passbook").delete!

```

## Certificates

```ruby
# Fetch all available certificates (includes signing and push profiles)
certificates = Spaceship::Portal.certificate.all
```

### Code Signing Certificates

```ruby
# Production identities
prod_certs = Spaceship::Portal.certificate.production.all

# Development identities
dev_certs = Spaceship::Portal.certificate.development.all

# Download a certificate
cert_content = prod_certs.first.download
```

### Push Certificates
```ruby
# Production push profiles
prod_push_certs = Spaceship::Portal.certificate.production_push.all

# Development push profiles
dev_push_certs = Spaceship::Portal.certificate.development_push.all

# Download a push profile
cert_content = dev_push_certs.first.download

# Creating a push certificate

# Create a new certificate signing request
csr, pkey = Spaceship::Portal.certificate.create_certificate_signing_request

# Use the signing request to create a new push certificate
Spaceship::Portal.certificate.production_push.create!(csr: csr, bundle_id: "com.krausefx.app")
```

### Create a Certificate

```ruby
# Create a new certificate signing request
csr, pkey = Spaceship::Portal.certificate.create_certificate_signing_request

# Use the signing request to create a new distribution certificate
Spaceship::Portal.certificate.production.create!(csr: csr)
```

## Provisioning Profiles

### Receiving profiles

```ruby
##### Finding #####

# Get all available provisioning profiles
profiles = Spaceship::Portal.provisioning_profile.all

# Get all App Store and Ad Hoc profiles
# Both app_store.all and ad_hoc.all return the same
# This is the case since September 2016, since the API has changed
# and there is no fast way to get the type when fetching the profiles
profiles_appstore_adhoc = Spaceship::Portal.provisioning_profile.app_store.all
profiles_appstore_adhoc = Spaceship::Portal.provisioning_profile.ad_hoc.all

# To distinguish between App Store and Ad Hoc profiles use
adhoc_only = profiles_appstore_adhoc.find_all do |current_profile|
  current_profile.is_adhoc?
end

# Get all Development profiles
profiles_dev = Spaceship::Portal.provisioning_profile.development.all

# Fetch all profiles for a specific app identifier for the App Store (Array of profiles)
filtered_profiles = Spaceship::Portal.provisioning_profile.app_store.find_by_bundle_id("com.krausefx.app")

# Check if a provisioning profile is valid
profile.valid?

# Verify that the certificate of the provisioning profile is valid
profile.certificate_valid?

##### Downloading #####

# Download a profile
profile_content = profiles.first.download

# Download a specific profile as file
matching_profiles = Spaceship::Portal.provisioning_profile.app_store.find_by_bundle_id("com.krausefx.app")
first_profile = matching_profiles.first

File.write("output.mobileprovision", first_profile.download)
```

### Create a Provisioning Profile

```ruby
# Choose the certificate to use
cert = Spaceship::Portal.certificate.production.all.first

# Create a new provisioning profile with a default name
# The name of the new profile is "com.krausefx.app AppStore"
profile = Spaceship::Portal.provisioning_profile.app_store.create!(bundle_id: "com.krausefx.app",
                                                         certificate: cert)

# AdHoc Profiles will add all devices by default
profile = Spaceship::Portal.provisioning_profile.ad_hoc.create!(bundle_id: "com.krausefx.app",
                                                      certificate: cert,
                                                             name: "Profile Name")

# Store the new profile on the filesystem
File.write("NewProfile.mobileprovision", profile.download)
```

### Repair all broken provisioning profiles

```ruby
# Select all 'Invalid' or 'Expired' provisioning profiles
broken_profiles = Spaceship::Portal.provisioning_profile.all.find_all do |profile|
  # the below could be replaced with `!profile.valid? || !profile.certificate_valid?`, which takes longer but also verifies the code signing identity
  (profile.status == "Invalid" or profile.status == "Expired")
end

# Iterate over all broken profiles and repair them
broken_profiles.each do |profile|
  profile.repair! # yes, that's all you need to repair a profile
end

# or to do the same thing, just more Ruby like
Spaceship::Portal.provisioning_profile.all.find_all { |p| !p.valid? || !p.certificate_valid? }.map(&:repair!)
```

## Devices

```ruby
# Get all enabled devices
all_devices = Spaceship::Portal.device.all

# Disable first device
all_devices.first.disable!

# Find disabled device and enable it
Spaceship::Portal.device.find_by_udid("44ee59893cb...", include_disabled: true).enable!

# Get list of all devices, including disabled ones, and filter the result to only include disabled devices use enabled? or disabled? methods
disabled_devices = Spaceship::Portal.device.all(include_disabled: true).select do |device|
  !device.enabled?
end

# or to do the same thing, just more Ruby like with disabled? method
disabled_devices = Spaceship::Portal.device.all(include_disabled: true).select(&:disabled?)

# Register a new device
Spaceship::Portal.device.create!(name: "Private iPhone 6", udid: "5814abb3...")
```

## Enterprise

```ruby
# Use the InHouse class to get all enterprise certificates
cert = Spaceship::Portal.certificate.in_house.all.first

# Create a new InHouse Enterprise distribution profile
profile = Spaceship::Portal.provisioning_profile.in_house.create!(bundle_id: "com.krausefx.*",
                                                        certificate: cert)

# List all In-House Provisioning Profiles
profiles = Spaceship::Portal.provisioning_profile.in_house.all
```

## Multiple Spaceships

Sometimes one `spaceship` just isn't enough. That's why this library has its own Spaceship Launcher to launch and use multiple `spaceships` at the same time :rocket:

```ruby
# Launch 2 spaceships
spaceship1 = Spaceship::Launcher.new("felix@krausefx.com", "password")
spaceship2 = Spaceship::Launcher.new("stefan@spaceship.airforce", "password")

# Fetch all registered devices from spaceship1
devices = spaceship1.device.all

# Iterate over the list of available devices
# and register each device from the first account also on the second one
devices.each do |device|
  spaceship2.device.create!(name: device.name, udid: device.udid)
end
```

## More cool things you can do
```ruby
# Find a profile with a specific name
profile = Spaceship::Portal.provisioning_profile.development.all.find { |p| p.name == "Name" }

# Add all available devices to the profile
profile.devices = Spaceship::Portal.device.all

# Push the changes back to the Apple Developer Portal
profile.update!

# Get the currently used team_id
Spaceship::Portal.client.team_id

app = Spaceship::Portal.app.find("com.krausefx.app")

# Update app name
app.update_name!('New App Name')

# We generally don't want to be destructive, but you can also delete things
# This method might fail for various reasons, e.g. app is already in the store
app.delete!
```

## Example Data

Some unnecessary information was removed, check out [provisioning_profile.rb](https://github.com/fastlane/fastlane/blob/master/spaceship/lib/spaceship/portal/provisioning_profile.rb) for all available attributes.

The example data below is a provisioning profile, containing a device, certificate and app.

```
#<Spaceship::ProvisioningProfile::AdHoc
  @devices=[
    #<Spaceship::Device
      @id="5YTNZ5A9AA",
      @name="Felix iPhone 6",
      @udid="39d2cab02642dc2bfdbbff4c0cb0e50c8632faaa"
    >,  ...],
  @certificates=[
    #<Spaceship::Certificate::Production
      @id="LHNT9C2AAA",
      @name="iOS Distribution",
      @expires=#<DateTime: 2016-02-10T23:44:20>
    ],
  @id="72SRVUNAAA",
  @uuid="43cda0d6-04a5-4964-89c0-a24b5f258aaa",
  @expires=#<DateTime: 2016-02-10T23:44:20>,
  @distribution_method="adhoc",
  @name="com.krausefx.app AppStore",
  @status="Active",
  @platform="ios",
  @app=#<Spaceship::App
    @app_id="2UMR2S6AAA",
    @name="App Name",
    @platform="ios",
    @bundle_id="com.krausefx.app",
    @is_wildcard=false>
  >
>
```

### License

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
