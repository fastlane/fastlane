<h3 align="center">
  <a href="https://github.com/fastlane/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/deliver">deliver</a> &bull; 
  <b>chiizu</b> &bull; 
  <a href="https://github.com/fastlane/frameit">frameit</a> &bull; 
  <a href="https://github.com/fastlane/pem">pem</a> &bull; 
  <a href="https://github.com/fastlane/sigh">sigh</a> &bull; 
  <a href="https://github.com/fastlane/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/scan">scan</a> &bull;
  <a href="https://github.com/fastlane/match">match</a>
</p>
-------

<p align="center">
  <img src="assets/chiizu.png" height="110">
</p>

chiizu
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/chiizu/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/chiizu.svg?style=flat)](http://rubygems.org/gems/chiizu)

###### Automate taking localized screenshots of your Android app

You have to manually create 20 (languages) x 6 (devices) x 5 (screenshots) = **600 screenshots**.

It's hard to get everything right!

- New screenshots with every (design) update
- No loading indicators
- Same content / screens
- [Clean Status Bar](#use-a-clean-status-bar)
- Uploading screenshots ([`supply`](https://github.com/fastlane/supply) is your friend)

`chiizu` runs completely in the background - you can do something else, while your computer takes the screenshots for you.

Get in contact with us on Twitter: [@FastlaneTools](https://twitter.com/FastlaneTools)

-------
<p align="center">
    <a href="#features">Features</a> &bull; 
    <a href="#installation">Installation</a> &bull; 
    <a href="#ui-tests">UI Tests</a> &bull; 
    <a href="#quick-start">Quick Start</a> &bull; 
    <a href="#usage">Usage</a> &bull; 
    <a href="#tips">Tips</a> &bull; 
    <a href="#how-does-it-work">How?</a> &bull; 
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>chiizu</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

# Features
- Create hundreds of screenshots in multiple languages on emulators or real devices
- Configure it once, store the configuration in git
- Do something else, while the computer takes the screenshots for you
- Integrates with [`fastlane`](https://fastlane.tools) and [`supply`](https://github.com/fastlane/supply)
- Generates a beautiful web page, which shows all screenshots on all devices. This is perfect to send to Q&A or the marketing team

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

After `chiizu` successfully created new screenshots, it will generate a beautiful HTML file to get a quick overview of all screens:

![assets/htmlPagePreviewFade.jpg](assets/htmlPagePreviewFade.jpg)

## Why?

This tool automatically switches the language and device type and runs UI Tests for every combination.

### Why should I automate this process?

- It takes **hours** to take screenshots
- You get a great overview of all your screens, without the need to manually start it hundreds of times
- Easy verification for translators (without devices) that translations make sense in the context of your app
- Easy verification that localizations fit into labels on all screen dimensions
- It is an integration test: You can test for UI elements and other things inside your scripts
- Keep your screenshots perfectly up-to-date with every app update. Your customers deserve it!
- Found a UI mistake after completing the process? Just correct it and re-run the script!

# Installation

Install the gem

    sudo gem install chiizu
    
# UI Tests

## Getting started

# Quick Start

# Usage

```sh
chiizu
```

## Chiizufile

All of the available options can also be stored in a configuration file called the `Chiizufile`. Since most values will not change often for your project, it is recommended to store them there:

First make sure to have a `Chiizufile` (you get it for free when running `chiizu init`)

The `Chiizufile` can contain all the options that are also available on `chiizu --help`

```ruby
# TODO update for chiizu syntax

devices([
  "iPhone 6",
  "iPhone 6 Plus",
  "iPhone 5",
  "iPhone 4s"
])

languages([
  "en-US",
  "de-DE",
  "es-ES"
])

launch_arguments("-username Felix")

# The directory in which the screenshots should be stored
output_directory './screenshots'

clear_previous_screenshots true
```

# How does it work?

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`supply`](https://github.com/fastlane/supply): Upload screenshots, metadata and your app to the Play Store
- [`frameit`](https://github.com/fastlane/frameit): Quickly put your screenshots into the right device frames

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Frame the screenshots

If you want to add frames around the screenshots and even put a title on top, check out [frameit](https://github.com/fastlane/frameit).

## Available language codes
```ruby
ALL_LANGUAGES = ["da", "de-DE", "el", "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX", "fi", "fr-CA", "fr-FR", "id", "it", "ja", "ko", "ms", "nl", "no", "pt-BR", "pt-PT", "ru", "sv", "th", "tr", "vi", "zh-Hans", "zh-Hant"]
```

## Editing the `Chiizufile`
Change syntax highlighting to *Ruby*.

# Need help?
Please submit an issue on GitHub and provide information about your setup

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
