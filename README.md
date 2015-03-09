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
  <a href="https://github.com/KrauseFx/codes">codes</a>
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
    <a href="#customise-the-fastfile">Customise</a> &bull;
    <a href="#extensions">Extensions</a> &bull;
    <a href="#jenkins-integration">Jenkins</a> &bull;
    <a href="#tips">Tips</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

# Features
- Connect all tools, part of the ```fastlane``` toolchain to work seamlessly together
- Define different ```deployment lanes``` for App Store deployment, beta builds or testing
- Deploy from any computer
- [Jenkins Integration](#jenkins-integration): Show the output directly in the Jenkins test results
- Write your [own actions](#extensions) (extensions) to extend the functionality of `fastlane`
- Store data like the ```Bundle Identifier``` or your ```Apple ID``` once and use it across all tools
- Never remember any difficult commands, just ```fastlane```
- Easy setup, which helps you getting up and running very fast
- Shared context, which is used to let the different deployment steps communicate with each other
- Store **everything** in git. Never lookup the used build commands in the ```Jenkins``` configs
- Saves you **hours** of preparing app submission, uploading screenshots and deploying the app for each update
- Very flexible configuration using a fully customizable `Fastfile`
- Once up and running, you have a fully working **Continuous Deployment** process. Just trigger ```fastlane``` and you're good to go.

##### Take a look at the [fastlane website](https://fastlane.tools) for more information about why and when to use `fastlane`.

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Installation

I recommend following the [fastlane guide](https://github.com/KrauseFx/fastlane/blob/master/GUIDE.md) to get started.

If you are familiar with the command line and Ruby, install `fastlane` yourself:

    sudo gem install fastlane

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install


If you want to take a look at a project, already using `fastlane`, check out the [fastlane-example project](https://github.com/krausefx/fastlane-example) on GitHub.

# Quick Start


The setup assistent will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```fastlane init```
- Follow the setup assistent, which will set up ```fastlane``` for you
- Further customise the ```Fastfile``` using the next section

For a more detailed setup, please follow the [fastlane guide](https://github.com/KrauseFx/fastlane/blob/master/GUIDE.md).

# Customise the ```Fastfile```
Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily deploy from any computer.

Open the ```Fastfile``` using a text editor and customise it even further. (Switch to *Ruby* Syntax Highlighting)

### Lanes
You can define multiple ```lanes``` which are different workflows for a release process.

Examples are: ```appstore```, ```beta``` and ```test```.

You define a ```lane``` like this (more details about the commands in the [Actions](#actions) section):
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

To launch the ```appstore``` lane run
```
fastlane appstore
```

When one command fails, the execution will be aborted.

## Available fastlane actions

### Project
- [CocoaPods](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#cocoapods): Setup your CocoaPods project
- [increment_build_number](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#increment_build_number): Increment the Xcode build number before building the app

### Testing
- [snapshot](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#snapshot): Automate taking localized screenshots of your iOS app on every device
- [xctool](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#xctool): Run tests of your app
- [Testmunk](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#testmunk): Run integration tests on real devices

### Certificates
- [cert](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#cert): Automatically create and maintain iOS code signing certificates
- [sigh](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#sigh): Create and maintain your provisioning profiles
- [resign](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#resign): Re-Sign an existing ipa file

### Building
- [ipa](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#ipa): Build your app for further use of the [uploading](#uploading) section

### Uploading
- [deliver](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#deliver): Upload screenshots, metadata and your app to the App Store
- [HockeyApp](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#hockeyapp): Upload beta builds to Hockey App
- [Crashlytics Beta](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#crashlytics-beta): Upload beta builds to Crashlytics Beta
- [DeployGate](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#deploygate): Upload beta builds to DeployGate

### Git
- [ensure_git_status_clean](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#ensure_git_status_clean): Makes sure, the git repository is in a clean state
- [commit_version_bump](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#commit_version_bump): Commit the version bump of your project
- [add_git_tag](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#add_git_tag): Automatically tag your git repository
- [reset_git_repo](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#reset_git_repo): Reset the git repository after the `fastlane` run

### Notifications

Send success and error messages:

- [Slack](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#slack)
- [HipChat](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#hipchat)
- [Typetalk](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#typetalk)

### Misc
- [frameit](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#frameit): Put your screenshots into the right device frames
- [produce](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#produce): Create new iOS apps on iTunes Connect and Developer Portal
- [clean_build_artifacts](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#clean_build_artifacts): Cleans up temporary files created by `sigh` and the other tools
- [gcovr](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#gcovr): Generate summarized code coverage reports
- [xcode_select](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#xcode_select): Set a path to a custom Xcode installation
- [team_id](https://github.com/KrauseFx/fastlane/blob/master/Actions.md#team_id): Select a team ID for the Apple Developer Portal if you are in multiple teams


### *before_all* block
This block will get executed *before* running the requested lane. It supports the same actions as lanes.

```ruby
before_all do |lane|
  cocoapods
end
```

### *after_all* block
This block will get executed *after* running the requested lane. It supports the same actions as lanes.

It will only be called, if the selected lane was executed **successfully**.

```ruby
after_all do |lane|
  say "Successfully finished deployment (#{lane})!"
  slack({
    message: "Successfully submitted new App Update"
  })
  sh "./send_screenshots_to_team.sh" # Example
end
```

### *error* block
This block will get executed when an error occurs, in any of the blocks (*before_all*, the lane itself or *after_all*).
```ruby
error do |lane, exception|
  slack({
    message: "Something went wrong with the deployment.",
    success: false
  })
end
```

# Extensions

Why only use the default actions? Create your own to extend the functionality of `fastlane`.

The build step you create will behave exactly like the built in actions.

Just run `fastlane new_action`. Then enter the name of the action and edit the generated Ruby file in `fastlane/actions/[action_name].rb`.

From then on, you can just start using your action in your `Fastfile`.

If you think your extension can be used by other developers as well, let me know, and we can bundle it with `fastlane`.

# Jenkins Integration

The `Jenkins` setup was moved to [Jenkins.md](https://github.com/KrauseFx/fastlane/blob/master/Jenkins.md).

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`deliver`](https://github.com/KrauseFx/deliver): Upload screenshots, metadata and your app to the App Store using a single command
- [`snapshot`](https://github.com/KrauseFx/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/KrauseFx/frameit): Quickly put your screenshots into the right device frames
- [`PEM`](https://github.com/KrauseFx/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/KrauseFx/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/KrauseFx/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/KrauseFx/cert): Automatically create and maintain iOS code signing certificates
- [`codes`](https://github.com/KrauseFx/codes): Create promo codes for iOS Apps using the command line

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Advanced

#### Complex Fastfile Example
```ruby
before_all do |lane|
  ENV["SLACK_URL"] = "https://hooks.slack.com/services/..."
  team_id "Q2CBPK58CA"

  ensure_git_status_clean

  increment_build_number

  cocoapods

  xctool :test

  ipa({
    workspace: "MyApp.xcworkspace"
  })
end

lane :beta do
  cert

  sigh :adhoc

  deliver :beta

  hockey({
    api_token: '...',
    ipa: './app.ipa' # optional
  })
end

lane :deploy do
  cert

  sigh

  snapshot

  deliver :force
  
  frameit
end

after_all do |lane|
  clean_build_artifacts

  commit_version_bump

  add_git_tag

  slack({
    message: "Successfully deployed a new version."
  })
  say "My job is done here"
end

error do |lane, exception|
  reset_git_repo

  slack({
    message: "An error occured"
  })
end
```

##### More advanced settings and tips can be found in [Advanced.md](https://github.com/KrauseFx/fastlane/blob/master/Advanced.md)

# Credentials
A detailed description about your credentials is available on a [separate repo](https://github.com/KrauseFx/CredentialsManager).

# Need help?
- If there is a technical problem with ```fastlane```, submit an issue.
- I'm available for contract work - drop me an email: fastlane@krausefx.com

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/KrauseFx/fastlane/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
