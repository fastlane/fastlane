# _fastlane_’s Philosophy

_fastlane_ automates the beta and release deployment process for your iOS or Android apps, including build, code signing, automatic screenshot capture, and distribution of your app binaries.

_fastlane_ will continue to evolve in ways that make it indispensable for, and focused on these needs.

_fastlane_ aims to be elegant in success, and empathetic in failure.

_fastlane_ provides intelligent defaults for options, prompts for missing information, and a context that automatically shares relevant information between actions. All of this allows a simple, elegant Fastfile to do a lot of powerful work.

Since errors are inevitable, _fastlane_ should show empathy and provide a suggested solution, or attempt to solve the problem automatically. Errors that can be anticipated should not crash _fastlane_, and should present users with a friendly message that is easy to spot in their terminal or logs.

## Actions and Plugins

_fastlane_ saw a lot of early growth through a wide number of actions that meet a variety of needs. Actions can trigger built-in _fastlane_ tools, talk to external tools and services, and more. However, with more than 170 built-in actions, further growth here will make _fastlane_ harder to understand and get started with. Another consideration is that actions which ship with _fastlane_ represent a maintenance cost for the _fastlane_ core team.

With these challenges in mind, [_fastlane_ plugin system](https://fabric.io/blog/introducing-fastlane-plugins/) allows anyone to develop, share, and use new actions built and maintained by the awesome _fastlane_ community. If you have an idea for a new _fastlane_ action, [create it as a plugin](https://docs.fastlane.tools/plugins/create-plugin/) and it’ll be automatically listed in the [_fastlane_ plugin registry](https://docs.fastlane.tools/plugins/available-plugins). The most impactful and commonly used plugins could be adopted into _fastlane_ in the future.

## _fastlane_ Tool Responsibilities

Each _fastlane_ tool has a specific purpose and should be kept focused on the functionality required for that task.

* [deliver](https://github.com/fastlane/fastlane/tree/master/deliver): Upload screenshots, metadata, and your app binary to the App Store
* [supply](https://github.com/fastlane/fastlane/tree/master/supply): Upload your Android app and its metadata to Google Play
* [snapshot](https://github.com/fastlane/fastlane/tree/master/snapshot): Automate taking localized screenshots of your iOS apps on every device
* [screengrab](https://github.com/fastlane/fastlane/tree/master/screengrab): Automate taking localized screenshots of your Android app on every device
* [frameit](https://github.com/fastlane/fastlane/tree/master/frameit): Quickly put your screenshots into the right device frames
* [pem](https://github.com/fastlane/fastlane/tree/master/pem): Automatically generate and renew your push notification certificates
* [sigh](https://github.com/fastlane/fastlane/tree/master/sigh): Because you would rather spend your time building stuff than fighting provisioning
* [produce](https://github.com/fastlane/fastlane/tree/master/produce): Create new iOS apps on iTunes Connect and Apple Developer Portal using the command line
* [cert](https://github.com/fastlane/fastlane/tree/master/cert): Automatically create and maintain iOS code signing certificates
* [spaceship](https://github.com/fastlane/fastlane/tree/master/spaceship): Ruby library to access the Apple Developer Portal and iTunes Connect
* [pilot](https://github.com/fastlane/fastlane/tree/master/pilot): The best way to manage your TestFlight testers and builds from your terminal
* [boarding](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers
* [gym](https://github.com/fastlane/fastlane/tree/master/gym): Building your iOS apps has never been easier
* [match](https://github.com/fastlane/fastlane/tree/master/match): Easily sync your certificates and profiles across your team using Git
* [scan](https://github.com/fastlane/fastlane/tree/master/scan): The easiest way to run tests for your iOS and Mac apps
* [precheck](https://github.com/fastlane/fastlane/tree/master/precheck): Check your app using a community driven set of App Store review rules to avoid being rejected

## _fastlane_’s Relationship with [Google](https://google.com)

Google supports app development teams with the best tools for building, understanding, and growing their mobile app businesses through [Firebase](https://firebase.google.com] and [Fabric](https://get.fabric.io/).

Google has recognized _fastlane_ as the best tool for tackling tough beta and release deployment challenges. The team’s mission is to make _fastlane_ the de facto tool to automate beta deployments and app store releases for iOS and Android apps.

Google intends to keep _fastlane_ open source and available as a standalone tool for users who are not using Firebase or Fabric. Google is also committed to increasing use of _fastlane_ by promoting it through other products and websites, and developing integrations with Firebase and Fabric tools to help them work better together.
