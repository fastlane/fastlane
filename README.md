<h3 align="center">
  <a href="https://github.com/KrauseFx/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/KrauseFx/deliver">deliver</a> &bull;
  <a href="https://github.com/KrauseFx/snapshot">snapshot</a> &bull;
  <a href="https://github.com/KrauseFx/frameit">frameit</a> &bull;
  <a href="https://github.com/KrauseFx/PEM">PEM</a> &bull;
  <a href="https://github.com/KrauseFx/sigh">sigh</a> &bull;
  <a href="https://github.com/KrauseFx/produce">produce</a> &bull;
  <a href="https://github.com/KrauseFx/cert">cert</a> &bull;
  <a href="https://github.com/KrauseFx/codes">codes</a>
</p>
-------

<p align="center">
    <img src="assets/spaceship.png">
</p>

spaceship
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/spaceship/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/spaceship.svg?style=flat)](http://rubygems.org/gems/spaceship)
[![Codeship Status for KrauseFx/spaceship](https://img.shields.io/codeship/96bb1040-c2b6-0132-4c5b-22f8b41c2618/master.svg)](https://codeship.com/projects/73801)


Get in contact with the developers on Twitter: [@snatchev](https://twitter.com/snatchev/) and [@KrauseFx](https://twitter.com/KrauseFx)


-------
<p align="center">
    <a href="#why">Why?</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#technical-details">Technical Details</a>  &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>spaceship</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# What's Spaceship?

> `spaceship` is named after the new Apple HQ in Cupertino. It allows you to seamlessly interact with the Apple Developer Portal using very simple Ruby code. 

`spaceship` uses simple HTTPs requests without any sort of web scraping. This allows `spaceship` to have a 95% test coverage.

Using `spaceship`, the execution time of [sigh](https://github.com/KrauseFx/sigh) was reduced from over 1 minute to less than 5 seconds :rocket:

`spaceship` uses a combination of 3 different API endpoints, used by the Apple Developer Portal and Xcode. As no API offers everything we need, `spaceship` combines all APIs for you, so you don't have to think about it. [More details about the APIs](#technical-details).

Up until now, the [fastlane tools](https://fastlane.tools) use web scraping to interact with Apple's web services. By upgrading them to use `spaceship` all [fastlane tools](https://fastlane.tools) will be even faster and much more stable.

> No matter how many apps or profiles you have, `spaceship` **can** handle your scale.

Enough words, here is some code:

```ruby
Spaceship.login
 
# Create a new app
app = Spaceship::App.create!(bundle_id: "com.krausefx.app", name: "Spaceship App")
 
# Use an existing certificate
cert = Spaceship::Certificate::Production.all.first
 
# Create a new provisioning profile
profile = Spaceship::ProvisioningProfile::AppStore.create!(bundle_id: app.bundle_id,
                                                         certificate: cert)
 
# Print the name and download the new profile
puts "Created Profile " + profile.name
profile.download
```

# Installation

    sudo gem install spaceship

# Usage

## Login

```ruby
Spaceship.login("felix@krausefx.com", "password")

Spaceship.client.select_team # call this method to let the user select a team
```

## Apps

```ruby
# Fetch all available apps
all_apps = Spaceship.apps

# Find a specific app based on the bundle identifier
app = Spaceship.apps.find("com.krausefx.app")

# Show the names of all your apps
Spaceship.apps.each do |app|
  puts app.name
end

# Create a new app
app = Spaceship::App.create!(bundle_id: "com.krausefx.app_name", name: "fastlane App")
```

## Certificates

```ruby
# Fetch all available certificates (includes signing and push profiles)
certificates = Spaceship.certificates
```

### Code Signing Certificates

```ruby
# Production identities
prod_certs = Spaceship::Certificate::Production.all

# Development identities
dev_certs = Spaceship::Certificate::Development.all

# Download a certificate
cert_content = prod_certs.first.download
```

### Push Certificates
```ruby
# Production push profiles
prod_push_certs = Spaceship::Certificate::ProductionPush.all

# Development push profiles
dev_push_certs = Spaceship::Certificate::DevelopmentPush.all

# Download a push profile
cert_content = dev_push_certs.first.download
```

### Create a Certificate

```ruby
# Create a new certificate signing request
csr = Spaceship::Certificate.create_certificate_signing_request

# Use the signing request to create a new distribution certificate
Spaceship::Certificate::Production.create!(csr: csr)

# Use the signing request to create a new push certificate
Spaceship::Certificate::ProductionPush.create!(csr: csr, bundle_id: "com.krausefx.app")
```

## Provisioning Profiles

### Receiving profiles

```ruby
##### Finding #####

# Get all available provisioning profiles
profiles = Spaceship.provisioning_profiles

# Get all App Store profiles
profiles_appstore = Spaceship::ProvisioningProfile::AppStore.all

# Get all AdHoc profiles
profiles_adhoc = Spaceship::ProvisioningProfile::AdHoc.all

# Get all Development profiles
profiles_dev = Spaceship::ProvisioningProfile::Development.all

# Fetch all profiles for a specific app identifier for the App Store
filtered_profiles = Spaceship::ProvisioningProfile::AppStore.find_by_bundle_id("com.krausefx.app")

##### Downloading #####

# Download a profile
profile_content = profiles.first.download

# Download a specific profile as file
my_profile = Spaceship::ProvisioningProfile::AppStore.find_by_bundle_id("com.krausefx.app")
File.write("output.mobileprovision", my_profile.download)
```

### Create a Provisioning Profile

```ruby
# Choose the certificate to use
cert = Spaceship::Certificate::Production.all.first

# Create a new provisioning profile with a default name
# The name of the new profile is "com.krausefx.app AppStore"
profile = Spaceship::ProvisioningProfile::AppStore.create!(bundle_id: "com.krausefx.app",
                                                         certificate: cert)

# AdHoc Profiles will add all devices by default
profile = Spaceship::ProvisioningProfile::AdHoc.create!(bundle_id: "com.krausefx.app",
                                                      certificate: cert,
                                                             name: "Such Custom Name, Much Special")

# Store the new profile on the filesystem
File.write("NewProfile.mobileprovision", profile.download)
```

### Repair a broken provisioning profile

```ruby
# Select all 'Invalid' or 'Expired' provisioning profiles
broken_profiles = Spaceship.provisioning_profiles.find_all do |profile| 
  (profile.status == "Invalid" or profile.status == "Expired")
end

# Iterate over all broken profiles and repair them
broken_profiles.each do |profile|
  profile.repair! # yes, that's all you need to repair a profile
end

# or to make the same thing, just more Ruby like:
Spaceship.provisioning_profiles.find_all { |p| %w[Invalid Expired].include?p.status}.map(&:repair!)
```

## Devices

```ruby
all_devices = Spaceship.devices

# Register a new device
Spaceship::Device.create!(name: "Private iPhone 6", udid: "5814abb3...")
```

## Enterprise

```ruby
# Use the InHouse class to get all enterprise certificates
cert = Spaceship::Certificate::InHouse.all.first 

# Create a new InHouse Enterprise distribution profile
profile = Spaceship::ProvisioningProfile::AppStore.create!(bundle_id: "com.krausefx.*",
                                                         certificate: cert)
```

## More cool things you can do
```ruby
# Find a profile with a specific name
profile = Spaceship::ProvisioningProfile::Development.all.find { |p| p.name == "ProfileName" }

# Add all available devices to the profile
profile.devices = Spaceship.devices

# Push the changes back to the Apple Developer Portal
profile.update!

# Get the currently used team_id
Spaceship.client.team_id

# We generally don't want to be destructive, but you can also delete things
# This method might fail for various reasons, e.g. app is already in the store
app = Spaceship.apps.find("com.krausefx.app")
app.delete!
```

## Example Data

Some unnecessary information was removed, check out [provisioning_profile.rb](https://github.com/KrauseFx/spaceship/blob/master/lib/spaceship/provisioning_profile.rb) for all available attributes.

The example data below is a provisioning profile, containg a device, certificate and app. 

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

# Technical Details

## HTTP Client

Up until now all [fastlane tools](https://fastlane.tools) used web scraping to interact with Apple's web services. `spaceship` uses a simple HTTP client only, resulting in much less overhead and drastically improved speed. 

Advantages of `spaceship` (HTTP client) over web scraping: 

- Blazing fast :rocket: 90% faster than previous methods
- No more overhead by loading images, HTML, JS and CSS files on each page load
- Great test coverage by stubbing server responses
- Resistant against design changes of the Apple Developer Portal
- Automatic re-trying of requests in case a timeout occurs
- By stubbing the `spaceship` objects it is possible to also implement tests for tools like [sigh](https://github.com/KrauseFx/sigh)

## API Endpoints

I won't go into too much technical details about the various API endpoints, but just to give you an idea:

- `https://idmsa.apple.com`: Used to authenticate and get a valid session
- `https://developerservices2.apple.com`: Used to get a detailed list of all available provisioning profiles. This API requires the devices, certificates and app for each of the profiles.
- `https://developer.apple.com`: 
 - List all devices, certificates and apps
 - Create new certificates, provisioning profiles and apps
 - Delete certificates and apps
 - Repair provisioning profiles
 - Download provisioning profiles
 - Team selection

`spaceship` uses all those API points to offer this seamless experience.

## Magic involved

`spaceship` does a lot of magic to get everything working so neatly: 

- **Sensible Defaults**: You only have to provide the mandatory information (e.g. new provisioning profiles contain all devices by default)
- **Local Validation**: When pushing changes back to the Apple Dev Portal `spaceship` will make sure only valid data is sent to Apple (e.g. automatic repairing of provisioning profiles)
- **Various request/response types**: When working with the different API endpoints, `spaceship` has to deal with `JSON`, `XML`, `txt`, `plist` and sometimes even `HTML` responses and requests. 
- **Automatic Pagination**: Even if you have thousands of apps, profiles or certificates, `spaceship` **can** handle your scale. It was heavily tested by first using `spacehip` to create hundreds of profiles and then accessing them using `spaceship`.
- **Session, Cookie and CSRF token**: All the security aspects are handled by `spaceship`.
- **Profile Magic**: Create and upload code signing requests, all managed by `spaceship`

# Credits

This project has been sponsored by [ZeroPush](https://zeropush.com). `spaceship` was developed by [@snatchev](https://twitter.com/snatchev/) and [@KrauseFx](https://twitter.com/KrauseFx).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to start a discussion about your idea
2. Fork it (https://github.com/KrauseFx/fastlane/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
