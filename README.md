<h3 align="center">
  <a href="https://github.com/fastlane/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>


match
============

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/match/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/match.svg?style=flat)](http://rubygems.org/gems/match)
[![Build Status](https://img.shields.io/travis/fastlane/match/master.svg?style=flat)](https://travis-ci.org/fastlane/match)

###### Easily sync your certificates and profiles across your team using git

A new approach to iOS code signing: Share one code signing identity across your development team to simplify your codesigning setup and prevent code signing issues.

-------
<p align="center">
    <a href="#why-match">Why?</a> &bull; 
    <a href="#installation">Installation</a> &bull; 
    <a href="#usage">Usage</a> &bull; 
    <a href="#is-this-secure">Is this secure?</a> &bull; 
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>match</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

## Why match?

Before starting to use `match`, make sure to read the [codesigning.guide](https://codesigning.guide) 

> When deploying an app to the App Store, beta testing service or even installing it on a device, most development teams have separate code signing identities for every member. This results in dozens of profiles including a lot of duplicates.

> You have to manually renew and download the latest provisioning profiles every time we add a new device or a certificate expires. Additionally you have to spend a lot of time when setting up a new machine. 

**A new approach**

> What if there was a central place where your code signing identity and profiles are kept, so anyone in the team can access them during the build process?

### Why not let Xcode handle all this?

- You have full control over what happens
- You have access to all the certificates and profiles, which are all securely stored in git
- You share one code signing identity across the team to have less certificates and profiles
- Xcode can often revoke certificates and break your set up causing failed builds
- It's better to be explicit about what profiles to use instead of using the `Automatic` setting for more predictable build artifacts
- It just works™

## Installation

```
sudo gem install match
```

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

## Usage

### Setup

Create a new, private git repo (e.g. on [GitHub](https://github.com/new) or [BitBucket](https://bitbucket.org/repo/create)) and name it something like `certificates`. **Important:** Make sure the repository is set to *private*.

Run the following in your project folder to start using `match`:

```
match init
```

You'll be asked to enter the URL to your git repo. This can be either a `https://` or a `git` URL. `match init` won't read or modify your certificates or profiles.

This will create a `Matchfile` in your current directory (or in your `./fastlane/` folder). 

Example content (for more advanced setups check out the [fastlane section](#fastlane)):

```ruby
git_url "https://github.com/fastlane/certificates"

app_identifier "tools.fastlane.app" 
username "user@fastlane.tools"
```

### Run

> Before running `match` for the first time, you should consider clearing your existing profiles and certificates using the [match nuke command](#nuke).

After running `match init` you can run the following to generate new certificates and profiles:

```
match appstore
```
```
match development
```

This will create a new certificate and provisioning profile (if required) and store them in your git repo. If you previously ran `match` it will automatically install the existing profiles from the git repo.

The provisioning profiles are installed in `~/Library/MobileDevice/Provisioning Profiles` while the certificates and private keys are installed in your Keychain.

To get a more detailed output of what `match` is doing use

```
match --verbose
```

For a list of all available options run

```
match --help
```

#### fastlane

Add `match` to your `Fastfile` to automatically fetch the latest code signing certificates before building your app with [fastlane](https://fastlane.tools).

```ruby
match(type: "appstore")

match(git_url: "https://github.com/fastlane/certificates", 
      type: "development")

match(git_url: "https://github.com/fastlane/certificates", 
      type: "adhoc", 
      app_identifier: "tools.fastlane.app")

# `match` should be called before building the app with `gym`
gym
...
```

##### Multiple Targets

If you app has multiple targets (e.g. Today Widget or WatchOS Extension)

```ruby
match(app_identifier: "tools.fastlane.app", type: "appstore")
match(app_identifier: "tools.fastlane.app.today_widget", type: "appstore")
```

`match` can even use the same one git repository for all bundle identifiers.

### Setup Xcode project

To make sure Xcode is using the right provisioning profile for each target, don't use the `Automatic` feature for the profile selection.

Additionally it is recommended to disable the `Fix Issue` button using the [FixCode Xcode Plugin](https://github.com/neonichu/FixCode). The `Fix Issue` button sometimes revokes your existing certificates, which will invalidate your provisioning profiles.

#### To build from the command line using [fastlane](https://fastlane.tools)

`match` automatically pre-fills environment variables with the UUIDs of the correct provisioning profiles, ready to be used in your Xcode project. 

<img src="assets/UDIDPrint.png" width="700" />

Open your target settings, open the dropdown for `Provisioning Profile` and select `Other`:

<img src="assets/XcodeProjectSettings.png" width="700" />

Profile environment variables are named after `$(sigh_<bundle_identifier>_<profile_type>)`

e.g. `$(sigh_tools.fastlane.app_development)`

#### To build from Xcode manually

This is useful when installing your application on your device using the Development profile. 

You can statically select the right provisioning profile in your Xcode project (the name should be `tools.fastlane.app Development`).

### Install profiles on a new computer

To install all certificates and provisioning profiles on a new machine, just run

```
match bootstrap
```

Note: If you run the above command in the project directory containing the `Matchfile`, you won't be asked for the `git_url`, otherwise you can also pass it using

```
match bootstrap --git_url https://github.com/fastlane/certificates
```

### Nuke

If you never really cared about code signing and have a messy Apple Developer account with a lot of invalid, expired or Xcode managed profiles/certificates, you can use the `match nuke` command. After clearing your account you'll start from a clean state, and you can run `match` to generate your certificates and profiles again.

To revoke all certificates and provisioning profiles for a specific environment:

```sh
match nuke development
match nuke adhoc
match nuke appstore
```

You'll have to confirm a list of profiles / certificates that will be deleted.

## Is this secure?

Storing your private keys in a git repo might sound off-putting at first. We did an in-depth analysis of potential security issues and came to the following conclusion: 

#### What can happen if someone steals my private key?

If attackers have your certificate and provisioning profile, they could codesign an application with the same bundle identifier. 

What's the worst that could happen for each of the profile types?

##### App Store Profiles

An App Store profile can't be used for anything as long as it's not re-signed by Apple. The only way to get an app resigned is to submit an app for review (which takes around 7 days). Attackers could only submit an app for review, if they also got access to your iTunes Connect credentials (which are not stored in git, but in your local keychain). Additionally you get an email notification every time a build gets uploaded to cancel the submission even before your app gets into the review stage.

##### Development and Ad Hoc Profiles

In general those profiles are harmless as they can only be used to install a signed application on a small subset of devices. To add new devices, the attacker would also need your Apple Developer Portal credentials (which are not stored in git, but in your local keychain). 

##### Enterprise Profiles

Attackers could use an In-House profile to distribute signed application to a potentially unlimited number of devices. All this would run under your company name and it could eventually lead to Apple revoking your In-House account. However it is very easy to revoke a certificate to remotely break the app on all devices.

Because of the potentially dangerous nature of In-House profiles we decided to not allow the use of `match` with enterprise accounts.

##### To sum up

- You have full control over the access list of your git repo, no third party service involved
- Even if your certificates got leaked, they can't be used to cause any harm without your login credentials
- `match` doesn't support In-House Enterprise profiles as they are harder to control
- If you use GitHub or Bitbucket we encourage to enable 2 factor authentification for all accounts that have access to the certificates repo.

# Need help?
Please submit an issue on GitHub and provide information about your setup

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
