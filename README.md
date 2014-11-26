<p align="center">
<a href="https://github.com/KrauseFx/deliver">Deliver</a> &bull; 
<a href="https://github.com/KrauseFx/snapshot">Snapshot</a> &bull; 
<a href="https://github.com/KrauseFx/frameit">FrameIt</a> &bull; 
<a href="https://github.com/KrauseFx/PEM">PEM</a> &bull; 
<b>Sign</b>
</p>
-------

<p align="center">
    <img src="assets/sign.png">
</p>

Sign - Create and maintain provisioning profiles
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/sign/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/sign.svg?style=flat)](http://rubygems.org/gems/sign)


Tired of manually creating and maintaining your provisioning profiles?

```Sign``` handles all that for you. Just run ```sign``` and it will do the rest.

Follow the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)



-------
[Features](#features) &bull;
[Installation](#installation) &bull;
[Usage](#usage) &bull;
[How does it work?](#how-does-it-work) &bull;
[Tips](#tips) &bull;
[Need help?](#need-help)

-------

# Features

- **Download** the latest provisining profile for your app
- **Renew** a provisining profile, when it has expired
- **Create** a new App Store provisioning profile, if it doesn't exist yet
- Support for both **App Store** and **Ad Hoc** profiles


Check out this gif:

![assets/signRecording.gif](assets/signRecording.gif)

# Installation
    sudo gem install sign

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

# Usage

    sign
Yes, that's the whole command!

You can pass parameters like this:

    sign -a at.felixkrause.app -u username

If you want to generate an Ad Ho profile instead:

    sign --development

By default, ```sign``` will install the downloaded profile on your machine. If you just want to generate the profile and skip the installation, use the following flag:

    sign --skip_install


## Environment Variables
In case you prefer environment variables:

- ```SIGN_USERNAME```
- ```SIGN_APP_IDENTIFIER```

# How does it work?

```Sign``` will access the ```iOS Dev Center``` to download, renew or generate the ```.mobileprovision``` file. Check out the full source code: [developer_center.rb](https://github.com/KrauseFx/sign/blob/master/lib/sign/developer_center.rb).


## How is my password stored?
```Sign``` uses the password manager from [```Deliver```](https://github.com/KrauseFx/deliver#can-i-trust-deliver). Take a look the [Deliver README](https://github.com/KrauseFx/deliver#can-i-trust-deliver) for more information.

# Tips
## Other helpful tools
Check out other tools in this collection to speed up your deployment process:

- [```deliver```](https://github.com/KrauseFx/deliver): Deploy screenshots, app metadata and app updates to the App Store using just one command
- [```snapshot```](https://github.com/KrauseFx/snapshot): Create hundreds of screenshots of your iPhone app... while doing something else
- [```FrameIt```](https://github.com/KrauseFx/frameit): Want a device frame around your screenshot? Do it in an instant!
- [```PEM```](https://github.com/KrauseFx/pem): Tired of manually creating and maintaining your push certification profiles?


## Use the 'Provisioning Quicklook plugin'
Download and install the [Provisioning Plugin](https://github.com/chockenberry/Provisioning).

It will show you the ```mobileprovision``` files like this: 
![assets/QuickLookScreenshot.png](assets/QuickLookScreenshot.png)


# Need help?
- If there is a technical problem with ```sign```, submit an issue. Run ```sign --trace``` to get the stacktrace.
- I'm available for contract work - drop me an email: sign@felixkrause.at

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/KrauseFx/sign/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
