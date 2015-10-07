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
  <a href="https://github.com/KrauseFx/codes">codes</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a>
</p>
-------

<p align="center">
    <img src="assets/supply.png">
</p>

supply
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/supply/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/supply.svg?style=flat)](http://rubygems.org/gems/supply)
[![Build Status](https://img.shields.io/travis/KrauseFx/supply/master.svg?style=flat)](https://travis-ci.org/KrauseFx/supply)

###### Command line tool for updating Android apps and their metadata on the Google Play Store

Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)


-------
<p align="center">
    <a href="#features">Features</a> &bull; 
    <a href="#installation">Installation</a> &bull; 
    <a href="#setup">Setup</a> &bull; 
    <a href="#quick-start">Quick Start</a> &bull; 
    <a href="#available-commands">Available Commands</a> &bull; 
    <a href="#uploading-an-apk">Uploading an APK</a> &bull; 
    <a href="#images-and-screenshots">Images and Screenshots</a> &bull; 
</p>

-------

<h5 align="center"><code>supply</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

## Features
- Update existing Android applications on Google Play via the command line
- Upload new builds (APKs)
- Retrieve and edit metadata, such as title and description, for multiple languages
- Upload the app icon, promo graphics and screenshots for multiple languages
- Have a local copy of the metadata in your git repository

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Installation

Install the gem

    sudo gem install supply

## Setup

- Open the [Google Play Console](https://play.google.com/apps/publish/)
- Open _Settings => API-Access_
- Create a new Service Account - follow the link of the dialog
- Create new Client ID
- Select _Service Account_
- Click _Generate new P12 key_ and store the downloaded file
- Make a note of the _Email address_ underneath _Service account_ - this is the issuer which you will need later
- Back on the Google Play developer console, click on _Grant Access_ for the newly added service account
- Choose _Release Manager_ from the dropdown and confirm

## Quick Start

- `cd [your_project_folder]`
- `supply init`
- Make changes to the downloaded metadata, add images, screenshots and/or an APK
- `supply run`

## Available Commands

- `supply`: update an app with metadata, a build, images and screenshots
- `supply init`: download metadata for an existing app to a local directory
- `supply --help`: show information on available commands, arguments and environment variables

You can either run `supply` on its own and use it interactively, or you can pass arguments or specify environment variables for all the options to skip the questions.

## Uploading an APK

Simply run `supply --apk path/to/app.apk`, or use the `SUPPLY_APK` environment variable.

This will also upload app metadata if you previously ran `supply init`.

## Images and Screenshots

After running `supply init`, you will have a metadata directory. This directory contains one or more locale directories (e.g. en-US, en-GB, etc.), and inside this directory are text files such as `title.txt` and `short.txt`.

Here you can supply images with the following file names (extension can be png, jpg or jpeg):

- `featureGraphic`
- `icon`
- `promoGraphic`
- `tvBanner`

And you can supply screenshots by creating directories with the following names, containing PNGs or JPEGs (image names are irrelevant):

- `phoneScreenshots/`
- `sevenInchScreenshots/` (7-inch tablets)
- `tenInchScreenshots/` (10-inch tablets)
- `tvScreenshots/`

Note that these will replace the current images and screenshots on the play store listing, not add to them.

## Tips

### [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`deliver`](https://github.com/KrauseFx/deliver): Upload screenshots, metadata and your app to the App Store
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

# Need help?
Please submit an issue on GitHub and provide information about your setup

## License

This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
