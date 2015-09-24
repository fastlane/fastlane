<h3 align="center">
  <a href="https://github.com/KrauseFx/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <b>deliver</b> &bull; 
  <a href="https://github.com/KrauseFx/snapshot">snapshot</a> &bull; 
  <a href="https://github.com/KrauseFx/frameit">frameit</a> &bull; 
  <a href="https://github.com/KrauseFx/PEM">PEM</a> &bull; 
  <a href="https://github.com/KrauseFx/sigh">sigh</a> &bull; 
  <a href="https://github.com/KrauseFx/produce">produce</a> &bull; 
  <a href="https://github.com/KrauseFx/cert">cert</a> &bull; 
  <a href="https://github.com/KrauseFx/codes">codes</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a>
</p>
-------

<p align="center">
    <img src="assets/deliver.png">
</p>

deliver
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/deliver/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/deliver.svg?style=flat)](http://rubygems.org/gems/deliver)
[![Build Status](https://img.shields.io/travis/KrauseFx/deliver/master.svg?style=flat)](https://travis-ci.org/KrauseFx/deliver)

###### Upload screenshots, metadata and your app to the App Store using a single command

`deliver` **can upload ipa files, app screenshots and more to the iTunes Connect backend**, which means, you can deploy new iPhone app updates using the command line.

Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)


-------
<p align="center">
    <a href="#features">Features</a> &bull; 
    <a href="#installation">Installation</a> &bull; 
    <a href="#quick-start">Quick Start</a> &bull; 
    <a href="#usage">Usage</a> &bull; 
    <a href="#can-i-trust-deliver">Can I trust deliver?</a> &bull; 
    <a href="#tips">Tips</a> &bull; 
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>deliver</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

# Features
- Upload hundreds of screenshots with different languages from different devices
- Upload a new ipa file to iTunes Connect without Xcode from any computer
- Update app metadata
- Easily implement a real Continuous Deployment process using [fastlane](https://github.com/KrauseFx/fastlane)
- Store the configuration in git to easily deploy from **any** computer, including your Continuous Integration server (e.g. Jenkins)
- Get a PDF preview of the fetched metadata before uploading the app metadata and screenshots to Apple: [Example Preview](https://github.com/krausefx/deliver/blob/master/assets/PDFExample.png?raw=1)
- Automatically create new screenshots with [snapshot](https://github.com/KrauseFx/snapshot)

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Installation

Install the gem

    sudo gem install deliver

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

To create new screenshots automatically, check out my other open source project [snapshot](https://github.com/KrauseFx/snapshot).

To upload builds to TestFlight check out [pilot](https://github.com/fastlane/pilot).

# Quick Start

The guide will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```deliver init```
- Enter your iTunes Connect credentials
- Enter your app identifier
- Enjoy a good drink, while the computer does all the work for you

From now on, you can run `deliver` to deploy a new update, or just upload new app metadata and screenshots.

# Usage

TODO

# Credentials

A detailed description about your credentials is available on a [separate repo](https://github.com/fastlane/CredentialsManager).

# Can I trust `deliver`? 
###How does this thing even work? Is magic involved? 🎩###

`deliver` is fully open source, you can take a look at its source files. It will only modify the content you want to modify using the ```Deliverfile```. Your password will be stored in the Mac OS X keychain, but can also be passed using environment variables. (More information available on [CredentialsManager](https://github.com/fastlane/CredentialsManager))

Before actually uploading anything to iTunes, ```deliver``` will generate a [HTML summary](https://github.com/krausefx/deliver/blob/master/assets/PDFExample.png?raw=1) of the collected data. 

```deliver``` uses the following techniques under the hood:

- The iTMSTransporter tool is used to upload the binary to iTunes Connect. iTMSTransporter is a command line tool provided by Apple.
- For all metadata related actions `deliver` uses [spaceship](https://github.com/fastlane/spaceship)

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`snapshot`](https://github.com/KrauseFx/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/KrauseFx/frameit): Quickly put your screenshots into the right device frames
- [`PEM`](https://github.com/KrauseFx/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/KrauseFx/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/KrauseFx/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/KrauseFx/cert): Automatically create and maintain iOS code signing certificates
- [`codes`](https://github.com/KrauseFx/codes): Create promo codes for iOS Apps using the command line
- [`spaceship`](https://github.com/fastlane/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers 
- [`gym`](https://github.com/fastlane/gym): Building your iOS apps has never been easier

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Available language codes
```ruby
"da", "de-DE", "el", "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX", "fi", "fr-CA", "fr-FR", "id", "it", "ja", "ko", "ms", "nl", "no", "pt-BR", "pt-PT", "ru", "sv", "th", "tr", "vi", "zh-Hans", "zh-Hant"
```

## Automatically create screenshots

If you want to integrate ```deliver``` with ```snapshot```, check out [fastlane](https://github.com/KrauseFx/fastlane)!

More information about ```snapshot``` can be found on the [Snapshot GitHub page](https://github.com/KrauseFx/snapshot).

## Jenkins integration
Detailed instructions about how to set up `deliver` and `fastlane` in `Jenkins` can be found in the [fastlane README](https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md).

## Firewall Issues

`deliver` uses the iTunes Transporter to upload metadata and binaries. In case you are behind a firewall, you can specify a different transporter protocol using

```
DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS="-t DAV" deliver
```

## Limit
Apple has a limit of 150 binary uploads per day. 

## Editing the ```Deliverfile```
Change syntax highlighting to *Ruby*.

# Need help?
Please submit an issue on GitHub and provide information about your setup

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
