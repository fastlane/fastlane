<h3 align="center">
  <a href="https://github.com/fastlane/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/deliver">deliver</a> &bull; 
  <b>chiizu</b> &bull; 
  <a href="https://github.com/fastlane/frameit">frameit</a> &bull; 
  <a href="https://github.com/fastlane/pem">pem</a> &bull; 
  <a href="https://github.com/fastlane/sigh">sigh</a> &bull; 
  <a href="https://github.com/fastlane/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a> &bull;
  <a href="https://github.com/fastlane/scan">scan</a> &bull;
  <a href="https://github.com/fastlane/match">match</a>
</p>
-------

<p align="center">
  <img src="assets/chiizu.png" height="110">
</p>

chiizu
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/chiizu/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/chiizu.svg?style=flat)](http://rubygems.org/gems/chiizu)

### Automates screenshots of your Android app

Chiizu is a commandline tool that automates taking localized screenshots of your Android app. 

[insert gif of commandline output && emulator running tests)]

Get in contact with us on Twitter: [@FastlaneTools](https://twitter.com/FastlaneTools)

-------
<p align="center">
    <a href="#features">Features</a> &bull; 
    <a href="#installation">Installation</a> &bull; 
    <a href="#ui-tests">UI Tests</a> &bull; 
    <a href="#quick-start">Quick Start</a> &bull; 
    <a href="#usage">Usage</a> &bull; 
    <a href="#tips">Tips</a> &bull; 
    <a href="#how-does-it-work">How?</a> &bull; 
    <a href="#need-help">Need help?</a>
</p>

-------

<h5 align="center"><code>chiizu</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

### Why should I automate this process?
- Create hundreds of screenshots in multiple languages on emulators or real devices, saving you hours
- Easily verify that localizations fit into labels on all screen dimensions to find UI mistakes before you ship
- You only need to configure it once for anyone on your team to run it
- Keep your screenshots perfectly up-to-date with every app update. Your customers deserve it!
- Fully integrates with [`fastlane`](https://fastlane.tools) and [`supply`](https://github.com/fastlane/supply)

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# [ALPHA] Installation

Once this tool is officially released, the installation will be as simple as running `gem install chiizu`, and referencing a published Android AAR. For the private alpha, please follow these testing instructions:

##### Command line tool installation 
1. Clone the repo with `git clone git@github.com:fastlane/chiizu.git`
1. `cd` into your chiizu repo directory and run `rake install`
  - You may need to `gem install bundler` if you don't already have bundler
  - If you're using the default Ruby on Mac OS you may need to use `sudo`
1. Run `chiizu init` to complete installation

##### Java library installation
Import the Chiizu library AAR into your Android Studio project
  1. Right click on your root project and select New > Module
<p align="center">
  <img src="assets/new-module.png" height="450">
</p>
  1. Select **Import .JAR/.AAR Package** from the New Module dialog
<p align="center">
  <img src="assets/import-dialog.png" height="450">
</p>
  1. Pick `[path_to_chiizu_repo]/chiizu-lib-release/chiizu-lib-release.aar` and click **Finish**
  1. Add `androidTestCompile project(':chiizu-lib-release')` to your app's **build.gradle** dependencies

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
2.  To capture screenshots, add the following to your tests `Lens.screenshot(activity, "name_of_screenshot_here");` on the appropriate screens

# Generating Screenshots with Chiizu
- Then, before running `chiizu` you'll need a debug and test apk
  - You can create your APKs with `./gradlew assembleDebug assembleAndroidTest`
- Once complete run `chiizu` in your app project directory to generate screenshots
    - You will be prompted to provide any required parameters which are not in your **Chiizufile** or provided as command line arguments
- Your screenshots will be saved in a /screenshots directory in the directory where you ran `chiizu`     

## Advanced Chiizufile Configuration

Running `chiizu init` generated a Chiizufile which can store all of your configuration options. Since most values will not change often for your project, it is recommended to store them there. 

The `Chiizufile` is written in Ruby, so you may find it helpful to use an editor that highlights Ruby syntax to modify this file.

```ruby
# remove the leading '#' to uncomment lines

# app_package_name 'your.app.package'
# use_tests_in_packages ['your.screenshot.tests.package']

# app_apk_path 'path/to/your/app.apk'
# tests_apk_path 'path/to/your/tests.apk'

locales ['en-US', 'fr-FR', 'it-IT']

# clear all previously generated screenshots in your local output directory before creating new ones
clear_previous_screenshots
```

For more information about all available options run

```
chiizu --help
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
        Lens.screenshot(activityRule.getActivity(), "before_button_click");

        onView(withId(R.id.fab)).perform(click());

        Lens.screenshot(activityRule.getActivity(), "after_button_click");
    }
}

```
There is an [example project](https://github.com/fastlane/screengrab/tree/master/example/src/androidTest/java/io/fabric/localetester) showing how to use use JUnit 3 or 4 and Espresso with the chiizu Java library to capture screenshots during a UI test run.

Using JUnit 4 is preferable because of its ability to perform actions before and after the entire test class is run. This means you will change the device's locale far fewer times when compared with JUnit 3 running those commands before and after each test method.

When using JUnit 3 you'll need to add a bit more code:
- Use `LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getTestLocale());` in `setUp()`
- Use `LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getEndingLocale());` in `tearDown()`
- Use `Lens.screenshot(activity, "name_of_screenshot_here");` to capture screenshots at the appropriate points in your tests

If you're having trouble getting your device unlocked and the screen activated to run tests, try using `ScreenUtil.activateScreenForTesting(activity);` in your test setup. 

## [`fastlane`](https://fastlane.tools) Toolchain

- [`fastlane`](https://fastlane.tools): Connect all deployment tools into one streamlined workflow
- [`supply`](https://github.com/fastlane/supply): Upload screenshots, metadata and your app to the Play Store
- [`frameit`](https://github.com/fastlane/frameit): Quickly put your screenshots into the right device frames

##### [Like this tool? Be the first to know about updates and new fastlane tools](https://tinyletter.com/krausefx)

# Need help?
Please submit an issue on GitHub and provide information about your setup.

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
