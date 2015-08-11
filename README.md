<h3 align="center">
  <img src="assets/fastlane_text.png" alt="fastlane Logo" />
</h3>
<p align="center">
  <a href="https://github.com/KrauseFx/deliver">deliver</a> &bull;
  <a href="https://github.com/KrauseFx/snapshot">snapshot</a> &bull;
  <a href="https://github.com/KrauseFx/frameit">frameit</a> &bull;
  <a href="https://github.com/KrauseFx/PEM">PEM</a> &bull;
  <a href="https://github.com/KrauseFx/sigh">sigh</a> &bull;
  <a href="https://github.com/KrauseFx/produce">produce</a> &bull;
  <a href="https://github.com/KrauseFx/cert">cert</a> &bull;
  <a href="https://github.com/KrauseFx/codes">codes</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a>
</p>
-------

fastlane
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/fastlane/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/fastlane.svg?style=flat)](http://rubygems.org/gems/fastlane)
[![Build Status](https://img.shields.io/travis/KrauseFx/fastlane/master.svg?style=flat)](https://travis-ci.org/KrauseFx/fastlane)

######*fastlane* lets you define and run your deployment pipelines for different environments. It helps you unify your apps release process and automate the whole process. fastlane connects all fastlane tools and third party tools, like [CocoaPods](http://cocoapods.org) and [xctool](https://github.com/facebook/xctool).

Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)

-------
<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#examples">Example Setups</a> &bull; 
    <a href="https://github.com/KrauseFx/fastlane/tree/master/docs">Documentation</a> &bull; 
    <a href="#need-help">Need help?</a>
</p>

-------

## Features

Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily test, builld, and deploy from _any_ computer.

[Take a look at how Wikipedia and Product Hunt use `fastlane`](https://github.com/fastlane/examples).

Define different environments (`lanes`) in your `Fastfile`: Examples are: `appstore`, `beta` and `test`.

You define a `lane` like this (more details about the commands in the [Actions](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md) documentation):

```ruby
lane :appstore do
  increment_build_number
  cocoapods
  xctool
  snapshot
  sigh
  deliver
  frameit
  sh "./customScript.sh"

  slack
end
```

To launch the `appstore` lane, just run:

```sh
fastlane appstore
```

`fastlane` can do a lot for you to automate tedious and time-consuming tasks:

- Connect all build related iOS tools into one workflow (both `fastlane` tools and third party tools)
- Define different `deployment lanes` for App Store deployment, beta builds or testing.
- Deploy from any computer.
- Write your [own actions](https://github.com/KrauseFx/fastlane/blob/master/docs#extensions) (extensions) to extend the functionality of `fastlane`.
- Store data like the `Bundle Identifier` or your `Apple ID` once and use it across all tools.
- Never remember any difficult commands, just `fastlane`.
- Easy setup, which helps you getting up and running quickly.
- [Shared context](https://github.com/KrauseFx/fastlane/blob/master/docs/Advanced.md#lane-context), which is used to let the different deployment steps communicate with each other.
- Store **everything** in git. Never again lookup the used build commands in the ```Jenkins``` configs.
- Saves you **hours** of preparing app submission, uploading screenshots and deploying the app for each update.
- Very flexible configuration using a fully customizable `Fastfile`.
- Once up and running, you have a fully working **Continuous Delivery** process. Just trigger ```fastlane``` and you're good to go.
- [Jenkins Integration](https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md): Show the output directly in the Jenkins test results.
- Automatically generate a markdown documentation of your lanes based on your `Fastfile`.
- Over 60 built-in integrations available.
- Support for both iOS and Mac OS apps
- Full git and mercurial support

##### Take a look at the [fastlane website](https://fastlane.tools) for more information about why and when to use `fastlane`.

##### Like this tool? [Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx).

## Installation

I recommend following the [fastlane guide](https://github.com/KrauseFx/fastlane/blob/master/docs/Guide.md) to get started.

    sudo gem install fastlane --verbose

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

If you experience slow launch times of fastlane, try running

    gem cleanup

to clean up outdated gems.


If you want to take a look at a project, already using `fastlane`, check out the [fastlane-examples](https://github.com/fastlane/examples) with `fastlane` setups by Wikipedia, Product Hunt, MindNode and more.

## Quick Start

The setup assistant will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```fastlane init```
- Follow the setup assistant, which will set up ```fastlane``` for you
- Further customise the ```Fastfile``` with [actions](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md).

For more details, please follow the [fastlane guide](https://github.com/KrauseFx/fastlane/blob/master/docs/Guide.md) or [documentation](https://github.com/KrauseFx/fastlane/blob/master/docs).

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

`fastlane` is designed to make your life easier by bringing together the `fastlane` suite of tools under one roof. 

- [`deliver`](https://github.com/KrauseFx/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/KrauseFx/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/KrauseFx/frameit): Quickly put your screenshots into the right device frames
- [`PEM`](https://github.com/KrauseFx/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/KrauseFx/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/KrauseFx/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/KrauseFx/cert): Automatically create and maintain iOS code signing certificates
- [`codes`](https://github.com/KrauseFx/codes): Create promo codes for iOS Apps using the command line
- [`spaceship`](https://github.com/fastlane/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers 
- [`gym`](https://github.com/fastlane/gym): Building your iOS apps has never been easier

## Statistics

`fastlane` tracks the number of errors for each action to detect integration issues. The data will be sent to [fastlane-enhancer](https://github.com/fastlane/enhancer) and is available publicly.

You can easily opt-out by adding `opt_out_usage` to your `Fastfile` or by setting the environment variable `FASTLANE_OPT_OUT_USAGE`.

To also disable update checks, set the `FASTLANE_SKIP_UPDATE_CHECK` variable.

## Credentials
A detailed description about how `fastlane` stores your credentials is available on a [separate repo](https://github.com/KrauseFx/CredentialsManager).

## Need help?
- If there is a technical problem with `fastlane`, [open an issue](https://github.com/KrauseFx/fastlane/issues/new).
- I'm available for contract work - drop me an email: fastlane@krausefx.com

## Special Thanks

Thanks to all contributors for extending and improving the `fastlane` suite:

- [Product Hunt](http://producthunt.com)
- [MindNode](https://mindnode.com)
- [Detroit Labs](http://www.detroitlabs.com/)
- Josh Holtz ([@joshdholtz](https://twitter.com/joshdholtz))
- Ash Furrow ([@ashfurrow](https://twitter.com/ashfurrow))
- Dan Trenz ([@dtrenz](https://twitter.com/dtrenz))
- Luka Mirosevic ([@lmirosevic](https://twitter.com/lmirosevic))
- Almas Sapargali ([@almassapargali](https://twitter.com/almassapargali))
- Manuel Wallner ([@milch](https://github.com/milch))
- Pawel Dudek ([@eldudi](https://twitter.com/eldudi))

Check out the project pages of the other tools for more sponsors and contributors.

## License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
