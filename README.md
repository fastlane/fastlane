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

###### Easily sync your certificates and profiles across your team using git

A new approach to code signing: Share one code signing identity across your development team to simplify your codesigning setup.

-------
<p align="center">
    <a href="#why-match">Why?</a> &bull; 
    <a href="#installation">Installation</a> &bull; 
    <a href="#usage">Usage</a> &bull; 
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
- Xcode sometimes revokes your certificates
- It just works™

## Installation

```
sudo gem install match
```

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

## Usage

### Setup

Create a new private git repo and run the following in your project folder

```
match init
```

You'll be asked to enter the URL to your git repo. This can be either a `https://` or a `git://` URL. `match init` won't read or modify your certificates or profiles.

This will create a `Matchfile` in your current directory (or in your `./fastlane/` folder). Example content:
```ruby
git_url "https://github.com/fastlane/certificates"

app_identifier "tools.fastlane.app" 
username "user@fastlane.tools"
```

### Run

Before running `match` the first time, you should consider clearing your existing profiles and certificates using the [match nuke command](#nuke).

After running `match init` you can run the following to generate new certificates and profiles:

```
match appstore
```
```
match development
```

This will create a new certificate and provisioning profile (if required) and store them in your git repo. If you previously ran `match` it will automatically install the existing profiles from the git repo.

For a list of all available options run

```
match --help
```

#### fastlane

Add `match` to your `Fastfile` (part of [fastlane](https://fastlane.tools))

```ruby
match(type: "appstore")

match(git_url: "https://github.com/fastlane/certificates", 
      type: "development")

match(git_url: "https://github.com/fastlane/certificates", 
      type: "adhoc", 
      app_identifier: "tools.fastlane.app")

# `match` should be called before building the app
gym
...
```

### Setup Xcode project

To make sure Xcode is using the right provisioning profile for each target, don't use the `Automatic` feature for the profile selection.

`match` automatically pre-fills environment variables with the UUIDs of the correct provisioning profiles, ready to be used in your Xcode project. 

<img src="assets/UDIDPrint.png" width="700" />

Open your target settings, open the dropdown for `Provisioning Profile` and select `Other`:

```
$(sigh_tools.fastlane.app_development)
```

<img src="assets/XcodeProjectSettings.png" width="700" />

Additionally it is recommended to disable the `Fix Issue` button using the [FixCode Xcode Plugin](https://github.com/neonichu/FixCode).

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

If you never really cared about code signing and have a messy Apple Developer account with a lot of invalid, expired or Xcode managed profiles/certificates, you can use the `match nuke` command.

To revoke all certificates and provisioning profiles for a specific environment.

```sh
match nuke development
match nuke adhoc
match nuke appstore
```

You'll have to confirm a list of profiles / certificates that will be deleted.

# Need help?
Please submit an issue on GitHub and provide information about your setup

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
