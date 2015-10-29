<h3 align="center">
  <img src="assets/fastlane_text.png" alt="fastlane Logo" />
</h3>
<p align="center">
  <a href="https://github.com/fastlane/deliver">deliver</a> &bull;
  <a href="https://github.com/fastlane/snapshot">snapshot</a> &bull;
  <a href="https://github.com/fastlane/frameit">frameit</a> &bull;
  <a href="https://github.com/fastlane/PEM">PEM</a> &bull;
  <a href="https://github.com/fastlane/sigh">sigh</a> &bull;
  <a href="https://github.com/fastlane/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/scan">scan</a>
</p>
-------

fastlane
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/fastlane/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/fastlane.svg?style=flat)](http://rubygems.org/gems/fastlane)
[![Build Status](https://img.shields.io/travis/KrauseFx/fastlane/master.svg?style=flat)](https://travis-ci.org/KrauseFx/fastlane)

######*fastlane* lets you define and run your deployment pipelines for different environments. It helps you unify your apps release process and automate the whole process. fastlane connects all fastlane tools and third party tools, like [CocoaPods](https://cocoapods.org/) and [xctool](https://github.com/facebook/xctool).

Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)

-------
<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#examples">Example Setups</a> &bull; 
    <a href="https://github.com/fastlane/fastlane/tree/master/docs">Documentation</a> &bull; 
    <a href="#need-help">Need help?</a>
</p>

-------

## Features

Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily test, build, and deploy from _any_ computer.

[Take a look at how Wikipedia and Product Hunt use `fastlane`](https://github.com/fastlane/examples).

Define different environments (`lanes`) in your `Fastfile`: Examples are: `appstore`, `beta` and `test`.

You define a `lane` like this (more details about the commands in the [Actions](https://github.com/fastlane/fastlane/blob/master/docs/Actions.md) documentation):

```ruby
lane :appstore do
  increment_build_number
  cocoapods
  xctool
  snapshot
  sigh
  deliver
  sh "./customScript.sh"

  slack
end
```

To launch the `appstore` lane, just run:

```sh
fastlane appstore
```

              |  fastlane
--------------------------|------------------------------------------------------------
:sparkles: | Connect all iOS build tools into one workflow (both `fastlane` tools and third party tools)
:monorail: | Define different `deployment lanes` for App Store deployment, beta builds or testing
:ship: | Deploy from any computer, including a CI-server
:wrench: | Extend and customise the functionality 
:thought_balloon: | Never remember any difficult commands, just `fastlane`
:tophat: | Easy setup assistant to get started in a few minutes
:email: | Automatically pass on information from one build step to another (e.g. path to the `ipa` file)
:page_with_curl: | Store **everything** in git. Never again lookup the build commands in the `Jenkins` configs
:rocket: | Saves you **hours** for every app update you release
:pencil2: | Very flexible configuration using a fully customisable `Fastfile`
:mountain_cableway: | Implement a fully working Continuous Delivery process
:ghost: | [Jenkins Integration](https://github.com/fastlane/fastlane/blob/master/docs/Jenkins.md): Show the output directly in the Jenkins test results
:book: | Automatically generate a markdown documentation of your lane config
:hatching_chick: | Over 90 built-in integrations available
:computer: | Support for both iOS and Mac OS apps
:octocat: | Full git and mercurial support


###### Take a look at the [fastlane website](https://fastlane.tools) for more information about why and when to use `fastlane`.

##### Like this tool? [Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx).

## Installation

I recommend following the [fastlane guide](https://github.com/fastlane/fastlane/blob/master/docs/Guide.md) to get started.

    sudo gem install fastlane --verbose

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

If you experience slow launch times of fastlane, try running

    gem cleanup

to clean up outdated gems.

System Requirements: `fastlane` requires Mac OS X or Linux with Ruby 2.0.0 or above.


If you want to take a look at a project, already using `fastlane`, check out the [fastlane-examples](https://github.com/fastlane/examples) with `fastlane` setups by Wikipedia, Product Hunt, MindNode and more.

## Quick Start

The setup assistant will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```fastlane init```
- Follow the setup assistant, which will set up ```fastlane``` for you
- Further customise the ```Fastfile``` with [actions](https://github.com/fastlane/fastlane/blob/master/docs/Actions.md).

For more details, please follow the [fastlane guide](https://github.com/fastlane/fastlane/blob/master/docs/Guide.md) or [documentation](https://github.com/fastlane/fastlane/tree/master/docs).

There are also 2 Japanese fastlane guides available: [qiita](http://qiita.com/gin0606/items/162d756dfda7b84e97d4) and [mercari](http://tech.mercari.com/entry/2015/07/13/143000)

## Available commands

Usually you'll use fastlane by triggering individual lanes:

    fastlane [lane_name]

#### Other commands

- `fastlane actions`: List all available `fastlane` actions
- `fastlane action [action_name]`: Shows a more detailed description of an action
- `fastlane lanes`: Lists all available lanes with description
- `fastlane list`: Lists all available lanes without description
- `fastlane docs`: Generates a markdown based documentation of all your lanes
- `fastlane new_action`: Create a new action (integration) for fastlane  

## Examples

See how [Wikipedia](https://github.com/fastlane/examples#wikipedia-by-wikimedia-foundation), [Product Hunt](https://github.com/fastlane/examples#product-hunt) and [MindNode](https://github.com/fastlane/examples#mindnode) use `fastlane` to automate their iOS submission process.

## [`fastlane`](https://fastlane.tools) Toolchain

`fastlane` is designed to make your life easier by bringing together all `fastlane` tools under one roof. 

- [`deliver`](https://github.com/fastlane/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/fastlane/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/fastlane/frameit): Quickly put your screenshots into the right device frames
- [`PEM`](https://github.com/fastlane/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/fastlane/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/fastlane/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/fastlane/cert): Automatically create and maintain iOS code signing certificates
- [`codes`](https://github.com/fastlane/codes): Create promo codes for iOS Apps using the command line
- [`spaceship`](https://github.com/fastlane/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers 
- [`gym`](https://github.com/fastlane/gym): Building your iOS apps has never been easier

## Statistics

`fastlane` tracks the number of errors for each action to detect integration issues. The data will be sent to [fastlane-enhancer](https://github.com/fastlane/enhancer) and is available publicly.

You can easily opt-out by adding `opt_out_usage` to your `Fastfile` or by setting the environment variable `FASTLANE_OPT_OUT_USAGE`. To also disable update checks, set the `FASTLANE_SKIP_UPDATE_CHECK` variable.

You can optionally submit crash reports, run `fastlane enable_crash_reporting` to get started. This makes resolving issues much easier and helps improving fastlane. [More information](https://github.com/fastlane/fastlane/releases/tag/1.33.3)

## Credentials
A detailed description about how `fastlane` stores your credentials is available on a [separate repo](https://github.com/fastlane/credentials_manager).

## Need help?
Please submit an issue on GitHub and provide information about your setup

## Special Thanks

Thanks to all [contributors](https://github.com/fastlane/fastlane/graphs/contributors) for extending and improving `fastlane`. Check out the project pages of the other tools for more sponsors and contributors.

## License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
