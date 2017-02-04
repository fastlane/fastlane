<h3 align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/fastlane">
    <img src="../fastlane/assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/fastlane/tree/master/deliver">deliver</a> &bull;
  <b>screengrab</b> &bull;
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
  <a href="https://github.com/fastlane/fastlane/tree/master/match">match</a>
</p>
-------

<p align="center">
  <img src="assets/screengrab.png" height="110">
</p>

screengrab
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/screengrab/LICENSE)
[![Gem](https://img.shields.io/gem/v/screengrab.svg?style=flat)](https://rubygems.org/gems/screengrab)

###### Automated localized screenshots of your Android app on every device

`screengrab` generates localized screenshots of your Android app for different device types and languages for Google Play and can be uploaded using [`supply`](https://github.com/fastlane/fastlane/tree/master/supply).

<img src="assets/running-screengrab.gif" width="640">

### Why should I automate this process?
- Create hundreds of screenshots in multiple languages on emulators or real devices, saving you hours
- Easily verify that localizations fit into labels on all screen dimensions to find UI mistakes before you ship
- You only need to configure it once for anyone on your team to run it
- Keep your screenshots perfectly up-to-date with every app update. Your customers deserve it!
- Fully integrates with [`fastlane`](https://fastlane.tools) and [`supply`](https://github.com/fastlane/fastlane/tree/master/supply)

# Installation
Install the gem

```
sudo gem install fastlane
```

##### Gradle dependency
```java
androidTestCompile 'tools.fastlane:screengrab:x.x.x'
```

The latest version is [ ![Download](https://api.bintray.com/packages/fastlane/fastlane/screengrab/images/download.svg) ](https://bintray.com/fastlane/fastlane/screengrab/_latestVersion)

##### Configuring your Manifest Permissions
Ensure that the following permissions exist in your **src/debug/AndroidManifest.xml**

```xml
<!-- Allows unlocking your device and activating its screen so UI tests can succeed -->
<uses-permission android:name="android.permission.DISABLE_KEYGUARD"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>

<!-- Allows for storing and retrieving screenshots -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- Allows changing locales -->
<uses-permission android:name="android.permission.CHANGE_CONFIGURATION" />
```

##### Configuring your <a href="#ui-tests">UI Tests</a> for Screenshots

1.  Add `@ClassRule public static final LocaleTestRule localeTestRule = new LocaleTestRule();` to your tests class to handle automatic switching of locales
2.  To capture screenshots, add the following to your tests `Screengrab.screenshot("name_of_screenshot_here");` on the appropriate screens

# Generating Screenshots with Screengrab
- Then, before running `screengrab` you'll need a debug and test apk
  - You can create your APKs with `./gradlew assembleDebug assembleAndroidTest`
- Once complete run `screengrab` in your app project directory to generate screenshots
    - You will be prompted to provide any required parameters which are not in your **Screengrabfile** or provided as command line arguments
- Your screenshots will be saved to `fastlane/metadata/android` in the directory where you ran `screengrab`

## Improved screenshot capture with UI Automator

As of `screengrab` 0.5.0, you can specify different strategies to control the way `screengrab` captures screenshots. The newer strategy delegates to [UI Automator](https://developer.android.com/topic/libraries/testing-support-library/index.html#UIAutomator) which fixes a number of problems compared to the original strategy:

* Shadows/elevation are correctly captured for Material UI
* Multi-window situations are correctly captured (dialogs, etc.)
* Works on Android N

However, UI Automator requires a device with **API level >= 18**, so it is not yet the default strategy. To enable it for all screenshots by default, make the following call before your tests run:

```java
Screengrab.setDefaultScreenshotStrategy(new UiAutomatorScreenshotStrategy());
```

## Advanced Screengrabfile Configuration

Running `fastlane screengrab init` generated a Screengrabfile which can store all of your configuration options. Since most values will not change often for your project, it is recommended to store them there.

The `Screengrabfile` is written in Ruby, so you may find it helpful to use an editor that highlights Ruby syntax to modify this file.

```ruby
# remove the leading '#' to uncomment lines

# app_package_name 'your.app.package'
# use_tests_in_packages ['your.screenshot.tests.package']

# app_apk_path 'path/to/your/app.apk'
# tests_apk_path 'path/to/your/tests.apk'

locales ['en-US', 'fr-FR', 'it-IT']

# clear all previously generated screenshots in your local output directory before creating new ones
clear_previous_screenshots true
```

For more information about all available options run

```
fastlane screengrab --help
```

# Tips

# UI Tests

Check out [Testing UI for a Single App](http://developer.android.com/training/testing/ui-testing/espresso-testing.html) for an introduction to using Espresso for UI testing.

##### Example UI Test Class (Using JUnit4)
```java
@RunWith(JUnit4.class)
public class JUnit4StyleTests {
    @ClassRule
    public static final LocaleTestRule localeTestRule = new LocaleTestRule();

    @Rule
    public ActivityTestRule<MainActivity> activityRule = new ActivityTestRule<>(MainActivity.class);

    @Test
    public void testTakeScreenshot() {
        Screengrab.screenshot("before_button_click");

        onView(withId(R.id.fab)).perform(click());

        Screengrab.screenshot("after_button_click");
    }
}

```
There is an [example project](https://github.com/fastlane/fastlane/tree/master/screengrab/example/src/androidTest/java/tools/fastlane/localetester) showing how to use use JUnit 3 or 4 and Espresso with the screengrab Java library to capture screenshots during a UI test run.

Using JUnit 4 is preferable because of its ability to perform actions before and after the entire test class is run. This means you will change the device's locale far fewer times when compared with JUnit 3 running those commands before and after each test method.

When using JUnit 3 you'll need to add a bit more code:

- Use `LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getTestLocale());` in `setUp()`
- Use `LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getEndingLocale());` in `tearDown()`
- Use `Screengrab.screenshot("name_of_screenshot_here");` to capture screenshots at the appropriate points in your tests

If you're having trouble getting your device unlocked and the screen activated to run tests, try using `ScreenUtil.activateScreenForTesting(activity);` in your test setup.

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): The easiest way to automate beta deployments and releases for your iOS and Android apps
- [`supply`](https://github.com/fastlane/fastlane/tree/master/supply): Upload screenshots, metadata and your app to the Play Store

You can find all the tools on [fastlane.tools](https://fastlane.tools).

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Need help?
Please submit an issue on GitHub and provide information about your setup.

## Code of Conduct

Help us keep `screengrab` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
