<h3 align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/fastlane">
    <img src="../fastlane/assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/deliver">deliver</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/snapshot">snapshot</a> &bull;
  <b>frameit</b> &bull;
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
  <img src="assets/frameit.png" height="110">
</p>

frameit
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/frameit/LICENSE)
[![Gem](https://img.shields.io/gem/v/frameit.svg?style=flat)](https://rubygems.org/gems/frameit)

###### Quickly put your screenshots into the right device frames

`frameit` allows you to put a gorgeous device frame around your iOS and macOS screenshots just by running one simple command. Use `frameit` to prepare perfect screenshots for the App Store, your website, QA or emails.


Get in contact with the developer on Twitter: [@FastlaneTools](https://twitter.com/FastlaneTools)


-------
<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#tips">Tips</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------
<h5 align="center"><code>frameit</code> is part of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate beta deployments and releases for your iOS and Android apps.</h5>


# Features

Put a gorgeous device frame around your iOS and macOS screenshots just by running one simple command. Support for:
- iPhone, iPad and Mac
- Portrait and Landscape modes
- Several colors

The complete and updated list of supported devices and colors can be found [here](https://github.com/fastlane/frameit-frames/tree/gh-pages/latest)

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

Here is a nice gif, that shows ```frameit``` in action:

![assets/FrameitGit.gif](assets/FrameitGit.gif?raw=1)

### Results

![assets/ScreenshotsBig.png](assets/ScreenshotsBig.png?raw=1)

-------

![assets/ScreenshotsOverview.png](assets/ScreenshotsOverview.png?raw=1)

-------

![assets/MacExample.png](assets/MacExample.png?raw=1)

<h5 align="center">The <code>frameit</code> 2.0 update was kindly sponsored by <a href="https://mindnode.com/">MindNode</a>, seen in the screenshots above.

# Installation

Make sure, you have the commandline tools installed

    xcode-select --install

Install the gem

    sudo gem install fastlane

The first time that ```frameit``` is executed the frames will be downloaded automatically. Originally the frames are coming from [Facebook frameset](http://facebook.design/devices) and they are kept on this repo: https://github.com/fastlane/frameit-frames

More information about this process and how to update the frames can be found [here](https://github.com/fastlane/fastlane/tree/master/frameit/frames_generator)

# Usage

Why should you have to use Photoshop, just to add a frame around your screenshots?

Just navigate to your folder of screenshots and use the following command:

    fastlane frameit

To use the silver version of the frames:

    fastlane frameit silver

To download the latest frames

    fastlane frameit download_frames

When using `frameit` without titles on top, the screenshots will have the full resolution, which means they can't be uploaded to the App Store directly. They are supposed to be used for websites, print media and emails. Check out the section below to use the screenshots for the App Store.

# Titles and Background (optional)

With `frameit` 2.0 you are now able to add a custom background, title and text colors to your screenshots.

A working example can be found in the [fastlane examples](https://github.com/fastlane/examples/tree/master/MindNode/screenshots) project.

#### `Framefile.json`

Use it to define the general information:

```json
{
  "device_frame_version": "latest",
  "default": {
    "keyword": {
      "font": "./fonts/MyFont-Rg.otf"
    },
    "title": {
      "font": "./fonts/MyFont-Th.otf",
      "color": "#545454"
    },
    "background": "./background.jpg",
    "padding": 50,
    "show_complete_frame": false
  },

  "data": [
    {
      "filter": "Brainstorming",
      "keyword": {
        "color": "#d21559"
      }
    },
    {
      "filter": "Organizing",
      "keyword": {
        "color": "#feb909"
      }
    },
    {
      "filter": "Sharing",
      "keyword": {
        "color": "#aa4dbc"
      }
    },
    {
      "filter": "Styling",
      "keyword": {
        "color": "#31bb48"
      }
    }
  ]
}
```
The `show_complete_frame` value specifies whether `frameit` should shrink the device and frame so that they show in full in the framed screenshot. If it is false, then they can hang over the bottom of the screenshot.

The `filter` value is a part of the screenshot named for which the given option should be used. If a screenshot is named `iPhone5_Brainstorming.png` the first entry in the `data` array will be used.

You can find a more complex [configuration](https://github.com/fastlane/examples/blob/master/MindNode/screenshots/Framefile.json) to also support Chinese, Japanese and Korean languages.

The `Framefile.json` should be in the `screenshots` folder, as seen in the [example](https://github.com/fastlane/examples/tree/master/MindNode/screenshots).

#### `.strings` files

To define the title and optionally the keyword, put two `.strings` files into the language folder (e.g. [en-US in the example project](https://github.com/fastlane/examples/tree/master/MindNode/screenshots/en-US))

The `keyword.strings` and `title.strings` are standard `.strings` file you already use for your iOS apps, making it easy to use your existing translation service to get localized titles.

**Note:** These `.strings` files **MUST** be utf-16 encoded (UTF-16 LE with BOM).  They also must begin with an empty line. If you are having trouble see [issue #1740](https://github.com/fastlane/fastlane/issues/1740)

**Note:** You **MUST** provide a background if you want titles. `frameit` will not add the tiles if a background is not specified.

#### Uploading screenshots to iTC

Use [deliver](https://github.com/fastlane/fastlane/tree/master/deliver) to upload all screenshots to iTunes Connect completely automatically :rocket:

### Mac

With `frameit` 2.0 it's possible to also frame macOS Application screenshots. You have to provide the following:

- The `offset` information so `frameit` knows where to put your screenshots
- A path to a `background`, which should contain both the background and the Mac
- `titleHeight`: The height in px that should be used for the title

##### Example
```json
{
  "default": {
    "title": {
      "color": "#545454"
    },
    "background": "Mac.jpg",
    "offset": {
      "offset": "+676+479",
      "titleHeight": 320
    }
  },
  "data": [
    {
      "filter": "Brainstorming",
      "keyword": {
        "color": "#d21559"
      }
    }
  ]
}
```

Check out the [MindNode example project](https://github.com/fastlane/examples/tree/master/MindNode/screenshots).

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): The easiest way to automate beta deployments and releases for your iOS and Android apps
- [`deliver`](https://github.com/fastlane/fastlane/tree/master/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot): Automate taking localized screenshots of your iOS app on every device
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

## Generate localized screenshots
Check out [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot) to automatically generate screenshots using ```UI Automation```.

## Alternative location to store device_frames

Device frames can also be stored in a ```./fastlane/screenshots/devices_frames``` directory if you prefer rather than in the ```~/.frameit/device_frames``` directory. If doing so please be aware that Apple's images are copyrighted and should not be redistributed as part of a repository so you may want to include them in your .gitignore file.

## White background of frames

Some stock images provided by Apple still have a white background instead of a transparent one. You'll have to edit the Photoshop file to remove the white background, delete the generated `.png` file and run `fastlane frameit` again.

## Use a clean status bar
You can use [SimulatorStatusMagic](https://github.com/shinydevelopment/SimulatorStatusMagic) to clean up the status bar.

## Gray artifacts around text

If you run into any quality issues, like having a border around the font, it usually helps to just re-install `imagemagick`. You can do so by running

```sh
brew uninstall imagemagick
brew install imagemagick
```

## Uninstall
- ```sudo gem uninstall fastlane```
- ```rm -rf ~/.frameit```

# Need help?
Please submit an issue on GitHub and provide information about your setup

# Code of Conduct
Help us keep `frameit` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
