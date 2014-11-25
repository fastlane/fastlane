<p align="center">
<a href="https://github.com/KrauseFx/deliver">Deliver</a> &bull; 
<a href="https://github.com/KrauseFx/snapshot">Snapshot</a> &bull; 
<a href="https://github.com/KrauseFx/frameit">FrameIt</a> &bull; 
<b>PEM</b>
</p>
-------

<p align="center">
    <img src="assets/pem.png">
</p>

Pem
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/pem/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/pem.svg?style=flat)](http://rubygems.org/gems/pem)


Tired of manually creating and maintaining your push notification profiles? Tired of generating a ```pem``` file for your server? 

```PEM``` does all that for, just by running ```pem```.

Felix Krause ([@KrauseFx](https://twitter.com/KrauseFx)) the developer of ```PEM```<br />
Sebastian Mayr ([@sebmasterkde](https://twitter.com/sebmasterkde)) who implemented the download mechanism of signing certificates<br />
Alexander Schuch ([@schuchalexander](https://twitter.com/schuchalexander)) who automated the generation of the signing request 


-------
[Features](#features) &bull;
[Installation](#installation) &bull;
[Usage](#usage) &bull;
[How does it work?](#how-does-it-work) &bull;
[Tips](#tips) &bull;
[Need help?](#need-help)

-------

# Features
Well, it's actually just one: Generate the ```pem``` file for your server.


Check out this gif:

![assets/PEMRecording.gif](assets/PEMRecording.gif)

# Installation
    sudo gem install pem

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

# Usage

    pem
Yes, that's the whole command!

This does the following:

- Verifies the production push certificate looks alright
- Renews the push certificate in case it's necessary
- Downloads the certificate
- Generates a new ```.pem``` file in the current working directory, which you can upload to your server

You can pass parameters like this:

    pem -a at.felixkrause.app -u username

If you want to generate a development certificate instead:

    pem --development

## Environment Variables
In case you prefer environment variables:

- ```PEM_USERNAME```
- ```PEM_APP_IDENTIFIER```
- ```PEM_CERT_SIGNING_REQUEST``` in case you want to pass your own signing request file

# How does it work?
There are 2 actions involved:

- Accessing the ```iOS Dev Center``` to download the latest ```aps_production.cer```. See: [developer_center.rb](https://github.com/KrauseFx/PEM/blob/master/lib/pem/developer_center.rb).
- Generating all the necessary profiles and files to prepare the finished ```.pem``` file. See: [cert_manager.rb](https://github.com/KrauseFx/PEM/blob/master/lib/pem/cert_manager.rb).
```PEM``` will create a temporary keychain called ```PEM.keychain``` and use that to generate the necessary profiles. That means ```PEM``` will not pollute your default keychain.
- The ```.certSigningRequest``` file will be generated in [signing_request.rb](https://github.com/KrauseFx/PEM/blob/master/lib/pem/signing_request.rb)


## How is my password stored?
```PEM``` uses the password manager from [```Deliver```](https://github.com/KrauseFx/deliver#can-i-trust-deliver). Take a look the [Deliver README](https://github.com/KrauseFx/deliver#can-i-trust-deliver) for more information.

# Tips
## Other helpful tools
Check out other tools in this collection to speed up your deployment process:
- [```deliver```](https://github.com/KrauseFx/deliver): Deploy screenshots, app metadata and app updates to the App Store using just one command
- [```snapshot```](https://github.com/KrauseFx/snapshot): Create hundreds of screenshots of your iPhone app... while doing something else
- [```FrameIt```](https://github.com/KrauseFx/frameit): Want a device frame around your screenshot? Do it in an instant!

## Use the ```Provisioning Quicklook plugin```
Download and install the [Provisioning Plugin](https://github.com/chockenberry/Provisioning).

It will show you the ```pem``` files like this: 
![assets/QuickLookScreenshot.png](assets/QuickLookScreenshot.png)


# Need help?
- If there is a technical problem with ```PEM```, submit an issue. Run ```pem --trace``` to get the stacktrace.
- I'm available for contract work - drop me an email: pem@felixkrause.at

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

# Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/KrauseFx/pem/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
