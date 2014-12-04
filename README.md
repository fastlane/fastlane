<p align="center">
  <b>Fastlane</b><br />
  <a href="https://github.com/KrauseFx/deliver">Deliver</a> &bull; 
  <a href="https://github.com/KrauseFx/snapshot">Snapshot</a> &bull; 
  <a href="https://github.com/KrauseFx/frameit">FrameIt</a> &bull; 
  <a href="https://github.com/KrauseFx/PEM">PEM</a> &bull; 
  <a href="https://github.com/KrauseFx/sigh">Sigh</a>
</p>
-------

<p align="center">
    <img src="assets/fastlane.png">
</p>

Fastlane - iOS Deployment without the hassle
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/fastlane/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/fastlane.svg?style=flat)](http://rubygems.org/gems/fastlane)
[![Build Status](https://img.shields.io/travis/KrauseFx/fastlane/master.svg?style=flat)](https://travis-ci.org/KrauseFx/fastlane)

Automate the **whole** deployment process of your iOS apps using ```fastlane``` and all its tools:

- [```deliver```](https://github.com/KrauseFx/deliver): Uploads app screenshots, metadata and app updates to iTunes Connect
- [```snapshot```](https://github.com/KrauseFx/snapshot): Creates perfect screenshots of your app in all languages on all device types automatically
- [```frameit```](https://github.com/KrauseFx/frameit): Adds device frames around your screenshots to use on your website
- [```PEM```](https://github.com/KrauseFx/PEM): Creates push certificates for your server
- [```sigh```](https://github.com/KrauseFx/sigh): Creates, maintainces and repairs provisioning profiles for you

Follow the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)


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


# Features
- Connect all tools, part of the ```fastlane``` tool chain in a meaningful way
- Define different ```deployment lanes``` for App Store deployment, beta builds or testing
- Deploy from any computer
- Never remember any difficult commands, just ```fastlane```
- Store **everything** in git. Never lookup the used build commands in the ```Jenkins``` configs
- Saves you **hours** of preparing app submission, uploading screenshots and deploying the app for each update.
- Once up and running, you have a fully working **Continuous Deployment** process. Just trigger ```fastlane``` and you're good to go.

# Installation

Install the gem

    sudo gem install fastlane

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install


# Quick Start


The guide will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```fastlane init```
- TODO


### Customize the ```Fastfile```
Open the ```Fastfile``` using a text editor and customize it even further. 

# Usage

Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily deploy from any computer.


# Tips

## Other helpful tools
Check out other tools in this collection to speed up your deployment process:
- [```deliver```](https://github.com/KrauseFx/deliver): Deploy screenshots, app metadata and app updates to the App Store using just one command
- [```snapshot```](https://github.com/KrauseFx/snapshot): Create hundreds of screenshots of your iPhone app... while doing something else.
- [```frameit```](https://github.com/KrauseFx/frameit): Want a device frame around your screenshot? Do it in an instant!
- [```PEM```](https://github.com/KrauseFx/pem): Tired of manually creating and maintaining your push certification profiles?
- [```sigh```](https://github.com/KrauseFx/sigh): Because you would rather spend your time building stuff than fighting provisioning.


## Jenkins integration
TODO

The recommended way to install ```Jenkins``` is through ```homebrew```:

```brew update && brew install jenkins```

From now on start ```Jenkins``` using

```jenkins&```

You should not deploy a new App Store update after every commit, since you still have to wait for your review. Instead I recommend using Git Tags, or custom triggers to deploy a new update. 

## Editing the ```Fastfile```
Change syntax highlighting to *Ruby*.


# Need help?
- If there is a technical problem with ```fastlane```, submit an issue. Run ```fastlane --trace``` to get the stacktrace.
- I'm available for contract work - drop me an email: fastlane@felixkrause.at

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/KrauseFx/fastlane/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
