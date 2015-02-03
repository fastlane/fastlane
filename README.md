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
  <b>sigh</b> &bull; 
  <a href="https://github.com/KrauseFx/produce">produce</a>
</p>
-------

<p align="center">
    <img src="assets/sigh.png">
</p>

sigh
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/sigh/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/sigh.svg?style=flat)](http://rubygems.org/gems/sigh)

###### Because you would rather spend your time building stuff than fighting provisioning

Tired of manually creating, renewing and downloading your iOS provisioning profiles?

```sigh``` handles all that for you. Just run ```sigh``` and it will do the rest.

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

<h5 align="center"><code>sigh</code> is part of <a href="http://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>


# Features

- **Download** the latest provisioning profile for your app
- **Renew** a provisioning profile, when it has expired
- **Repair** a provisioning profile, when it is broken
- **Create** a new provisioning profile, if it doesn't exist already
- Supports **App Store**, **Ad Hoc** and **Development** profiles
- Support for **multiple Apple accounts**, storing your credentials securely in the Keychain
- Support for **multiple Teams**
- Support for **Enterprise Profiles**

To automate iOS Push profiles you can use [PEM](https://github.com/KrauseFx/PEM).

### Why not let Xcode do the work?

- ```sigh``` can easily be integrated into your CI-server (e.g. Jenkins)
- Xcode sometimes invalidates all existing profiles ([Screenshot](assets/SignErrors.png))
- You have control over what happens
- You still get to have the signing files, which you can then use for your build scripts or store in git

See ```sigh``` in action:

![assets/sighRecording.gif](assets/sighRecording.gif)

# Installation
    sudo gem install sigh

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

If you don't already have homebrew installed, [install it here](http://brew.sh/).

# Usage

    sigh
Yes, that's the whole command!

```sigh``` will create, repair and download profiles for the App Store by default. 

You can pass your bundle identifier and username like this:

    sigh -a com.krausefx.app -u username

If you want to generate an **Ad Hoc** profile instead of an App Store profile:

    sigh --adhoc
    
If you want to generate a **Development** profile:

    sigh --development

To generate the profile in a specific directory: 

    sigh -o "~/Certificates/"
    
### Advanced

By default, ```sigh``` will install the downloaded profile on your machine. If you just want to generate the profile and skip the installation, use the following flag:

    sigh --skip_install
    
To save the provisioning profile under a specific name, use the -f option:

    sigh -a com.krausefx.app -u username -f "myProfile.mobileprovision"

If you need the provisioning profile to be renewed regardless of its state use the `--force` option. This gives you a profile with the maximum lifetime:

    sigh --force -a com.krausefx.app -u username

To renew a valid profile with a different certificate, look up the expiry date of the certificate you want to sign with in the Apple Developer Portal under Production Certificates. Copy the date string from there and use the following:

    sigh --force -a com.krausefx.app -u username -d "Nov 11, 2017"


## Environment Variables
In case you prefer environment variables:

- ```SIGH_USERNAME```
- ```SIGH_APP_IDENTIFIER```
- ```SIGH_TEAM_ID``` (The Team ID, e.g. `Q2CBPK58CA`)
- `SIGH_DISABLE_OPEN_ERROR` - in case of error, `sigh` won't open Preview with a screenshot of the error when this variable is set.

# How does it work?

```sigh``` will access the ```iOS Dev Center``` to download, renew or generate the ```.mobileprovision``` file. Check out the full source code: [developer_center.rb](https://github.com/KrauseFx/sigh/blob/master/lib/sigh/developer_center.rb).


## How is my password stored?
```sigh``` uses the [password manager](https://github.com/KrauseFx/CredentialsManager) from `fastlane`. Take a look the [CredentialsManager README](https://github.com/KrauseFx/CredentialsManager) for more information.

# Tips
## [`fastlane`](http://fastlane.tools) Toolchain

- [`fastlane`](http://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`deliver`](https://github.com/KrauseFx/deliver): Upload screenshots, metadata and your app to the App Store using a single command
- [`snapshot`](https://github.com/KrauseFx/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/KrauseFx/frameit): Quickly put your screenshots into the right device frames
- [`PEM`](https://github.com/KrauseFx/pem): Automatically generate and renew your push notification profiles
- [`produce`](https://github.com/KrauseFx/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line

## Use the 'Provisioning Quicklook plugin'
Download and install the [Provisioning Plugin](https://github.com/chockenberry/Provisioning).

It will show you the ```mobileprovision``` files like this: 
![assets/QuickLookScreenshot.png](assets/QuickLookScreenshot.png)


# Need help?
- If there is a technical problem with ```sigh```, submit an issue.
- I'm available for contract work - drop me an email: sigh@krausefx.com

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to start a discussion about your idea
2. Fork it (https://github.com/KrauseFx/sigh/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
