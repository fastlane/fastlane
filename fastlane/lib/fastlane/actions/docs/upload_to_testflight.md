<p align="center">
  <img src="/img/actions/PilotTextTransparentSmall.png" width="500">
</p>

###### The best way to manage your TestFlight testers and builds from your terminal

Pilot makes it easier to manage your app on Apple’s TestFlight. You can:

- Upload & distribute builds
- Add & remove testers
- Retrieve information about testers & devices
- Import/export all available testers

_pilot_ uses [spaceship.airforce](https://spaceship.airforce) to interact with iTunes Connect 🚀

-------

<p align="center">
    <a href="#usage">Usage</a> &bull;
    <a href="#tips">Tips</a>
</p>

-------

<h5 align="center"><code>pilot</code> is part of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate beta deployments and releases for your iOS and Android apps.</h5>

# Usage

For all commands you can specify the Apple ID to use using `-u felix@krausefx.com`. If you execute _pilot_ in a project already using [_fastlane_](https://fastlane.tools) the username and app identifier will automatically be determined.

## Uploading builds

To upload a new build, just run

```no-highlight
fastlane pilot upload
```

This will automatically look for an `ipa` in your current directory and tries to fetch the login credentials from your [fastlane setup](https://fastlane.tools).

You'll be asked for any missing information. Additionally, you can pass all kinds of parameters:

```no-highlight
fastlane action pilot
```

You can pass a changelog using

```no-highlight
fastlane pilot upload --changelog "Something that is new here"
```

You can also skip the submission of the binary, which means, the `ipa` file will only be uploaded and not distributed to testers:

```no-highlight
fastlane pilot upload --skip_submission
```

_pilot_ does all kinds of magic for you:

- Automatically detects the bundle identifier from your `ipa` file
- Automatically fetch the AppID of your app based on the bundle identifier

_pilot_ uses [_spaceship_](https://spaceship.airforce) to submit the build metadata and the iTunes Transporter to upload the binary. Because iTunes Transporter's upload capability is only supported on OS X, `pilot upload` does not work on Linux, as described [in this issue](https://github.com/fastlane/fastlane/issues/5789)

## List builds

To list all builds for specific application use

```no-highlight
fastlane pilot builds
```

The result lists all active builds and processing builds:

```no-highlight
+-----------+---------+----------+
|      Great App Builds          |
+-----------+---------+----------+
| Version # | Build # | Installs |
+-----------+---------+----------+
| 0.9.13    | 1       | 0        |
| 0.9.13    | 2       | 0        |
| 0.9.20    | 3       | 0        |
| 0.9.20    | 4       | 3        |
+-----------+---------+----------+
```

## Managing beta testers

### List of Testers

This command will list all your testers, both internal and external.

```no-highlight
fastlane pilot list
```

The output will look like this:

```no-highlight
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

```no-highlight
fastlane pilot add email@invite.com
```

Additionally you can specify the app identifier (if necessary):

```no-highlight
fastlane pilot add email@email.com -a com.krausefx.app
```

### Find a tester

To find a specific tester use

```no-highlight
fastlane pilot find felix@krausefx.com
```

The resulting output will look like this:

```no-highlight
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

```no-highlight
fastlane pilot remove felix@krausefx.com
```

### Export testers

To export all external testers to a CSV file. Useful if you need to import tester info to another system or a new account.

```no-highlight
fastlane pilot export
```

### Import testers

Add external testers from a CSV file. Sample CSV file available [here](https://itunesconnect.apple.com/itc/docs/tester_import.csv).

```no-highlight
fastlane pilot import
```

You can also specify the directory using

```no-highlight
fastlane pilot export -c ~/Desktop/testers.csv
fastlane pilot import -c ~/Desktop/testers.csv
```

# Tips

## Debug information

If you run into any issues you can use the `verbose` mode to get a more detailed output:

    fastlane pilot upload --verbose

## Firewall Issues

_pilot_ uses the iTunes Transporter to upload metadata and binaries. In case you are behind a firewall, you can specify a different transporter protocol from the command line using

```no-highlight
DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS="-t DAV" pilot ...
```

If you are using _pilot_ via the [fastlane action](https://docs.fastlane.tools/actions#pilot), add the following to your `Fastfile`

```no-highlight
ENV["DELIVER_ITMSTRANSPORTER_ADDITIONAL_UPLOAD_PARAMETERS"] = "-t DAV"
pilot...
```

## Credentials Issues

If your password contains special characters, _pilot_ may throw a confusing error saying your "Your Apple ID or password was entered incorrectly". The easiest way to fix this error is to change your password to something that **does not** contains special characters.

## How is my password stored?

_pilot_ uses the [CredentialsManager](https://github.com/fastlane/fastlane/tree/master/credentials_manager) from _fastlane_.
