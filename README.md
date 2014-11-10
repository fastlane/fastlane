<p align="center">
    <img src="assets/snapshot.png">
</p>

Snapshot - Create hundreds of iOS app screenshots
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
<!-- [![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/deliver/blob/develop/LICENSE)
[![Gem](https://img.shields.io/gem/v/deliver.svg?style=flat)](http://rubygems.org/gems/deliver)
[![Build Status](https://img.shields.io/travis/KrauseFx/deliver/master.svg?style=flat)](https://travis-ci.org/KrauseFx/deliver) -->

Taking perfect iOS screenshots is difficult. You usually want them to look the same in **all languages** on **all devices**. 

This easily results in over **300 screenshots** you have to create. 

Uploading them is really easy, using [```deliver```](https://github.com/KrauseFx/deliver).

Follow the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)


-------
[Features](#features) &bull;
[Installation](#installation) &bull;
[Quick Start](#quick-start) &bull;
[Usage](#usage) &bull;
[Tips](#tips) &bull;
[Need help?](#need-help)

-------


# Features
- Create hundreds of screenshots in multiple languages on all simulators
- Configure it once, store the configuration in git
- Do something else, while the computer takes the screenshots for you
- Very easy to integrate with ```deliver```

# Installation

Install the gem

    sudo gem install snapshot

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

# Quick Start


The guide will create all the necessary files for you, using the existing app metadata from iTunes Connect.

- ```cd [your_project_folder]```
- ```snapshot```

Your screenshots will be stored in ```./screenshots/``` by default.

From now on, you can run ```snapshot``` to create new screenshots of your app.


# Usage

Why should you have to remember complicated commands and parameters?

Store your configuration in a text file to easily take screenshots from any computer.

## Snapfile

Create a file called ```Snapfile``` in your project directory.
Once you created your configuration, just run ```snapshot```.

The ```Snapfile``` may contain the following information (all are optional):

### Simulator Types
```ruby
devices([
  "iPhone 6",
  "iPhone 6 Plus",
  "iPhone 5",
  "iPhone 4s"
])
```

### Languages

```ruby
languages([
  "en-US",
  "de-DE",
  "es-ES"
])
```

### Javascript file
Usually ```snapshot``` automatically finds your JavaScript file. If that's not the case, you can pass the path 
to your test file.
```ruby
js_file './path/file.js'
```

### Scheme
To not be asked which scheme to use, just set it like this:
```ruby
scheme "Name"
```

### Screenshots output path
All generated screenshots will be stored in the given path.
```ruby
screenshots_path './screenshots'
```

### Project Path
By default, ```snapshot``` will look for your project in the current directory. If it is located somewhere else, pass your custom path:
```ruby
project_path "./my_project/Project.xcworkspace"
```

### iOS Version
I'll try to keep the script up to date. If you need to change the iOS version, you can do it like this:

```ruby
ios_version "9.0"
```


# Tips
## Available language codes
```ruby
["da-DK", "de-DE", "el-GR", "en-AU", "en-CA", "en-GB", "en-US", "es-ES", "es-MX", "fi-FI", "fr-CA", "fr-FR", "id-ID", "it-IT", "ja-JP", "ko-KR", "ms-MY", "nl-NL", "no-NO", "pt-BR", "pt-PT", "ru-RU", "sv-SE", "th-TH", "tr-TR", "vi-VI", "cmn-Hans", "zh_CN", "cmn-Hant"]
```

## Use a clean status bar
You can use [SimulatorStatusMagic](https://github.com/shinydevelopment/SimulatorStatusMagic) to clean up the status bar.

## Editing the ```Deliverfile```
Change syntax highlighting to *Ruby*.

# Need help?
- If there is a technical problem with ```Snapshot```, submit an issue. Run ```snapshot --trace``` to get the stacktrace.
- I'm available for contract work - drop me an email: snapshot@felixkrause.at

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/KrauseFx/snapshot/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
