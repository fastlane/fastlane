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


Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)


-------
<p align="center">
    insert points here
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>spaceship</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Installation

    sudo gem install spaceship

# Usage

Spaceship is library designed to provide an interface to all of the functionality of Apple's Developer Portal via a simple HTTP client.


## Authorization

In order to use the library you must login with you Apple ID credentials. This
only needs to be done once during the lifetime of your app as the authenticated
client is shared. Your credentials are not saved anywhere.


```ruby
Spaceship.login(username, password)
```

### Multiple Teams

Show a UI to the user:

```ruby
Spaceship.UI.select_team
```

Set a team manually

```ruby
Spaceship.client.current_team_id = "5A997XSHAA"
```

### App Ids

For instance, this is how you can list all of your app ids:
```ruby
Spaceship.apps.each do |app|
  puts app
end
```

Finding an app by it's bundle_id
```ruby
app = Spaceship.apps.find('tools.fastlane.test-app')
```

Creating an app:
```ruby
Spaceship.apps.create!('com.company.appname', 'Next Big App')
```

### Certificates

Download a certificate:

```ruby
certificates = Spaceship.certificates

x509_cert = certificates.download('CERTID')
File.write('/tmp/test', x509_cert.to_pem)
```

Filter by certificate types:
```ruby
push_certs = Spaceship.certificates.select {|c| c.kind_of?(Spaceship::Certificates::PushCertificate) }
#or
prod_push_certs = Spaceship.certificates.select {|c| c.kind_of?(Spaceship::Certificates::ProductionPush) }
```

Create a new certificate

```ruby
csr = Spaceship::Certificates.certificate_signing_request
Spaceship.certificates.create!(Spaceship::Certificates::ProductionPush, csr, 'tools.fastlane.test-app')
```

### Provisioning Profiles

List provisioning profiles
```ruby
profiles = Spaceship.provisioning_profiles
```

create a distribution provisioning profile for an app
```ruby
production_cert = Spaceship.certificates.select {|c| c.is_a?(Spaceship::Certificates::Production)}.first
Spaceship.provisioning_profiles.create!(Spaceship::ProvisioningProfiles::AppStore, 'Flappy Bird 2.0', 'tools.fastlane.flappy-bird', production_cert)
```

Named Parameters
```ruby
Spaceship.provisioning_profiles.create!(
    klass: Spaceship::ProvisioningProfiles::Development,
    name: "Spaceship",
    bundle_id: "net.sunapps.1",
    certificate: Spaceship.certificates.all_of_type(Spaceship::Certificates::Development).first,
    devices: [Spaceship.devices.first]
)
```

download the .mobileprovision profile
```ruby
file = Spaceship.provisioning_profiles.download('tools.fastlane.flappy-bird')
```

Check out the wiki for a full list of all supported actions.


The goal is to get to a point to be able to do this:

```ruby
Spaceship.login

app = Spaceship.apps.create!(identifier: ‘com.krausefx.app’, name: ‘New App’)

profile = app.provisioning_profiles.create!(
  type: :appstore,
  name: "Spaceship Profile"
)

profile.download
```

## Debugging

In order to inspect traffic during development, it is useful to enable network debugging.
A man-in-the-middle proxy such as Charles or mitmproxy on `localhost:8080` is required for this to work.

### Example

`$ brew install mitmproxy`

`$ mitmproxy`

in another terminal

`$ DEBUG=1 bundle exec pry -rspaceship`

`>> Spaceship.login('username', 'password')`

You should see the requests and responses in mitmproxy

## Credit

This project has been sponsored by [https://zeropush.com](ZeroPush).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to start a discussion about your idea
2. Fork it (https://github.com/KrauseFx/spaceship/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

