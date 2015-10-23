<h3 align="center">
  <a href="https://github.com/KrauseFx/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/KrauseFx/deliver">deliver</a> &bull; 
  <b>snapshot</b> &bull; 
  <a href="https://github.com/KrauseFx/frameit">frameit</a> &bull; 
  <a href="https://github.com/KrauseFx/PEM">PEM</a> &bull; 
  <a href="https://github.com/KrauseFx/sigh">sigh</a> &bull; 
  <a href="https://github.com/KrauseFx/produce">produce</a> &bull;
  <a href="https://github.com/KrauseFx/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/scan">scan</a>
</p>
-------

<p align="center">
  <img src="assets/snapshot.png" height="110">
</p>

snapshot
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/snapshot/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/snapshot.svg?style=flat)](http://rubygems.org/gems/snapshot)

###### Automate taking localized screenshots of your iOS app on every device

You have to manually create 20 (languages) x 6 (devices) x 5 (screenshots) = **600 screenshots**.

It's hard to get everything right!

- New screenshots with every (design) update
- No loading indicators
- Same content / screens
- [Clean Status Bar](#use-a-clean-status-bar)
- Uploading screenshots ([`deliver`](https://github.com/KrauseFx/deliver) is your friend)

More information about [creating perfect screenshots](https://krausefx.com/blog/creating-perfect-app-store-screenshots-of-your-ios-app).

`snapshot` runs completely in the background - you can do something else, while your computer takes the screenshots for you.

Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)

### Note: New `snapshot` with UI Tests in Xcode 7

Apple announced a new version of Xcode with support for UI Tests built in right into Xcode. This technology allows `snapshot` to be even better: Instead of dealing with UI Automation Javascript code, you are now be able to write the screenshot code in Swift or Objective C allowing you to use debugging features like breakpoints.

As a result, `snapshot` was completely rewritten from ground up without changing its public API.

Please check out the [MigrationGuide to 1.0](/MigrationGuide.md) :+1:

**Why change to UI Tests?**

- UI Automation is deprecated
- UI Tests will evolve and support even more features in the future
- UI Tests are much easier to debug
- UI Tests are written in Swift or Objective C
- UI Tests can be executed in a much cleaner and better way

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

<h5 align="center"><code>snapshot</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

# Features
- Create hundreds of screenshots in multiple languages on all simulators
- Configure it once, store the configuration in git
- Do something else, while the computer takes the screenshots for you
- Integrates with [`fastlane`](https://fastlane.tools) and [`deliver`](https://github.com/KrauseFx/deliver)
- Generates a beautiful web page, which shows all screenshots on all devices. This is perfect to send to Q&A or the marketing team
- `snapshot` automatically waits for network requests to be finished before taking a screenshot (we don't want loading images in the App Store screenshots)

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

After `snapshot` successfully created new screenshots, it will generate a beautiful HTML file to get a quick overview of all screens:

![assets/htmlPagePreviewFade.jpg](assets/htmlPagePreviewFade.jpg)

## Why?

This tool automatically switches the language and device type and runs UI Tests for every combination.

### Why should I automate this process?

- It takes **hours** to take screenshots
- You get a great overview of all your screens, running on all available simulators without the need to manually start it hundreds of times
- Easy verification for translators (without an iDevice) that translations do make sense in real App context
- Easy verification that localizations fit into labels on all screen dimensions
- It is an integration test: You can test for UI elements and other things inside your scripts
- Be so nice, and provide new screenshots with every App Store update. Your customers deserve it
- You realise, there is a spelling mistake in one of the screens? Well, just correct it and re-run the script

# Installation

Install the gem

    sudo gem install snapshot

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install
    
# UI Tests

## Getting started
This project uses Apple's newly announced UI Tests. I will not go into detail on how to write scripts. 

Here a few links to get started:

- [WWDC 2015 Introduction to UI Tests](https://developer.apple.com/videos/play/wwdc2015-406/)
- [A first look into UI Tests](http://www.mokacoding.com/blog/xcode-7-ui-testing/)
- [UI Testing in Xcode 7](http://masilotti.com/ui-testing-xcode-7/)

**Note**: Since there is no official way to trigger a screenshot from UI Tests, `snapshot` uses a workaround (described in [How Does It Work?](#how-does-it-work)) to trigger a screenshot. If you feel like this should be done right, please duplicate radar [23062925](https://openradar.appspot.com/radar?id=5056366381105152).

# Quick Start

- Create a new UI Test target in your Xcode project ([top part of this article](https://krausefx.com/blog/run-xcode-7-ui-tests-from-the-command-line))
- Run `snapshot init` in your project folder
- Add the ./SnapshotHelper.swift to your UI Test target (You can move the file anywhere you want)
- In your UI Test class, click the `Record` button on the bottom left and record your interaction
- Add `snapshot("01LoginScreen")` method calls inbetween your interactions to take new screenshots
- Add the following code to your `setUp()` method

```swift
let app = XCUIApplication()
setLanguage(app)
app.launch()
```

![assets/snapshot.gif](assets/snapshot.gif)

You can take a look at the example project to play around with it.

# Usage

```sh
snapshot
```

Your screenshots will be stored in the `./screenshots/` folder by default (or `./fastlane/screenshots` if you're using [fastlane](https://fastlane.tools))

If any error occurs while running the snapshot script on a device, that device will not have any screenshots, and `snapshot` will continue with the next device or language. To stop the flow after the first error, run

```sh
snapshot --stop_after_first_error
```

Also by default, `snapshot` will open the HTML after all is done. This can be skipped with the following command


```sh
snapshot --stop_after_first_error --skip_open_summary
```

There are a lot of options available that define how to build your app, for example

```sh
snapshot --scheme "UITests" --configuration "Release"  --sdk "iphonesimulator"
``` 

For a list for all available options run

```sh
snapshot --help
```

## Snapfile

All of the available options can also be stored in a configuration file called the `Snapfile`. Since most values will not change often for your project, it is recommended to store them there:

First make sure to have a `Snapfile` (you get it for free when running `snapshot init`)

The `Snapfile` can contain all the options that are also available on `snapshot --help`


```ruby
scheme "UITests"

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

# The directory in which the screenshots should be stored
output_directory './screenshots'

clear_previous_screenshots true
```

### Completely reset all simulators

You can run this command in the terminal to delete and re-create all iOS simulators:

```
snapshot reset_simulators
```

**Warning**: This will delete **all** your simulators and replace by new ones! This is useful, if you run into weird `Instruments` problems when running `snapshot`. 

You can use the environment variable `SNAPSHOT_FORCE_DELETE` to stop asking for confirmation before deleting.

# How does it work?

The easiest solution would be to just render the UIWindow into a file. That's not possible because UI Tests don't run on a main thread. So `snapshot` uses a different approach:

When you run unit tests in Xcode, the reporter generates a plist file, documenting all events that occured during the tests ([More Information](http://michele.io/test-logs-in-xcode)). Additionally, Xcode generates screenshots before, duing and after each of these events. There seems to be no way to manually trigger a screenshot event. The screenshots and the plist files are stored in the DerivedData directory, which `snapshot` stores in a temporary folder.

When the user calls `snapshot(...)` in the UI Tests (Swift or Objective C) the script actually just does a swipe gesture outside of the screen bounds which doesn't make any sense. It has no effect to the application and is not something you would do in your tests. The goal was to find *some* event that a user would never trigger, so that we know it's from `snapshot`.

`snapshot` then iterates through all test events and check where we did this weird gesture. Once `snapshot` has all events triggered by `snapshot` it collects a ordered list of all the file names of the actual screenshots of the application. 

In the test output, the Swift `snapshot` function will print out something like this

  snapshot: [some random text here]

`snapshot` finds all these entries using a regex. The number of `snapshot` outputs in the terminal and the number of `snapshot` events in the plist file should be the same. Knowing that, `snapshot` automatically matches these 2 lists to identify the name of each of these screenshots. They are then copied over to the output directory and separated by language and device.

2 thing have to be passed on from `snapshot` to the `xcodebuild` command line tool:

- The device type is passed via the `destination` parameter of the `xcodebuild` parameter
- The language is passed via a temporary file which is written by `snapshot` before running the tests and read by the UI Tests when launching the application

If you find a better way to do any of this, please submit an issue on GitHub or even a pull request :+1:

Also, feel free to duplicate radar [23062925](https://openradar.appspot.com/radar?id=5056366381105152).

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`deliver`](https://github.com/KrauseFx/deliver): Upload screenshots, metadata and your app to the App Store
- [`frameit`](https://github.com/KrauseFx/frameit): Quickly put your screenshots into the right device frames
- [`PEM`](https://github.com/KrauseFx/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/KrauseFx/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/KrauseFx/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/KrauseFx/cert): Automatically create and maintain iOS code signing certificates
- [`spaceship`](https://github.com/fastlane/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers 
- [`gym`](https://github.com/fastlane/gym): Building your iOS apps has never been easier
- [`scan`](https://github.com/fastlane/scan): The easiest way to run tests of your iOS and Mac app

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Frame the screenshots

If you want to add frames around the screenshots and even put a title on top, check out [frameit](https://github.com/fastlane/frameit).

## Available language codes
```ruby
ALL_LANGUAGES = ["da", "de-DE", "el", "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX", "fi", "fr-CA", "fr-FR", "id", "it", "ja", "ko", "ms", "nl", "no", "pt-BR", "pt-PT", "ru", "sv", "th", "tr", "vi", "zh-Hans", "zh-Hant"]
```

## Use a clean status bar
You can use [SimulatorStatusMagic](https://github.com/shinydevelopment/SimulatorStatusMagic) to clean up the status bar.

If you enable a clean status bar, you have to remove the `waitForLoadingIndicatorToDisappear` from the `SnapshotHelper.swift` code, as it doesn't detect when the loading indicator disappears. 

## Editing the `Snapfile`
Change syntax highlighting to *Ruby*.

### Simulator doesn't launch the application

When the app dies directly after the application is launched there might be 2 problems

- The simulator is somehow in a broken state and you need to re-create it. You can use `snapshot reset_simulators` to reset all simulators (this will remove all installed apps)
- A restart helps very often

## Determine language

To detect the currently used localization in your tests, use the following code:

```javascript
You can access the language using the `deviceLanguage` variable.
```

# Need help?
Please submit an issue on GitHub and provide information about your setup

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
