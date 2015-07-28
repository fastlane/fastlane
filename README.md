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
  <a href="https://github.com/fastlane/boarding">boarding</a>
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
    <a href="#testflight">TestFlight</a> &bull; 
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
- Upload new builds to the new Apple TestFlight

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Installation

Install the gem

    sudo gem install deliver

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

To create new screenshots automatically, check out my other open source project [snapshot](https://github.com/KrauseFx/snapshot).

# TestFlight

**New**: To upload builds to TestFlight, use the new [pilot](https://github.com/fastlane/pilot) tool.

Upload a new build to Apple `TestFlight` use the following command:

```
deliver testflight
```

This will automatically look for an ipa file in the current directory.

`deliver` currently supports **Internal Testers** only.

Make sure to increase your build number before building and uploading your app.

#### More options:

Specify the `ipa` file, the Apple ID and app identifier to be used: 

```
deliver testflight ./my_app.ipa -u felix@krausefx.com -a 862582703
```

To build and upload the ipa in one step, you can use [shenzhen](https://github.com/nomad/shenzhen):

```
ipa build && deliver testflight
```

You can pass the "What to Test" value using the environment variable `DELIVER_WHAT_TO_TEST`:

```
DELIVER_WHAT_TO_TEST="Try the brand new project button" deliver testflight
```

Additional environment variables: `DELIVER_BETA_DESCRIPTION`, `DELIVER_BETA_FEEDBACK_EMAIL`.

# Quick Start


The guide will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```deliver init```
- When your app is already in the App Store: ```y```
 - Enter your iTunes Connect credentials
 - Enter your app identifier
 - Enjoy a good drink, while the computer does all the work for you
- When it's a new app: ```n```

From now on, you can run ```deliver``` to deploy a new update, or just upload new app metadata and screenshots.

### Customize the ```Deliverfile```
Open the ```Deliverfile``` using a text editor and customize it even further. Take a look at the following settings:

- ```ipa```: You can either pass a static path to an ipa file, or add your custom build script.
- ```unit_tests```: Uncomment the code to run tests. (e.g. using [xctool](https://github.com/facebook/xctool)). It is recommended to use [fastlane](https://fastlane.tools) for running tests.

# Usage

Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily deploy from any computer.

Run ```deliver init``` to create a new ```Deliverfile```. You can either let the wizard generate a file based on the metadata from iTunes Connect or create one from a template.

Once you created your configuration, just run ```deliver```.

All available commands with a short description can be found in [Deliverfile.md](https://github.com/KrauseFx/deliver/blob/master/Deliverfile.md).

Here are a few examples:
#### Upload screenshots to iTunes Connect

Remove the rest, and use just this format for your ```Deliverfile```.

```ruby
app_identifier "net.sunapps.1"
version "1.1"

screenshots_path "./screenshots"
```
The screenshots folder must include one subfolder per language (see [Available language codes](#available-language-codes)).

The screenshots are ordered alphabetically. The best way to sort them is to prepend a number before the actual screenshot name. You can also put Watch screenshots into this folder.

To let the computer create the screenshots for you, checkout [this section of the README](#automatically-create-screenshots).

If you want to have the screenshots inside a device frame, with a background and a fancy label on top, you can use [Sketch to App Store](http://sketchtoappstore.com/).

To download all existing screenshots, use `deliver download_screenshots`.

#### Update App description, keywords and more

If you used `deliver init`, take a look at the `./metadata/` folder, which contains your app description, keywords and app title. If you change the content of the files, it will get updated when you run `deliver`.

#### Upload a new ipa file with a changelog to the App Store
This will submit a new update to Apple
```ruby
ipa do 
    system("ipa build")
    "./name.ipa"
end

changelog(
    "en-US" => "This update adds cool new features",
    "de-DE" => "Dieses Update ist super"
)
```
If you wish to skip automated submission to review you can provide `--skip-deploy` option when calling `deliver`. This will upload the ipa file and app metadata, but will not submit the app for review.

The changelog is only used for App Store submission, not for TestFlight builds.

It is recommended to use `deliver` in combination with [fastlane](https://github.com/KrauseFx/fastlane) to build the app using `xcodebuild`.

#### Upload a new ipa for TestFlight beta testers

In order to upload an `.ipa` file for Apple TestFlight you need to specify `beta_ipa` path in your `Deliverfile`

```ruby
beta_ipa do 
  system("ipa build")
  "./name.ipa"
end
```

and provide `--beta` option when calling `deliver`. When running `deliver` with the `--beta` flag enabled, it will **not** upload new app metadata.

#### Implement blocks to run unit tests
If you're using [fastlane](http://github.com/krausefx/fastlane), run tests and error blocks there.

If you only use `deliver`, you can use the following blocks:

```ruby
unit_tests do
    system("xctool test")
end

success do
    system("Say 'success'")
end

error do |information|
    # custom exception handling here
    raise "Something went wrong: #{information['error']}"    
end
```

#### Read content from somewhere external (file, web service, ...)
```ruby
description(
  "en-US" => File.read("description-en.txt")
  "de-DE" => open("http://example.com/app_description.txt").read
)
```

#### Build and sign the app
I'm using [Shenzhen](https://github.com/nomad/shenzhen), but you can use any build tool or custom scripts.
```ruby
ipa do
    # Add any code you want, like incrementing the build 
    # number or changing the app identifier
  
    system("ipa build --verbose") # build your project using Shenzhen
    "./AppName.ipa" # Tell 'deliver' where it can find the finished ipa file
end
```

#### Hide the iTunes Transporter log
By default, the transporter log is shown, to be fully transparent. If you prefer to hide it, you can use the following option in your ```Deliverfile``` to disable it for both the upload and the download of metadata:
```ruby
hide_transporter_output
```

##### What is the ```Deliverfile```?
As you can see, the ```Deliverfile``` is a normal Ruby file, which is executed when
running a deployment. Therefore it's possible to fully customise the behaviour
on a deployment. 

All available commands with a short description can be found in [Deliverfile.md](https://github.com/KrauseFx/deliver/blob/master/Deliverfile.md).

**Some examples:**

- Run your own unit tests or integration tests before a deploy (recommended)
- Ask the script user for a changelog
- Deploy a new version just by starting a Jenkins job
- Post the deployment status on Slack
- Upload the latest screenshots to your server

For further actions, check out [fastlane](https://github.com/KrauseFx/fastlane)
    
#### Use the exposed Ruby classes
Some examples:
```ruby
require 'deliver'

app = Deliver::App.new(app_identifier: 'com.krausefx.app')

app.get_app_status # => Waiting for Review
app.create_new_version!("1.4")
app.metadata.update_title("en-US" => "iPhone App Title")
app.metadata.set_all_screenshots_from_path("./screenshots")
app.upload_metadata!
app.itc.submit_for_review!(app)

FastlaneCore::ItunesSearchApi.fetch_by_identifier("net.sunapps.15") # => Fetches public metadata
```
This project is well documented, check it out on [RubyDoc](http://www.rubydoc.info/github/KrauseFx/deliver/frames).


# Credentials

A detailed description about your credentials is available on a [separate repo](https://github.com/fastlane/CredentialsManager).


# Can I trust `deliver`? 
###How does this thing even work? Is magic involved? 🎩###

`deliver` is fully open source, you can take a look at its source files. It will only modify the content you want to modify using the ```Deliverfile```. Your password will be stored in the Mac OS X keychain, but can also be passed using environment variables. (More information available on [CredentialsManager](https://github.com/fastlane/CredentialsManager))

Before actually uploading anything to iTunes, ```deliver``` will generate a [PDF summary](https://github.com/krausefx/deliver/blob/master/assets/PDFExample.png?raw=1) of the collected data. 

```deliver``` uses the following techniques under the hood:

- The iTMSTransporter tool is used to fetch the latest app metadata from iTunes Connect and upload the updated app metadata back to Apple. It is also used to upload the ipa file. iTMSTransporter is a command line tool provided by Apple.
- With the iTMSTransporter you cannot create new version on iTunes Connect or actually publish the newly uploaded ipa file. This is why there is some browser scripting involved, using [Capybara](https://github.com/jnicklas/capybara) and [Poltergeist](https://github.com/teampoltergeist/poltergeist).
- The iTunes search API to find missing information about a certain app, like the *apple_id* when you only pass the *bundle_identifier*. 

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

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Available language codes
```ruby
["da-DK", "de-DE", "el-GR", "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX", "fi-FI", "fr-CA", "fr-FR", "id-ID", "it-IT", "ja-JP", "ko-KR", "ms-MY", "nl-NL", "no-NO", "pt-BR", "pt-PT", "ru-RU", "sv-SE", "th-TH", "tr-TR", "vi-VI", "cmn-Hans", "cmn-Hant"]
```

## Use a clean status bar
You can use [SimulatorStatusMagic](https://github.com/shinydevelopment/SimulatorStatusMagic) to clean up the status bar.

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
- If there is a technical problem with ```deliver```, submit an issue.
- I'm available for contract work - drop me an email: deliver@krausefx.com

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.

# Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/KrauseFx/deliver/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
