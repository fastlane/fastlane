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
  <b>pilot</b> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/scan">scan</a> &bull;
  <a href="https://github.com/fastlane/fastlane/tree/master/match">match</a>
</p>
-------

<p align="center">
  <img src="assets/PilotTextTransparentSmall.png" width="500">
</p>

Pilot
============
[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/pilot/LICENSE)
[![Gem](https://img.shields.io/gem/v/pilot.svg?style=flat)](https://rubygems.org/gems/pilot)


###### The best way to manage your TestFlight testers and builds from your terminal

Pilot makes it easier to manage your app on Apple’s TestFlight. You can:

- Upload & distribute builds
- Add & remove testers
- Retrieve information about testers & devices
- Import/export all available testers

Get in contact with the developer on Twitter: [@FastlaneTools](https://twitter.com/FastlaneTools)

`pilot` uses [spaceship.airforce](https://spaceship.airforce) to interact with iTunes Connect :rocket:

-------
<p align="center">
    <a href="#installation">Installation</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#tips">Tips</a> &bull;
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>pilot</code> is part of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate beta deployments and releases for your iOS and Android apps.</h5>

# Installation

    sudo gem install fastlane

# Usage

For all commands you can specify the Apple ID to use using `-u felix@krausefx.com`. If you execute `pilot` in a project already using [fastlane](https://fastlane.tools) the username and app identifier will automatically be determined.

## Uploading builds

To upload a new build, just run

```
fastlane pilot upload
```

This will automatically look for an `ipa` in your current directory and tries to fetch the login credentials from your [fastlane setup](https://fastlane.tools).

You'll be asked for any missing information. Additionally, you can pass all kinds of parameters:

```
fastlane pilot --help
```

You can pass a changelog using

```
fastlane pilot upload --changelog "Something that is new here"
```

You can also skip the submission of the binary, which means, the `ipa` file will only be uploaded and not distributed to testers:

```
fastlane pilot upload --skip_submission
```

`pilot` does all kinds of magic for you:

- Automatically detects the bundle identifier from your `ipa` file
- Automatically fetch the AppID of your app based on the bundle identifier

`pilot` uses [spaceship](https://spaceship.airforce) to submit the build metadata and the iTunes Transporter to upload the binary.

## List builds

To list all builds for specific application use

```
fastlane pilot builds
```

The result lists all active builds and processing builds:

```
+-----------+---------+----------+----------+----------+
|                   Great App Builds                   |
+-----------+---------+----------+----------+----------+
| Version # | Build # | Testing  | Installs | Sessions |
+-----------+---------+----------+----------+----------+
| 0.9.13    | 1       | Expired  | 1        | 0        |
| 0.9.13    | 2       | Expired  | 0        | 0        |
| 0.9.20    | 3       | Expired  | 0        | 0        |
| 0.9.20    | 4       | Internal | 5        | 3        |
+-----------+---------+----------+----------+----------+
```

## Managing beta testers

### List of Testers

This command will list all your testers, both internal and external.

```
fastlane pilot list
```

The output will look like this:

```
+--------+--------+--------------------------+-----------+
|                    Internal Testers                    |
+--------+--------+--------------------------+-----------+
| First  | Last   | Email                    | # Devices |
+--------+--------+--------------------------+-----------+
| Felix  | Krause | felix@krausefx.com       | 2         |
+--------+--------+--------------------------+-----------+

+-----------+---------+----------------------------+-----------+
|                       External Testers                       |
+-----------+---------+----------------------------+-----------+
| First     | Last    | Email                      | # Devices |
+-----------+---------+----------------------------+-----------+
| Max       | Manfred | email@email.com            | 0         |
| Detlef    | Müller  | detlef@krausefx.com        | 1         |
+-----------+---------+----------------------------+-----------+
```

### Add a new tester

To add a new tester to both your iTunes Connect account and to your app (if given), use the `pilot add` command. This will create a new tester (if necessary) or add an existing tester to the app to test.

```
fastlane pilot add email@invite.com
```

Additionally you can specify the app identifier (if necessary):

```
fastlane pilot add email@email.com -a com.krausefx.app
```

### Find a tester

To find a specific tester use

```
fastlane pilot find felix@krausefx.com
```

The resulting output will look like this:

```
+---------------------+---------------------+
|            felix@krausefx.com             |
+---------------------+---------------------+
| First name          | Felix               |
| Last name           | Krause              |
| Email               | felix@krausefx.com  |
| Latest Version      | 0.9.14 (23          |
| Latest Install Date | 03/28/15 19:00      |
| 2 Devices           | • iPhone 6, iOS 8.3 |
|                     | • iPhone 5, iOS 7.0 |
+---------------------+---------------------+
```

### Remove a tester

This command will only remove external beta testers.

```
fastlane pilot remove felix@krausefx.com
```

### Export testers

To export all external testers to a CSV file. Useful if you need to import tester info to another system or a new account.

```
fastlane pilot export
```

### Import testers

Add external testers from a CSV file. Sample CSV file available [here](https://itunesconnect.apple.com/itc/docs/tester_import.csv).

```
fastlane pilot import
```

You can also specify the directory using

```
fastlane pilot export -c ~/Desktop/testers.csv
fastlane pilot import -c ~/Desktop/testers.csv
 ```

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): The easiest way to automate beta deployments and releases for your iOS and Android apps
- [`deliver`](https://github.com/fastlane/fastlane/tree/master/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/fastlane/fastlane/tree/master/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/fastlane/fastlane/tree/master/frameit): Quickly put your screenshots into the right device frames
- [`produce`](https://github.com/fastlane/fastlane/tree/master/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`pem`](https://github.com/fastlane/fastlane/tree/master/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/fastlane/fastlane/tree/master/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`cert`](https://github.com/fastlane/fastlane/tree/master/cert): Automatically create and maintain iOS code signing certificates
- [`spaceship`](https://github.com/fastlane/fastlane/tree/master/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers
- [`gym`](https://github.com/fastlane/fastlane/tree/master/gym): Building your iOS apps has never been easier
- [`scan`](https://github.com/fastlane/fastlane/tree/master/scan): The easiest way to run tests of your iOS and Mac app
- [`match`](https://github.com/fastlane/fastlane/tree/master/match): Easily sync your certificates and profiles across your team using git

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Debug information

If you run into any issues you can use the `verbose` mode to get a more detailed output:

    fastlane pilot upload --verbose

## Firewall Issues

`pilot` uses the iTunes Transporter to upload metadata and binaries. In case you are behind a firewall, you can specify a different transporter protocol from the command line using

```
DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS="-t DAV" pilot ...
```

If you are using `pilot` via the [fastlane action](https://docs.fastlane.tools/actions#pilot), add the following to your `Fastfile`

```
ENV["DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS"] = "-t DAV"
pilot...
```

## Credentials Issues

If your password contains special characters, `pilot` may throw a confusing error saying your "Your Apple ID or password was entered incorrectly". The easiest way to fix this error is to change your password to something that **does not** contains special characters.

## How is my password stored?

`pilot` uses the [CredentialsManager](https://github.com/fastlane/fastlane/tree/master/credentials_manager) from `fastlane`.

# Need help?
Please submit an issue on GitHub and provide information about your setup

# Code of Conduct
Help us keep `pilot` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
