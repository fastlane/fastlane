<h3 align="center">
  <a href="https://github.com/fastlane/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/deliver">deliver</a> &bull; 
  <a href="https://github.com/fastlane/snapshot">snapshot</a> &bull; 
  <a href="https://github.com/fastlane/frameit">frameit</a> &bull; 
  <a href="https://github.com/fastlane/pem">pem</a> &bull; 
  <a href="https://github.com/fastlane/sigh">sigh</a> &bull; 
  <a href="https://github.com/fastlane/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <b>pilot</b> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/scan">scan</a> &bull;
  <a href="https://github.com/fastlane/match">match</a>
</p>
-------

<p align="center">
  <img src="assets/PilotTextTransparentSmall.png" width="500">
</p>

Pilot
============
[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/pilot/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/pilot.svg?style=flat)](http://rubygems.org/gems/pilot)


###### The best way to manage your TestFlight testers and builds from your terminal

This tool allows you to manage all important features of Apple TestFlight using your terminal.

- Upload new builds and distribute them to all testers
- List all available builds
- Add and remove beta testers
- Get information about testers, like the registered devices
- Export and import all your testers

Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)

`pilot` uses [spaceship.airforce](https://spaceship.airforce) to interact with iTunes Connect :rocket:

-------
<p align="center">
    <a href="#installation">Installation</a> &bull; 
    <a href="#usage">Usage</a> &bull; 
    <a href="#tips">Tips</a> &bull; 
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>pilot</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

# Installation

    sudo gem install pilot

# Usage

For all commands you can specify the Apple ID to use using `-u felix@krausefx.com`. If you execute `pilot` in a project already using [fastlane](https://fastlane.tools) the username and app identifier will automatically be determined.

## Uploading builds

To upload a new build, just run 

```
pilot upload
```

This will automatically look for an `ipa` in your current directory and tries to fetch the login credentials from your [fastlane setup](https://fastlane.tools).

You'll be asked for any missing information. Additionally, you can pass all kinds of parameters:

```
pilot --help
```

You can pass a changelog using

```
pilot upload --changelog "Something that is new here"
```

You can also skip the submission of the binary, which means, the `ipa` file will only be uploaded and not distributed to testers:

```
pilot upload --skip_submission
```

`pilot` does all kinds of magic for you:

- Automatically detects the bundle identifier from your `ipa` file
- Automatically fetch the AppID of your app based on the bundle identifier

`pilot` uses [spaceship](https://spaceship.airforce) to submit the build metadata and the iTunes Transporter to upload the binary.

## List builds

To list all builds for specific application use

```
pilot builds
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
pilot list
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

To add a new tester to both your iTunes Connect account and to your app (if given), use the `pilot add` command. This will create a new tester (if necesssary) or add an existing tester to the app to test.

```
pilot add email@invite.com
```

Additionally you can specify the app identifier (if necessary): 

```
pilot add email@email.com -a com.krausefx.app
```

### Find a tester

To find a specific tester use

```
pilot find felix@krausefx.com
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
pilot remove felix@krausefx.com
```

### Export testers

To export all external testers to a CSV file. Useful if you need to import tester info to another system or a new account.

```
pilot export
```

### Import testers

Add external testers from a CSV file. Sample CSV file available [here](https://itunesconnect.apple.com/itc/docs/tester_import.csv).

```
pilot import
```

You can also specify the directory using

```
pilot export -c ~/Desktop/testers.csv
pilot import -c ~/Desktop/testers.csv
 ```

# Tips

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`deliver`](https://github.com/fastlane/deliver): Upload screenshots, metadata and your app to the App Store
- [`snapshot`](https://github.com/fastlane/snapshot): Automate taking localized screenshots of your iOS app on every device
- [`frameit`](https://github.com/fastlane/frameit): Quickly put your screenshots into the right device frames
- [`produce`](https://github.com/fastlane/produce): Create new iOS apps on iTunes Connect and Dev Portal using the command line
- [`pem`](https://github.com/fastlane/pem): Automatically generate and renew your push notification profiles
- [`sigh`](https://github.com/fastlane/sigh): Because you would rather spend your time building stuff than fighting provisioning
- [`cert`](https://github.com/fastlane/cert): Automatically create and maintain iOS code signing certificates
- [`spaceship`](https://github.com/fastlane/spaceship): Ruby library to access the Apple Dev Center and iTunes Connect
- [`boarding`](https://github.com/fastlane/boarding): The easiest way to invite your TestFlight beta testers
- [`gym`](https://github.com/fastlane/gym): Building your iOS apps has never been easier
- [`scan`](https://github.com/fastlane/scan): The easiest way to run tests of your iOS and Mac app
- [`match`](https://github.com/fastlane/match): Easily sync your certificates and profiles across your team using git

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

## Debug information

If you run into any issues you can use the `verbose` mode to get a more detailed output:

    pilot --verbose

## Firewall Issues

`pilot` uses the iTunes Transporter to upload metadata and binaries. In case you are behind a firewall, you can specify a different transporter protocol from the command line using

```
DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS="-t DAV" pilot ...
```

If you are using `pilot` via the [fastlane action](https://github.com/fastlane/fastlane/blob/master/docs/Actions.md#pilot), add the following to your `Fastfile`

```
ENV["DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS"] = "-t DAV"
pilot...
```

## How is my password stored?

`pilot` uses the [CredentialsManager](https://github.com/fastlane/credentials_manager) from `fastlane`.

# Need help?
Please submit an issue on GitHub and provide information about your setup

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
