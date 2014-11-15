<p align="center">
<a href="https://github.com/KrauseFx/deliver">Deliver</a> &bull; 
<a href="https://github.com/KrauseFx/snapshot">Snapshot</a> &bull; 
<a href="https://github.com/KrauseFx/frameit">FrameIt</a>
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
[![Build Status](https://img.shields.io/travis/KrauseFx/pem/master.svg?style=flat)](https://travis-ci.org/KrauseFx/pem)


Tired of manually creating and maintaining your push notification profiles? Tired of generating a ```pem``` file for your server? 

```PEM``` does all that for, just by running ```pem```!

-------
[Features](#features) &bull;
[Installation](#installation) &bull;
[Usage](#usage) &bull;
[How does it work?](#how-does-it-work) &bull;
[Need help?](#need-help)

-------

# Installation
    sudo gem install pem

Make sure, you have the latest version of the Xcode command line tools installed:

    xcode-select --install

# Usage

```pem ```

This command does the following:

- Verifies the production push certificate looks alright
- Download the certificate
- Generates a new ```.pem``` file in the current working directory, which you can upload to your server

You can pass parameters to the command, like this:

```pem renew -a at.felixkrause.app -u username```

## Environment Variables
In case you prefer environment variables:

- ```PEM_USERNAME```
- ```PEM_APP_IDENTIFIER```

# How does it work?

TODO


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
