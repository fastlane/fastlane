<h3 align="center">
  <a href="https://github.com/fastlane/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/deliver">deliver</a> &bull; 
  <a href="https://github.com/fastlane/snapshot">snapshot</a> &bull; 
  <a href="https://github.com/fastlane/frameit">frameit</a> &bull; 
  <a href="https://github.com/fastlane/PEM">PEM</a> &bull; 
  <a href="https://github.com/fastlane/sigh">sigh</a> &bull; 
  <a href="https://github.com/fastlane/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/scan">scan</a>
</p>
-------

WatchBuild
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/watchbuild/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/watchbuild.svg?style=flat)](http://rubygems.org/gems/watchbuild)

###### Get a notification once your iTunes Connect build is finished processing

<img src="assets/screenshot.png" width=350>

When you upload a new binary from Xcode to iTunes Connect, you have to wait until it's done processing before you can submit it to the App Store.

As the [#iosprocessingtime](https://twitter.com/search?q=%23iosprocessingtime) varies from a few minutes to multiple hours, it's easy to forget to check iTunes Connect to see if the build is ready. WatchBuild lets you know as soon as it is done.

WatchBuild is a simple standalone tool that shows a notification once your newly uploaded build was successfully processed by iTunes Connect. 

Once the build is ready to be pushed to TestFlight or for review, you get a OS X notification. You can even directly click on the notification to open the build on iTunes Connect.

### Why use WatchBuild?

WatchBuild is a standalone tool and can be used without any of the other [fastlane tools](https://fastlane.tools). This is *big*, since you can use WatchBuild also if you use Xcode to upload your app. 

This tool is not a replacement for [deliver](https://github.com/fastlane/deliver) (Upload metadata and builds to iTunes Connect) or [pilot](https://github.com/fastlane/pilot) (Upload and distribute new builds to TestFlight), but is meant as a small helpful utility with the main purpose to wait for the binary processing to be finished.

Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)

-------
<p align="center">
    <a href="#installation">Installation</a> &bull; 
    <a href="#usage">Usage</a> &bull; 
    <a href="#tips">Tips</a> &bull; 
    <a href="#need-help">Need help?</a>
</p>

-------

# Installation

    sudo gem install watchbuild

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

# Usage

    watchbuild

You can pass your bundle identifier and username like this:

    watchbuild -a com.krausefx.app -u felix@krausefx.com

For a list of available parameters and commands run

    watchbuild --help

<img src="assets/terminal.png">

## How is my password stored?

`WatchBuild` uses the secure [CredentialsManager](https://github.com/fastlane/credentials_manager) from [fastlane](https://fastlane.tools) that stores credentials in your local keychain. 

# Tips
## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`deliver`](https://github.com/fastlane/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/fastlane/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/fastlane/frameit): Quickly put your screenshots into the right device frames
- [`PEM`](https://github.com/fastlane/PEM): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/fastlane/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/fastlane/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/fastlane/cert): Automatically create and maintain iOS code signing certificates
- [`spaceship`](https://github.com/fastlane/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers 
- [`gym`](https://github.com/fastlane/gym): Building your iOS apps has never been easier
- [`scan`](https://github.com/fastlane/scan): The easiest way to run tests of your iOS and Mac app

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Need help?
Please submit an issue on GitHub and provide information about your setup

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
