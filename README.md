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
  <b>PEM</b> &bull; 
  <a href="https://github.com/KrauseFx/sigh">sigh</a> &bull; 
  <a href="https://github.com/KrauseFx/produce">produce</a> &bull;
  <a href="https://github.com/KrauseFx/cert">cert</a>  &bull;
  <a href="https://github.com/KrauseFx/codes">codes</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a>
</p>
-------

<p align="center">
    <img src="assets/pem.png">
</p>

PEM
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/pem/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/pem.svg?style=flat)](http://rubygems.org/gems/pem)

###### Automatically generate and renew your push notification profiles

Tired of manually creating and maintaining your push notification profiles for your iOS apps? Tired of generating a `pem` file for your server? 

```PEM``` does all that for, just by running ```pem```.

To automate iOS Provisioning profiles you can use [sigh](https://github.com/KrauseFx/sigh).

Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)

-------
<p align="center">
    <a href="#features">Features</a> &bull; 
    <a href="#installation">Installation</a> &bull; 
    <a href="#usage">Usage</a> &bull; 
    <a href="#how-does-it-work">How does it work?</a> &bull; 
    <a href="#tips">Tips</a> &bull; 
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>PEM</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

# Features
Well, it's actually just one: Generate the ```pem``` file for your server.


Check out this gif:

![assets/PEMRecording.gif](assets/PEMRecording.gif)

# Installation
    sudo gem install pem

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

# Usage

    pem

Yes, that's the whole command!

This does the following:

- Create a new signing request
- Create a new push certification
- Downloads the certificate
- Generates a new ```.pem``` file in the current working directory, which you can upload to your server

```PEM``` will never revoke your existing certificates. 

If you already have a push certificate enabled, which is active for at least 30 more days, `PEM` will not create a new certificate. If you still want to create one, use the `force`:

    pem --force

You can pass parameters like this:

    pem -a com.krausefx.app -u username

If you want to generate a development certificate instead:

    pem --development

Set a password for your `p12` file:

    pem -p "MyPass"

You can specify a name for the output file:

    pem -o my.pem

To get a list of available options run:

    pem --help
    

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Environment Variables
In case you prefer environment variables:

- ```PEM_USERNAME```
- ```PEM_APP_IDENTIFIER```
- ```PEM_TEAM_ID```
- ```PEM_SAVE_PRIVATEKEY``` - Set to "1" to save the private RSA key

# How does it work?
There are 2 actions involved:

- Accessing the ```iOS Dev Center``` to download the latest ```aps_production.cer```. See: [developer_center.rb](https://github.com/KrauseFx/PEM/blob/master/lib/pem/developer_center.rb).
- Generating all the necessary profiles and files to prepare the finished ```.pem``` file. See: [cert_manager.rb](https://github.com/KrauseFx/PEM/blob/master/lib/pem/cert_manager.rb).
- The ```.certSigningRequest``` file will be generated in [signing_request.rb](https://github.com/KrauseFx/PEM/blob/master/lib/pem/signing_request.rb)


## How is my password stored?
```PEM``` uses the [password manager](https://github.com/KrauseFx/CredentialsManager) from `fastlane`. Take a look the [CredentialsManager README](https://github.com/KrauseFx/CredentialsManager) for more information.

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`deliver`](https://github.com/KrauseFx/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/KrauseFx/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/KrauseFx/frameit): Quickly put your screenshots into the right device frames
- [`sigh`](https://github.com/KrauseFx/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/KrauseFx/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/KrauseFx/cert): Automatically create and maintain iOS code signing certificates
- [`codes`](https://github.com/KrauseFx/codes): Create promo codes for iOS Apps using the command line
- [`spaceship`](https://github.com/fastlane/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers 


##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Use the 'Provisioning Quicklook plugin'
Download and install the [Provisioning Plugin](https://github.com/chockenberry/Provisioning).

It will show you the ```pem``` files like this: 
![assets/QuickLookScreenshot.png](assets/QuickLookScreenshot.png)


# Need help?
- If there is a technical problem with ```PEM```, submit an issue.
- I'm available for contract work - drop me an email: pem@krausefx.com

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.

# Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/KrauseFx/pem/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
