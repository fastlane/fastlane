<h3 align="center">
  <a href="https://github.com/fastlane/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>


fastfix
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastfix/blob/master/LICENSE)

### The Issue

To deploy an app to the App Store or beta testing service, the developer needs to sign the app. Most teams have separate code signing identities for every single developer in the team, resulting in dozens of profiles and a lot of duplicates.
If the team decides to use one code signing identity across the whole team, there is no way to sync the profiles and keys between the various machines. You have to manually export them using Xcode and transfer them between the Macs every time you change something. 

### The Solution

Store the certificates and profiles in a separate git repo. Have one code signing identity for the whole team. When running fastlane it will automatically fetch the latest certificates from the remote git repo and install it on the local machine. If some profile is missing, fastlane will automatically generate them for the user.

### The Goal

It is a declarative approach: the user doesn’t have to know how code signing works. The user shouldn’t have to think about the underlying technology and certificates. All the user cares about is to sign the application.
fastlane automatically pre-fills environment variables to enable proper code signing with multiple targets (e.g. WatchKit)

### How does it work (seen from the user)

```ruby
  setup_codesigning(git_url: "https://github.com/fastlane/certificates", type: :development)
  setup_codesigning(git_url: "https://github.com/fastlane/certificates", type: :adhoc, app_identifier: "tools.fastlane.app")
```

The user specifies 3 things only:
- The Git Repo to store the certificates in (optional, by default this would store the profiles in the same repo as the app itself)
- The type of the profile (App Store, Ad Hoc, Development or Enterprise)
- The app’s bundle identifier


### Result

See the attached screenshot: the repo contains all required certificates and profiles to sign the application.

Using this technique **we solved code signing**! It’s going to be huge!

# Need help?
Please submit an issue on GitHub and provide information about your setup

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
