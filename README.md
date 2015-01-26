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
  <b>produce</b>
</p>
-------

<p align="center">
    <img src="assets/produce.png">
</p>

produce
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/produce/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/produce.svg?style=flat)](http://rubygems.org/gems/produce)

###### Create new iOS apps on iTunes Connect and Dev Portal using your command line

##### This tool was financed by [AppInstitute](http://appinstitute.co.uk/).

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

<h5 align="center"><code>produce</code> is part of <a href="http://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>


# Features

- **Create** new apps on both iTunes Connect and the Apple Developer Portal
- Support for **multiple Apple accounts**, storing your credentials securely in the Keychain

# Installation
    sudo gem install produce

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

Install phantomjs (this is needed to control the Apple Developer Portal)

    brew update && brew install phantomjs

If you don't already have homebrew installed, [install it here](http://brew.sh/).

# Usage

    produce

## Environment Variables
In case you want to pass more information to `produce`:

- `PRODUCE_USERNAME` (your iTunes Connect username)
- `PRODUCE_APP_IDENTIFIER` (the bundle identifier of the new app)
- `PRODUCE_APP_NAME` (the name of the new app)
- `PRODUCE_LANGUAGE` (the language you want your app to use, e.g. `English`, `German`)
- `PRODUCE_VERSION` (the initial app version)
- `PRODUCE_SKU` (the SKU you want to use, which must be a unique number)
- `PRODUCE_TEAM_ID` (the Team ID, e.g. `Q2CBPK58CA`)

# How does it work?

```produce``` will access the ```iOS Dev Center``` to create your `App ID`. Check out the full source code: [developer_center.rb](https://github.com/KrauseFx/produce/blob/master/lib/produce/developer_center.rb).

After finishing the first step, `produce` will access `iTunes Connect` to create the new app with some initial values. Check out the full source code: [itunes_connect.rb](https://github.com/KrauseFx/produce/blob/master/lib/produce/itunes_connect.rb).

You'll still have to fill out the remaining information (like screenshots, app description and pricing). You can use [deliver](https://github.com/KrauseFx/deliver) to upload your app metadata using a CLI

## How is my password stored?
```produce``` uses the [password manager](https://github.com/KrauseFx/CredentialsManager) from `fastlane`. Take a look the [CredentialsManager README](https://github.com/KrauseFx/CredentialsManager) for more information.

# Tips
## [`fastlane`](http://fastlane.tools) Toolchain

- [`fastlane`](http://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`deliver`](https://github.com/KrauseFx/deliver): Upload screenshots, metadata and your app to the App Store using a single command
- [`snapshot`](https://github.com/KrauseFx/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/KrauseFx/frameit): Quickly put your screenshots into the right device frames
- [`PEM`](https://github.com/KrauseFx/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/KrauseFx/sigh): Because you would rather spend your time building stuff than fighting provisioning

# Need help?
- If there is a technical problem with `produce`, submit an issue. Run `produce --trace` to get the stacktrace.
- I'm available for contract work - drop me an email: produce@krausefx.com

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to start a discussion about your idea
2. Fork it (https://github.com/KrauseFx/produce/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
