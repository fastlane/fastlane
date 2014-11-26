<p align="center">
<a href="https://github.com/KrauseFx/deliver">Deliver</a> &bull; 
<a href="https://github.com/KrauseFx/snapshot">Snapshot</a> &bull; 
<a href="https://github.com/KrauseFx/frameit">FrameIt</a> &bull; 
<a href="https://github.com/KrauseFx/PEM">PEM</a> &bull; 
<b>Sigh</b>
</p>

-------

<p align="center">
    <img src="assets/sigh.png">
</p>

Sigh
============
#### Because you would rather spend your time building stuff than fighting provisioning

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/sigh/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/sigh.svg?style=flat)](http://rubygems.org/gems/sigh)


Tired of manually creating, renewing and downloading your provisioning profiles?

```sigh``` handles all that for you. Just run ```sigh``` and it will do the rest.

Follow the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)



-------
[Features](#features) &bull;
[Installation](#installation) &bull;
[Usage](#usage) &bull;
[How does it work?](#how-does-it-work) &bull;
[Tips](#tips) &bull;
[Need help?](#need-help)

-------

# Features

- **Download** the latest provisioning profile for your app
- **Renew** a provisioning profile, when it has expired
- **Repair** a provisioning profile, when it is broken
- **Create** a new provisioning profile, if it doesn't exist already
- Supports **App Store**, **Ad Hoc** and **Development** profiles


See ```sigh``` in action:

![assets/sighRecording.gif](assets/sighRecording.gif)

# Installation
    sudo gem install sigh

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

Install phantomjs (this is needed to control the Apple Developer Portal)

    brew update && brew install phantomjs

If you don't already have homebrew installed, [install it here](http://brew.sh/).

# Usage

    sigh
Yes, that's the whole command!

```sigh``` will create, repair and download profiles for the App Store by default. 

You can pass your bundle identifier and username like this:

    sigh -a at.felixkrause.app -u username

If you want to generate an **Ad Hoc** profile instead of an App Store profile:

    sigh --adhoc
    
If you want to generate a **Development** profile:

    sigh --development

By default, ```sigh``` will install the downloaded profile on your machine. If you just want to generate the profile and skip the installation, use the following flag:

    sigh --skip_install


## Environment Variables
In case you prefer environment variables:

- ```SIGH_USERNAME```
- ```SIGH_APP_IDENTIFIER```

# How does it work?

```sigh``` will access the ```iOS Dev Center``` to download, renew or generate the ```.mobileprovision``` file. Check out the full source code: [developer_center.rb](https://github.com/KrauseFx/sigh/blob/master/lib/sigh/developer_center.rb).


## How is my password stored?
```sigh``` uses the password manager from [```Deliver```](https://github.com/KrauseFx/deliver#can-i-trust-deliver). Take a look the [Deliver README](https://github.com/KrauseFx/deliver#can-i-trust-deliver) for more information.

# Tipsbo
## Other helpful tools
Check out other tools in this collection to speed up your deployment process:

- [```deliver```](https://github.com/KrauseFx/deliver): Deploy screenshots, app metadata and app updates to the App Store using just one command
- [```snapshot```](https://github.com/KrauseFx/snapshot): Create hundreds of screenshots of your iPhone app... while doing something else
- [```FrameIt```](https://github.com/KrauseFx/frameit): Want a device frame around your screenshot? Do it in an instant!
- [```PEM```](https://github.com/KrauseFx/pem): Tired of manually creating and maintaining your push certification profiles?


## Use the 'Provisioning Quicklook plugin'
Download and install the [Provisioning Plugin](https://github.com/chockenberry/Provisioning).

It will show you the ```mobileprovision``` files like this: 
![assets/QuickLookScreenshot.png](assets/QuickLookScreenshot.png)


# Need help?
- If there is a technical problem with ```sigh```, submit an issue. Run ```sigh --trace``` to get the stacktrace.
- I'm available for contract work - drop me an email: sigh@felixkrause.at

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to start a discussion about your idea
2. Fork it (https://github.com/KrauseFx/sigh/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
