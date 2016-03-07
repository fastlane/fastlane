<h3 align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/fastlane">
    <img src="assets/fastlane.png" width="100" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/deliver">deliver</a> &bull; 
  <a href="https://github.com/fastlane/fastlane/tree/master/snapshot">snapshot</a> &bull; 
  <a href="https://github.com/fastlane/fastlane/tree/master/frameit">frameit</a> &bull; 
  <a href="https://github.com/fastlane/fastlane/tree/master/pem">pem</a> &bull; 
  <a href="https://github.com/fastlane/fastlane/tree/master/sigh">sigh</a> &bull; 
  <a href="https://github.com/fastlane/fastlane/tree/master/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/cert">cert</a> &bull;
  <b>spaceship</b> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/scan">scan</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/match">match</a>
</p>
-------

<p align="center">
  <img src="assets/spaceship.png" width="470">
</p>
-------

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/LICENSE)
[![Coverage Status](https://coveralls.io/repos/fastlane/spaceship/badge.svg?branch=master&t=ldL8gg)](https://coveralls.io/r/fastlane/spaceship?branch=master)
[![Gem](https://img.shields.io/gem/v/spaceship.svg?style=flat)](http://rubygems.org/gems/spaceship)
[![Build Status](https://img.shields.io/travis/fastlane/spaceship/master.svg?style=flat)](https://travis-ci.org/fastlane/spaceship)


Get in contact with the developers on Twitter: [@KrauseFx](https://twitter.com/KrauseFx) and [@snatchev](https://twitter.com/snatchev)


-------
<p align="center">
    <a href="#whats-spaceship">Why?</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#technical-details">Technical Details</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>spaceship</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

# What's spaceship?

spaceship is a Ruby library that exposes both the Apple Developer Center and the iTunes Connect API. It’s super fast, well tested and supports all of the operations you can do via the browser. Scripting your Developer Center workflow has never been easier!

Up until now, the [fastlane tools](https://fastlane.tools) used web scraping to interact with Apple's web services. With spaceship it is possible to directly access the underlying APIs using a simple HTTP client only.

Using spaceship, the execution time of [sigh](https://github.com/fastlane/fastlane/tree/master/sigh) was reduced from over 1 minute to less than 5 seconds.

spaceship uses a combination of 3 different API endpoints, used by the Apple Developer Portal and Xcode. As no API offers everything we need, spaceship combines all APIs for you. [More details about the APIs](#technical-details).

More details about why spaceship is useful on [spaceship.airforce](https://spaceship.airforce).

> No matter how many apps or certificates you have, spaceship **can** handle your scale.

Enough words, here is some code:

```ruby
Spaceship.login

# Create a new app
app = Spaceship.app.create!(bundle_id: "com.krausefx.app", name: "Spaceship App")

# Use an existing certificate
cert = Spaceship.certificate.production.all.first

# Create a new provisioning profile
profile = Spaceship.provisioning_profile.app_store.create!(bundle_id: app.bundle_id,
                                                         certificate: cert)

# Print the name and download the new profile
puts "Created Profile " + profile.name
profile.download
```

## Speed

How fast are tools using `spaceship` compared to web scraping?

![assets/SpaceshipRecording.gif](assets/SpaceshipRecording.gif)

# Installation

    sudo gem install spaceship

# Usage

## Playground

To try `spaceship`, just run `spaceship`. It will automatically start the `spaceship playground`. It makes it super easy to try `spaceship` :rocket:

![assets/docs/Playground.png](assets/docs/Playground.png)

This requires you to install `pry` using `sudo gem install pry`. `pry` is not installed by default, as most [fastlane](https://fastlane.tools) users won't need the `spaceship playground`. You can add the `pry` dependency to your `Gemfile`.

## Apple Developer Portal API

##### Open [DeveloperPortal.md](docs/DeveloperPortal.md) for code samples

## iTunes Connect API

##### Open [iTunesConnect.md](docs/iTunesConnect.md) for code samples

### Spaceship in use

Most [fastlane tools](https://fastlane.tools) already use `spaceship`, like `sigh`, `cert`, `produce`, `pilot` and `boarding`.

### Full Documentation

The detailed documentation of all available classes is available on [RubyDoc](http://www.rubydoc.info/github/fastlane/spaceship/frames).

You can find the log file here `/tmp/spaceship[time]_[pid].log`.

# Technical Details

## HTTP Client

Up until now all [fastlane tools](https://fastlane.tools) used web scraping to interact with Apple's web services. `spaceship` uses a simple HTTP client only, resulting in much less overhead and extremely improved speed.

Advantages of `spaceship` (HTTP client) over web scraping:

- Blazing fast :rocket: 90% faster than previous methods
- No more overhead by loading images, HTML, JS and CSS files on each page load
- Great test coverage by stubbing server responses
- Resistant against design changes of the Apple Developer Portal
- Automatic re-trying of requests in case a timeout occurs

## API Endpoints

I won't go into too much technical details about the various API endpoints, but just to give you an idea:

- `https://idmsa.apple.com`: Used to authenticate to get a valid session
- `https://developerservices2.apple.com`:
 - Get a detailed list of all available provisioning profiles
 - This API returns the devices, certificates and app for each of the profiles
 - Register new devices
- `https://developer.apple.com`:
 - List all devices, certificates, apps and app groups
 - Create new certificates, provisioning profiles and apps
 - Disable/enable services on apps and assign them to app groups
 - Delete certificates and apps
 - Repair provisioning profiles
 - Download provisioning profiles
 - Team selection
- `https://itunesconnect.apple.com`:
 - Managing apps
 - Managing beta testers
 - Submitting updates to review
 - Managing app metadata
- `https://du-itc.itunesconnect.apple.com`:
 - Upload icons, screenshots, trailers ...

`spaceship` uses all those API points to offer this seamless experience.

## Magic involved

`spaceship` does a lot of magic to get everything working so neatly:

- **Sensible Defaults**: You only have to provide the mandatory information (e.g. new provisioning profiles contain all devices by default)
- **Local Validation**: When pushing changes back to the Apple Dev Portal `spaceship` will make sure only valid data is sent to Apple (e.g. automatic repairing of provisioning profiles)
- **Various request/response types**: When working with the different API endpoints, `spaceship` has to deal with `JSON`, `XML`, `txt`, `plist` and sometimes even `HTML` responses and requests.
- **Automatic Pagination**: Even if you have thousands of apps, profiles or certificates, `spaceship` **can** handle your scale. It was heavily tested by first using `spaceship` to create hundreds of profiles and then accessing them using `spaceship`.
- **Session, Cookie and CSRF token**: All the security aspects are handled by `spaceship`.
- **Profile Magic**: Create and upload code signing requests, all managed by `spaceship`
- **Multiple Spaceship**: You can launch multiple `spaceships` with different Apple accounts to do things like syncing the registered devices.

# Credits

The initial release was sponsored by [ZeroPush](https://zeropush.com).

`spaceship` was developed by
- [@KrauseFx](https://twitter.com/KrauseFx).
- [@snatchev](https://twitter.com/snatchev/)
- [@mathcarignani](https://twitter.com/mathcarignani/)

[Open full list of contributors](https://github.com/fastlane/spaceship/graphs/contributors).

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Code of Conduct
Help us keep `fastlane` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/code-of-conduct).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
