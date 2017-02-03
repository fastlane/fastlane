<h3 align="center">
  <img src="fastlane/assets/fastlane_text.png" alt="fastlane Logo" />
</h3>

fastlane
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/fastlane.svg?style=flat)](https://rubygems.org/gems/fastlane)
[![Build Status](https://img.shields.io/circleci/project/fastlane/fastlane/master.svg?style=flat)](https://circleci.com/gh/fastlane/fastlane)

#### ✨ Check out [docs.fastlane.tools](https://docs.fastlane.tools) on how to get started with fastlane ✨

`fastlane` is a tool for iOS, Mac, and Android developers to automate tedious tasks like generating screenshots, dealing with provisioning profiles, and releasing your application.

Use a lane to define your process:

```ruby
lane :beta do
  increment_build_number
  cocoapods
  match
  testflight
  sh "./customScript.sh"
  slack
end
```

Then to deploy a new 'beta' version of your app just run
`fastlane beta` :rocket:

              |  fastlane
--------------------------|------------------------------------------------------------
:sparkles: | Connect iOS, Mac, and Android build tools into one workflow (both _fastlane_ tools and third party tools)
:monorail: | Define different `deployment lanes` for App Store deployment, beta builds, or testing
:ship: | Deploy from any computer, including a CI server
:wrench: | Extend and customise functionality
:thought_balloon: | Never remember any difficult commands, just `fastlane`
:tophat: | Easy setup assistant to get started in a few minutes
:email: | Automatically pass on information from one build step to another (*e.g.* path to the `ipa` file)
:page_with_curl: | Store **everything** in Git. Never lookup build commands in `Jenkins` configs again.
:rocket: | Saves you **hours** for every app update you release
:pencil2: | Flexible configuration using a fully customisable `Fastfile`
:mountain_cableway: | Implement a fully working Continuous Delivery process
:ghost: | [Jenkins Integration](https://docs.fastlane.tools/best-practices/continuous-integration/#jenkins-integration): Show output directly in test results
:book: | Automatically generate Markdown documentation of your lane configurations
:hatching_chick: | Over 170 built-in integrations available
:computer: | Support for iOS, macOS, and Android apps
:octocat: | Full Git and Mercurial support

<hr />
<h4 align="center">
  Check out the new <a href="https://docs.fastlane.tools/">fastlane docs</a>
</h4>
<hr />

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

## Quick Start

Get started distributing your first app with fastlane within minutes:

[Create your first Fastfile](https://fabric.io/features/distribution?utm_campaign=github_readme)

Want to learn more? Explore guides for [iOS](https://docs.fastlane.tools/getting-started/ios/setup/)
 or [Android](https://docs.fastlane.tools/getting-started/android/setup/).

## Available Commands

Typically you'll use `fastlane` by triggering individual lanes:

    fastlane [lane_name]

#### Other Commands

- `fastlane actions`: List all available `fastlane` actions
- `fastlane action [action_name]`: Shows a more detailed description of an action
- `fastlane lanes`: Lists all available lanes with description
- `fastlane list`: Lists all available lanes without description
- `fastlane new_action`: Create a new action *(integration)* for fastlane
- `fastlane env`: Print out the fastlane ruby environment when submitting an issue


If you'd like to take a look at a project already using `fastlane` check out [fastlane-examples](https://github.com/fastlane/examples) which includes `fastlane` setups by Wikipedia, Product Hunt, MindNode, and more.

<hr />
<h4 align="center">
  Check out the new <a href="https://docs.fastlane.tools/">fastlane docs</a>
</h4>
<hr />

## [`fastlane`](https://fastlane.tools) Toolchain

In addition to `fastlane`'s commands, you also have access to these `fastlane` tools:

- [`deliver`](https://github.com/fastlane/fastlane/tree/master/deliver): Upload screenshots, metadata, and your app to the App Store
- [`supply`](https://github.com/fastlane/fastlane/tree/master/supply): Upload your Android app and its metadata to Google Play
- [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot): Automate taking localized screenshots of your iOS and tvOS apps on every device
- [`screengrab`](https://github.com/fastlane/fastlane/tree/master/screengrab): Automate taking localized screenshots of your Android app on every device
- [`frameit`](https://github.com/fastlane/fastlane/tree/master/frameit): Quickly put your screenshots into the right device frames
- [`pem`](https://github.com/fastlane/fastlane/tree/master/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/fastlane/fastlane/tree/master/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`produce`](https://github.com/fastlane/fastlane/tree/master/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`cert`](https://github.com/fastlane/fastlane/tree/master/cert): Automatically create and maintain iOS code signing certificates
- [`spaceship`](https://github.com/fastlane/fastlane/tree/master/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`pilot`](https://github.com/fastlane/fastlane/tree/master/pilot): The best way to manage your TestFlight testers and builds from your terminal
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers
- [`gym`](https://github.com/fastlane/fastlane/tree/master/gym): Building your iOS apps has never been easier
- [`match`](https://github.com/fastlane/fastlane/tree/master/match): Easily sync your certificates and profiles across your team using Git
- [`scan`](https://github.com/fastlane/fastlane/tree/master/scan): The easiest way to run tests for your iOS and Mac apps

## Need Help?

Please [submit an issue](https://github.com/fastlane/fastlane/issues) on GitHub and provide information about your setup.

## Special Thanks

Thanks to all [contributors](https://github.com/fastlane/fastlane/graphs/contributors) for extending and improving `fastlane`.

## Speakers

Are you giving a talk on fastlane? Great! [Let us know](https://fastlane.tools/speaking) so we can help you give the best possible presentation. 

## Code of Conduct

Help us keep `fastlane` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file.

> This project and all fastlane tools are in no way affiliated with Apple Inc or Google. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
