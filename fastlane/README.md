<h3 align="center">
  <img src="assets/fastlane_text.png" alt="fastlane Logo" />
</h3>
<p align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/deliver">deliver</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/snapshot">snapshot</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/frameit">frameit</a> &bull;
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

fastlane
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/fastlane/LICENSE)
[![Gem](https://img.shields.io/gem/v/fastlane.svg?style=flat)](https://rubygems.org/gems/fastlane)

######*fastlane* lets you define and run your deployment pipelines for different environments. It helps you unify your apps release process and automate the whole process. fastlane connects all fastlane tools and third party tools, like [CocoaPods](https://cocoapods.org/) and [Slack](https://slack.com).

Get in contact with the developer on Twitter: [@FastlaneTools](https://twitter.com/FastlaneTools)

-------
<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#installation">Installation</a> &bull;
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#examples">Example Setups</a> &bull;
    <a href="https://github.com/fastlane/fastlane/tree/master/fastlane/docs">Documentation</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

## Features

Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily test, build, and deploy from _any_ computer.

[Take a look at how Wikipedia and Product Hunt use `fastlane`](https://github.com/fastlane/examples).

Define different environments (`lanes`) in your `Fastfile`: Examples are: `appstore`, `beta` and `test`.

You define a `lane` like this (more details about the commands in the [Actions](https://docs.fastlane.tools/actions) documentation):

```ruby
lane :release do
  increment_build_number
  cocoapods
  scan
  snapshot
  match
  deliver
  sh "./customScript.sh"

  slack
end
```

To launch the `appstore` lane, just run:

```sh
fastlane release
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
:ghost: | [Jenkins Integration](https://docs.fastlane.tools/best-practices/continuous-integration/#jenkins-integration): Show the output directly in the Jenkins test results
:book: | Automatically generate a markdown documentation of your lane config
:hatching_chick: | Over 170 built-in integrations available
:computer: | Support for iOS, macOS and Android apps
:octocat: | Full git and mercurial support


###### Take a look at the [fastlane website](https://fastlane.tools) for more information about why and when to use `fastlane`.

##### Like this tool? [Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx).

## Installation
Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

### Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr> 
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools/fastlane.zip">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>


If you want to take a look at a project, already using `fastlane`, check out the [fastlane-examples](https://github.com/fastlane/examples) with `fastlane` setups by Wikipedia, Product Hunt, MindNode and more.

## Quick Start

The setup assistant will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```fastlane init```
- Follow the setup assistant, which will set up ```fastlane``` for you
- Further customise the ```Fastfile``` with [actions](https://docs.fastlane.tools/actions).

For more details, please follow the [fastlane guide](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Guide.md) or [documentation](https://github.com/fastlane/fastlane/tree/master/fastlane/docs).

There are also 2 Japanese fastlane guides available: [qiita](http://qiita.com/gin0606/items/a8573b582752de0c15e1) and [mercari](http://tech.mercari.com/entry/2015/07/13/143000)

## Available commands

Usually you'll use fastlane by triggering individual lanes:

```
fastlane [lane_name]
```

#### Other commands

- `fastlane actions`: List all available `fastlane` actions
- `fastlane action [action_name]`: Shows a more detailed description of an action
- `fastlane lanes`: Lists all available lanes with description
- `fastlane list`: Lists all available lanes without description
- `fastlane new_action`: Create a new action (integration) for fastlane
- `fastlane env`: Print out the fastlane ruby environment when submitting an issue

## Examples

See how [Wikipedia](https://github.com/fastlane/examples#wikipedia-by-wikimedia-foundation), [Product Hunt](https://github.com/fastlane/examples#product-hunt) and [MindNode](https://github.com/fastlane/examples#mindnode) use `fastlane` to automate their iOS submission process.

## [`fastlane`](https://fastlane.tools) Toolchain

`fastlane` is designed to make your life easier by bringing together all `fastlane` tools

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

## Statistics

`fastlane` tracks the number of errors for each action to detect integration issues. The data will be sent to [fastlane-enhancer](https://github.com/fastlane/enhancer).

You can easily opt-out by adding `opt_out_usage` to your `Fastfile` or by setting the environment variable `FASTLANE_OPT_OUT_USAGE`. To also disable update checks, set the `FASTLANE_SKIP_UPDATE_CHECK` variable.

## Credentials
A detailed description about how `fastlane` stores your credentials is available on a [separate repo](https://github.com/fastlane/fastlane/tree/master/credentials_manager).

## Need help?
Please submit an issue on GitHub and provide information about your setup

## Special Thanks

Thanks to all [contributors](https://github.com/fastlane/fastlane/graphs/contributors) for extending and improving `fastlane`. Check out the project pages of the other tools for more sponsors and contributors.

## Code of Conduct

Help us keep `fastlane` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

## License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc or Google. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
