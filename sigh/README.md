<h3 align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/fastlane">
    <img src="../fastlane/assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/deliver">deliver</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/snapshot">snapshot</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/frameit">frameit</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/pem">pem</a> &bull;
  <b>sigh</b> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/scan">scan</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/match">match</a>
</p>
-------

<p align="center">
  <img src="assets/sigh.png" height="110">
</p>

sigh
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/sigh/LICENSE)
[![Gem](https://img.shields.io/gem/v/sigh.svg?style=flat)](https://rubygems.org/gems/sigh)

###### Because you would rather spend your time building stuff than fighting provisioning

`sigh` can create, renew, download and repair provisioning profiles (with one command). It supports App Store, Ad Hoc, Development and Enterprise profiles and supports nice features, like auto-adding all test devices.

Get in contact with the developer on Twitter: [@FastlaneTools](https://twitter.com/FastlaneTools)

-------
<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#resign">Resign</a> &bull;
    <a href="#how-does-it-work">How does it work?</a> &bull;
    <a href="#tips">Tips</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>sigh</code> is part of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate beta deployments and releases for your iOS and Android apps.</h5>

# Features

- **Download** the latest provisioning profile for your app
- **Renew** a provisioning profile, when it has expired
- **Repair** a provisioning profile, when it is broken
- **Create** a new provisioning profile, if it doesn't exist already
- Supports **App Store**, **Ad Hoc** and **Development** profiles
- Support for **multiple Apple accounts**, storing your credentials securely in the Keychain
- Support for **multiple Teams**
- Support for **Enterprise Profiles**

To automate iOS Push profiles you can use [pem](https://github.com/fastlane/fastlane/tree/master/pem).

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

### Why not let Xcode do the work?

- ```sigh``` can easily be integrated into your CI-server (e.g. Jenkins)
- Xcode sometimes invalidates [all existing profiles](assets/SignErrors.png)
- You have control over what happens
- You still get to have the signing files, which you can then use for your build scripts or store in git

See ```sigh``` in action:

![assets/sighRecording.gif](assets/sighRecording.gif)

# Installation

**Note**: It is recommended to use [match](https://github.com/fastlane/fastlane/tree/master/match) according to the [codesigning.guide](https://codesigning.guide) for generating and maintaining your provisioning profiles. Use `sigh` directly only if you want full control over what's going on and know more about codesigning.

    sudo gem install fastlane

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

# Usage

    fastlane sigh

Yes, that's the whole command!

```sigh``` will create, repair and download profiles for the App Store by default.

You can pass your bundle identifier and username like this:

    fastlane sigh -a com.krausefx.app -u username

If you want to generate an **Ad Hoc** profile instead of an App Store profile:

    fastlane sigh --adhoc

If you want to generate a **Development** profile:

    fastlane sigh --development

To generate the profile in a specific directory:

    fastlane sigh -o "~/Certificates/"

To download all your provisioning profiles use

    fastlane sigh download_all

For a list of available parameters and commands run

    fastlane sigh --help

### Advanced

By default, ```sigh``` will install the downloaded profile on your machine. If you just want to generate the profile and skip the installation, use the following flag:

    fastlane sigh --skip_install

To save the provisioning profile under a specific name, use the -q option:

    fastlane sigh -a com.krausefx.app -u username -q "myProfile.mobileprovision"

If for some reason you don't want `sigh` to verify that the code signing identity is installed on your local machine:

    fastlane sigh --skip_certificate_verification

If you need the provisioning profile to be renewed regardless of its state use the `--force` option. This gives you a profile with the maximum lifetime. `--force` will also add all available devices to this profile.

    fastlane sigh --force

By default, `sigh` will include all certificates on development profiles, and first certificate on other types. If you need to specify which certificate to use you can either use the environment variable `SIGH_CERTIFICATE`, or pass the name or expiry date of the certificate as argument:

    fastlane sigh -c "SunApps GmbH"

For a list of available parameters and commands run

    fastlane sigh --help


### Use with [`fastlane`](https://github.com/fastlane/fastlane/tree/master/fastlane)

`sigh` becomes really interesting when used in [`fastlane`](https://github.com/fastlane/fastlane/tree/master/fastlane) in combination with [`cert`](https://github.com/fastlane/fastlane/tree/master/cert).

Update your `Fastfile` to contain the following code:

```ruby
lane :beta do
  cert
  sigh(force: true)
end
```

`force: true` will make sure to re-generate the provisioning profile on each run.
This will result in `sigh` always using the correct signing certificate, which is installed on the local machine.


# Repair

`sigh` can automatically repair all your existing provisioning profiles which are expired or just invalid.

    fastlane sigh repair

# Resign

If you generated your `ipa` file but want to apply a different code signing onto the ipa file, you can use `sigh resign`:

    fastlane sigh resign

`sigh` will find the ipa file and the provisioning profile for you if they are located in the current folder.

You can pass more information using the command line:

    fastlane sigh resign ./path/app.ipa --signing_identity "iPhone Distribution: Felix Krause" -p "my.mobileprovision"

# Manage

With `sigh manage` you can list all provisioning profiles installed locally.

    fastlane sigh manage

Delete all expired provisioning profiles

    fastlane sigh manage -e

Or delete all `iOS Team Provisioning Profile` by using a regular expression

    fastlane sigh manage -p "iOS\ ?Team Provisioning Profile:"

## Environment Variables

Run `fastlane sigh --help` to get a list of all available environment variables.

If you're using [cert](https://github.com/fastlane/fastlane/tree/master/cert) in combination with [fastlane](https://github.com/fastlane/fastlane/tree/master/fastlane) the signing certificate will automatically be selected for you. (make sure to run `cert` before `sigh`)

# How does it work?

`sigh` will access the `iOS Dev Center` to download, renew or generate the `.mobileprovision` file. It uses [spaceship](https://spaceship.airforce) to communicate with Apple's web services.

## How is my password stored?
`sigh` uses the [CredentialsManager](https://github.com/fastlane/fastlane/tree/master/credentials_manager) from `fastlane`.

# Tips
## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): The easiest way to automate beta deployments and releases for your iOS and Android apps
- [`deliver`](https://github.com/fastlane/fastlane/tree/master/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/fastlane/fastlane/tree/master/frameit): Quickly put your screenshots into the right device frames
- [`pem`](https://github.com/fastlane/fastlane/tree/master/pem): Automatically generate and renew your push notification profiles
- [`produce`](https://github.com/fastlane/fastlane/tree/master/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/fastlane/fastlane/tree/master/cert): Automatically create and maintain iOS code signing certificates
- [`spaceship`](https://github.com/fastlane/fastlane/tree/master/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/fastlane/tree/master/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers
- [`gym`](https://github.com/fastlane/fastlane/tree/master/gym): Building your iOS apps has never been easier
- [`scan`](https://github.com/fastlane/fastlane/tree/master/scan): The easiest way to run tests of your iOS and Mac app
- [`match`](https://github.com/fastlane/fastlane/tree/master/match): Easily sync your certificates and profiles across your team using git

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Use the 'Provisioning Quicklook plugin'
Download and install the [Provisioning Plugin](https://github.com/chockenberry/Provisioning).

It will show you the `mobileprovision` files like this:
![assets/QuickLookScreenshot.png](assets/QuickLookScreenshot.png)

## App Identifier couldn't be found

If you also want to create a new App Identifier on the Apple Developer Portal, check out [produce](https://github.com/fastlane/fastlane/tree/master/produce), which does exactly that.

## What happens to my Xcode managed profiles?

`sigh` will never touch or use the profiles which are created and managed by Xcode. Instead `sigh` will manage its own set of provisioning profiles.

# Need help?
Please submit an issue on GitHub and provide information about your setup

# Code of Conduct
Help us keep `sigh` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
