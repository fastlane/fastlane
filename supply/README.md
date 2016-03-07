<h3 align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/fastlane">
    <img src="assets/fastlane.png" width="150" />
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
  <a href="https://github.com/fastlane/fastlane/tree/master/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/scan">scan</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/match">match</a>
</p>
-------

<p align="center">
  <img src="assets/supply.png" height="110">
</p>

supply
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/supply.svg?style=flat)](http://rubygems.org/gems/supply)
[![Build Status](https://img.shields.io/travis/fastlane/supply/master.svg?style=flat)](https://travis-ci.org/KrauseFx/supply)

###### Command line tool for updating Android apps and their metadata on the Google Play Store

Get in contact with the developer on Twitter: [@FastlaneTools](https://twitter.com/FastlaneTools)


-------
<p align="center">
    <a href="#features">Features</a> &bull; 
    <a href="#installation">Installation</a> &bull; 
    <a href="#setup">Setup</a> &bull; 
    <a href="#quick-start">Quick Start</a> &bull; 
    <a href="#available-commands">Commands</a> &bull; 
    <a href="#uploading-an-apk">Uploading an APK</a> &bull; 
    <a href="#images-and-screenshots">Images</a>
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

Setup consists of setting up your Google Developers Service Account

- Open the [Google Play Console](https://play.google.com/apps/publish/)
- Select **Settings** tab, followed by the **API access** tab
- Click the **Create Service Account** button and follow the **Google Developers Console** link in the dialog
- Click **Add credentials** and select **Service account**
- Select **JSON** as the Key type and click **Create**
- Make a note of the file name of the JSON file downloaded to your computer, and close the dialog
- Make a note of the **Email address** under **Service accounts** - this is the user which you will need later
- Back on the Google Play developer console, click **Done** to close the dialog
- Click on **Grant Access** for the newly added service account
- In the **Invite a New User** dialog, paste the service account email address you noted earlier into the **Email address** field
- Choose **Release Manager** from the **Role** dropdown and click **Send Invitation** to close the dialog

### Migrating Google credential format (from .p12 key file to .json)

In previous versions of supply, credentials to your Play Console were stored as `.p12` files. Since version 0.4.0, supply now supports the recommended `.json` key Service Account credential files. If you wish to upgrade:

- follow the <a href="#setup">Setup</a> procedure once again to make sure you create the appropriate JSON file
- update your fastlane configuration or your command line invocation to use the appropriate argument if necessary.
  Note that you don't need to take note nor pass the `issuer` argument anymore.


The previous p12 configuration is still currently supported.


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

To upload a new binary to Google Play, simply run

```
supply --apk path/to/app.apk
```

This will also upload app metadata if you previously ran `supply init`.

To gradually roll out a new build use

```
supply --apk path/app.apk --track rollout --rollout 0.5
```

Expansion files (obbs) found under the same directory as your APK will also be uploaded together with your APK as long as:

- they are identified as type 'main' or 'patch' (by containing 'main' or 'patch' in their file name)
- you have at most one of each type

## Images and Screenshots

After running `supply init`, you will have a metadata directory. This directory contains one or more locale directories (e.g. en-US, en-GB, etc.), and inside this directory are text files such as `title.txt` and `short_description.txt`.

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
- `wearScreenshots/`

Note that these will replace the current images and screenshots on the play store listing, not add to them.

## Changelogs (What's new)

You can add changelog files under the `changelogs/` directory for each locale. The filename should exactly match the version code of the APK that it represents. `supply init` will populate changelog files from existing data on Google Play if no `metadata/` directory exists when it is run.

```
└── fastlane
    └── metadata
        └── android 
            ├── en-US
            │   └── changelogs
            │       ├── 100000.txt
            │       └── 100100.txt
            └── fr-FR
                └── changelogs
                    └── 100100.txt
```

## Tips

### [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`deliver`](https://github.com/fastlane/fastlane/tree/master/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/fastlane/fastlane/tree/master/frameit): Quickly put your screenshots into the right device frames
- [`pem`](https://github.com/fastlane/fastlane/tree/master/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/fastlane/fastlane/tree/master/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/fastlane/fastlane/tree/master/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/fastlane/fastlane/tree/master/cert): Automatically create and maintain iOS code signing certificates
- [`codes`](https://github.com/fastlane/codes): Create promo codes for iOS Apps using the command line
- [`spaceship`](https://github.com/fastlane/fastlane/tree/master/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/fastlane/tree/master/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers 
- [`gym`](https://github.com/fastlane/fastlane/tree/master/gym): Building your iOS apps has never been easier
- [`match`](https://github.com/fastlane/fastlane/tree/master/match): Easily sync your certificates and profiles across your team using git

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Need help?
Please submit an issue on GitHub and provide information about your setup

# Code of Conduct
Help us keep `supply` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/code-of-conduct).

## License

This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
