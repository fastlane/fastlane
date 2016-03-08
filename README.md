<h3 align="center">
  <img src="fastlane/assets/fastlane_text.png" alt="fastlane Logo" />
</h3>

fastlane
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/fastlane.svg?style=flat)](http://rubygems.org/gems/fastlane)
[![Build Status](https://img.shields.io/circleci/project/fastlane/fastlane/master.svg?style=flat)](https://circleci.com/gh/fastlane/fastlane)

`fastlane` is a tool for iOS and Android developers to automate tedious tasks like generating screenshots, dealing with provisioning profiles and releasing your application.

You define how your process looks like

```ruby
lane :beta do
  increment_build_number
  cocoapods
  match
  deliver
  sh "./customScript.sh"

  slack
end
```

To deploy your app to the App Store you can run
```
fastlane beta
```


              |  fastlane
--------------------------|------------------------------------------------------------
:sparkles: | Connect all iOS and Android build tools into one workflow (both `fastlane` tools and third party tools)
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
:ghost: | [Jenkins Integration](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Jenkins.md): Show the output directly in the Jenkins test results
:book: | Automatically generate a markdown documentation of your lane config
:hatching_chick: | Over 150 built-in integrations available
:computer: | Support for both iOS, Mac OS and Android apps
:octocat: | Full git and mercurial support

##### Like this tool? [Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx).

## Installation

    sudo gem install fastlane --verbose

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

If you experience slow launch times of fastlane, try running

    gem cleanup

System Requirements: `fastlane` requires Mac OS X or Linux with Ruby 2.0.0 or above.

If you want to take a look at a project, already using `fastlane`, check out the [fastlane-examples](https://github.com/fastlane/examples) with `fastlane` setups by Wikipedia, Product Hunt, MindNode and more.

## Quick Start

The setup assistant will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```fastlane init```
- Follow the setup assistant, which will set up ```fastlane``` for you
- Further customise the ```Fastfile``` with [actions](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Actions.md).

## Available commands

Usually you'll use fastlane by triggering individual lanes:

    fastlane [lane_name]

#### Other commands

- `fastlane actions`: List all available `fastlane` actions
- `fastlane action [action_name]`: Shows a more detailed description of an action
- `fastlane lanes`: Lists all available lanes with description
- `fastlane list`: Lists all available lanes without description
- `fastlane new_action`: Create a new action (integration) for fastlane

## [`fastlane`](https://fastlane.tools) Toolchain

Additionally to the `fastlane` commands, you now have access to those `fastlane` tools:

- [`deliver`](https://github.com/fastlane/fastlane/tree/master/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/fastlane/fastlane/tree/master/frameit): Quickly put your screenshots into the right device frames
- [`pem`](https://github.com/fastlane/fastlane/tree/master/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/fastlane/fastlane/tree/master/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/fastlane/fastlane/tree/master/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/fastlane/fastlane/tree/master/cert): Automatically create and maintain iOS code signing certificates
- [`spaceship`](https://github.com/fastlane/fastlane/tree/master/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/fastlane/tree/master/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers
- [`gym`](https://github.com/fastlane/fastlane/tree/master/gym): Building your iOS apps has never been easier
- [`match`](https://github.com/fastlane/fastlane/tree/master/match): Easily sync your certificates and profiles across your team using git

## Need help?
Please submit an issue on GitHub and provide information about your setup

## Special Thanks

Thanks to all [contributors](https://github.com/fastlane/fastlane/graphs/contributors) for extending and improving `fastlane`.

## Code of Conduct

Help us keep `fastlane` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

## License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc or Google. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
