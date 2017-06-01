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
  <a href="https://github.com/fastlane/fastlane/tree/master/match">match</a> &bull;
  <b>review</b>
</p>

-------

<p align="center">
  <img src="assets/review.png" height="110">
</p>

Review
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/LICENSE)

###### Pass App Store review, the first time

Apple rejects builds for many avoidable metadata issues like including swear words 😮, other companies’ trademarks, or even mentioning an iOS bug 🐛. fastlane review takes a lot of the guess work out by scanning your app’s details in iTunes Connect for avoidable problems. fastlane review helps you get your app through review without rejections so you can ship faster 🚀


Get in contact with the developer on Twitter: [@FastlaneTools](https://twitter.com/FastlaneTools)

-------

<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#example">Example</a> &bull;
    <a href="#how-does-it-work">How does it work?</a> &bull;
    <a href="#tips">Tips</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>review</code> is part of <a href="https://fastlane.tools">fastlane</a>: The best way to ensure your App Store review passes without a hitch </h5>

# Features

- Many scanning rules like improper trademark usage, or iOS bug 🐛 mentions, or even swear word checker 😮
- You can use our pre-selected list of what we would use, or you can customize which rules to check for, so you have to run the rules you care most about.
- Customizable: you can decide if you want to warn 📢 about potential problems and continue or have fastlane show an error 🙅 and stop after all scans are done.
- Paranoid mode if you want to be sure you’re doing all you can to avoid a potential rejection. This is most helpful when you need to get a hotfix out and you don’t want to take any chances it could be rejected.


##### [Do you like fastlane? Be the first to know about updates and new fastlane tools](https://tinyletter.com/fastlane-tools)

# Quick Start

    sudo gem install fastlane

# Usage
Run fastlane review to check the app metadata from iTunes Connect

    fastlane review

To get a list of available options run
    
    fastlane review --help
    
# Example

Each rule can take extra configuration arguments from the fastlane review file.
Here are some examples a list of rules
 
built-in rules:

    spell_checking :skip # indicates that your metadata will not be checked by this rule
    trademarks :warning  # when triggered, this rule will warn you of a potential problem
    private_api :fail    # show error and prevent any further commands from running after fastlane review finishes
 

### Use with [`fastlane`](https://github.com/fastlane/fastlane/tree/master/fastlane)

`review` becomes really interesting when used in [`fastlane`](https://github.com/fastlane/fastlane/tree/master/fastlane) in combination with [`deliver`](https://github.com/fastlane/fastlane/tree/master/deliver).

Update your `Fastfile` to contain the following code:

```ruby
lane :production do
  deliver
  review
end
```

# How does it work?

`review` will access the `iTunes Connect` to download your app's metadata. It uses [spaceship](https://spaceship.airforce) to communicate with Apple's web services.


# Tips
## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): The easiest way to automate beta deployments and releases for your iOS and Android apps
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
- [`scan`](https://github.com/fastlane/fastlane/tree/master/scan): The easiest way to run tests of your iOS and Mac app
- [`match`](https://github.com/fastlane/fastlane/tree/master/match): Easily sync your certificates and profiles across your team using git

##### [Do you like fastlane? Be the first to know about updates and new fastlane tools](https://tinyletter.com/fastlane-tools)

# Need help?
Please submit an issue on GitHub and provide information about your setup

# Want to improve review's rules?
Please submit an issue on GitHub and provide information about your App Store rejection! Make sure you scrub out any personally identifiable information since this will be public.

# Code of Conduct
Help us keep `review` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.


