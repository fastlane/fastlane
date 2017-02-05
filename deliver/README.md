<h3 align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/fastlane">
    <img src="../fastlane/assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <b>deliver</b> &bull;
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
  <img src="assets/deliver.png" height="110">
</p>

deliver
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/deliver/LICENSE)
[![Gem](https://img.shields.io/gem/v/deliver.svg?style=flat)](https://rubygems.org/gems/deliver)

###### Upload screenshots, metadata and your app to the App Store using a single command

`deliver` uploads screenshots, metadata and binaries to iTunes Connect. Use `deliver` to submit your app for App Store review.

Get in contact with the developer on Twitter: [@FastlaneTools](https://twitter.com/FastlaneTools)

-------
<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#tips">Tips</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>deliver</code> is part of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate beta deployments and releases for your iOS and Android apps.</h5>

# Features
- Upload hundreds of localised screenshots completely automatically
- Upload a new ipa/pkg file to iTunes Connect without Xcode from any Mac
- Maintain your app metadata locally and push changes back to iTunes Connect
- Easily implement a real Continuous Deployment process using [fastlane](https://fastlane.tools)
- Store the configuration in git to easily deploy from **any** Mac, including your Continuous Integration server
- Get a HTML preview of the fetched metadata before uploading the app metadata and screenshots to iTC

To upload builds to TestFlight check out [pilot](https://github.com/fastlane/fastlane/tree/master/pilot).

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Installation

Install the gem

    sudo gem install fastlane

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

# Quick Start

The guide will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```fastlane deliver init```
- Enter your iTunes Connect credentials
- Enter your app identifier
- Enjoy a good drink, while the computer does all the work for you

From now on, you can run `fastlane deliver` to deploy a new update, or just upload new app metadata and screenshots.

Already using `deliver` and just updated to 1.0? Check out the [Migration Guide](https://github.com/fastlane/fastlane/blob/master/deliver/MigrationGuide.md).

# Usage

Check out your local `./fastlane/metadata` and `./fastlane/screenshots` folders (if you don't use [fastlane](https://fastlane.tools) it's `./metadata` instead)

![assets/metadata.png](assets/metadata.png)

You'll see your metadata from iTunes Connect. Feel free to store the metadata in git (not the screenshots). You can now modify it locally and push the changes back to iTunes Connect.

Run `fastlane deliver` to upload the app metadata from your local machine

```
fastlane deliver
```

Provide the path to an `ipa` file to upload and submit your app for review:

```
fastlane deliver --ipa "App.ipa" --submit_for_review
```

or you can specify path to `pkg` file for macOS apps:

```
fastlane deliver --pkg "MacApp.pkg"
```

If you use [fastlane](https://fastlane.tools) you don't have to manually specify the path to your `ipa`/`pkg` file.

This is just a small sub-set of what you can do with `deliver`, check out the full documentation in [Deliverfile.md](https://github.com/fastlane/fastlane/blob/master/deliver/Deliverfile.md)

Download existing screenshots from iTunes Connect

```
fastlane deliver download_screenshots
```

To get a list of available options run

```
fastlane deliver --help
```


Select a previously uploaded build and submit it for review.

```
fastlane deliver submit_build --build_number 830
```

Check out [Deliverfile.md](https://github.com/fastlane/fastlane/blob/master/deliver/Deliverfile.md) for more options.

Already using `deliver` and just updated to 1.0? Check out the [Migration Guide](https://github.com/fastlane/fastlane/blob/master/deliver/MigrationGuide.md).

# Credentials

A detailed description about how your credentials are handled is available in a [credentials_manager](https://github.com/fastlane/fastlane/tree/master/credentials_manager).

### How does this thing even work? Is magic involved? 🎩###

Your password will be stored in the macOS keychain, but can also be passed using environment variables. (More information available on [CredentialsManager](https://github.com/fastlane/fastlane/tree/master/credentials_manager))

Before actually uploading anything to iTunes, ```deliver``` will generate a HTML summary of the collected data.

`deliver` uses the following techniques under the hood:

- The iTMSTransporter tool is used to upload the binary to iTunes Connect. iTMSTransporter is a command line tool provided by Apple.
- For all metadata related actions `deliver` uses [spaceship](https://github.com/fastlane/fastlane/tree/master/spaceship)

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): The easiest way to automate beta deployments and releases for your iOS and Android apps
- [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/fastlane/fastlane/tree/master/frameit): Quickly put your screenshots into the right device frames
- [`pem`](https://github.com/fastlane/fastlane/tree/master/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/fastlane/fastlane/tree/master/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/fastlane/fastlane/tree/master/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/fastlane/fastlane/tree/master/cert): Automatically create and maintain iOS code signing certificates
- [`spaceship`](https://github.com/fastlane/fastlane/tree/master/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/fastlane/tree/master/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers
- [`gym`](https://github.com/fastlane/fastlane/tree/master/gym): Building your iOS apps has never been easier
- [`scan`](https://github.com/fastlane/fastlane/tree/master/scan): The easiest way to run tests of your iOS and Mac app
- [`match`](https://github.com/fastlane/fastlane/tree/master/match): Easily sync your certificates and profiles across your team using git

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Available language codes
```
no, en-US, en-CA, fi, ru, zh-Hans, nl-NL, zh-Hant, en-AU, id, de-DE, sv, ko, ms, pt-BR, el, es-ES, it, fr-CA, es-MX, pt-PT, vi, th, ja, fr-FR, da, tr, en-GB
```

## Default values

Deliver has a special `default` language code which allows you to provide values that are not localised, and which will be used as defaults when you don’t provide a specific localised value.

You can use this either in json within your deliverfile, or as a folder in your metadata file.

Imagine that you have localised data for the following language codes:  ```en-US, de-DE, el, it```

You can set the following in your deliverfile

```ruby
release_notes({
  'default' => "Shiny and new”,
  'de-DE' => "glänzend und neu"
})
```

Deliver will use "Shiny and new" for en-US, el and it.

It will use "glänzend und neu" for de-DE.

You can do the same with folders

```
   default
      keywords.txt
      marketing_url.txt
      name.txt
      privacy_url.txt
      support_url.txt
      release_notes.txt
   en-US
      description.txt
   de-DE
      description.txt
   el
      description.txt
   it
      description.txt
```

In this case, default values for keywords, urls, name and release notes are used in all localisations, but each language has a fully localised description



## Automatically create screenshots

If you want to integrate `deliver` with [snapshot](https://github.com/fastlane/fastlane/tree/master/snapshot), check out [fastlane](https://fastlane.tools)!

## Jenkins integration
Detailed instructions about how to set up `deliver` and `fastlane` in `Jenkins` can be found in the [fastlane README](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Jenkins.md).

## Firewall Issues

`deliver` uses the iTunes Transporter to upload metadata and binaries. In case you are behind a firewall, you can specify a different transporter protocol using

```
DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS="-t DAV" fastlane deliver
```

## HTTP Proxy
iTunes Transporter is a Java application bundled with Xcode. In addition to utilizing the `DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS="-t DAV"`, you need to configure the transporter application to use the proxy independently from the system proxy or any environment proxy settings. You can find the configuration file within Xcode:

```bash
TOOLS_PATH=$( xcode-select -p )
REL_PATH='../Applications/Application Loader.app/Contents/itms/java/lib/net.properties'
echo "$TOOLS_PATH/$REL_PATH"
```

Add necessary proxy configuration values to the net.properties according to [Java Proxy Configuration](http://docs.oracle.com/javase/8/docs/technotes/guides/net/proxies.html).

As an alternative to editing the properties files, proxy configuration can be specified on the command line directly:

```bash
DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS="-t DAV -Dhttp.proxyHost=myproxy.com -Dhttp.proxyPort=8080"
```

## Limit
Apple has a limit of 150 binary uploads per day.

## Editing the ```Deliverfile```
Change syntax highlighting to *Ruby*.

# Need help?
Please submit an issue on GitHub and provide information about your setup

# Code of Conduct
Help us keep `deliver` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
