# Xcode::Install

[![Build Status](http://img.shields.io/travis/neonichu/xcode-install/master.svg?style=flat)](https://travis-ci.org/neonichu/xcode-install)
[![Coverage Status](https://coveralls.io/repos/neonichu/xcode-install/badge.svg)](https://coveralls.io/r/neonichu/xcode-install)
[![Gem Version](http://img.shields.io/gem/v/xcode-install.svg?style=flat)](http://badge.fury.io/rb/xcode-install)
[![Code Climate](http://img.shields.io/codeclimate/github/neonichu/xcode-install.svg?style=flat)](https://codeclimate.com/github/neonichu/xcode-install)

Install and update your Xcodes automatically.

```
$ gem install xcode-install
$ xcversion install 6.3
```

## Installation

```
$ gem install xcode-install
```

Note: unfortunately, XcodeInstall has a transitive dependency on a gem with native extensions and this is not really fixable at this point in time. If you are installing this on a machine without a working compiler, please use these alternative instructions instead:

```
$ curl -sL -O https://github.com/neonichu/ruby-domain_name/releases/download/v0.5.99999999/domain_name-0.5.99999999.gem
$ gem install domain_name-0.5.99999999.gem
$ gem install --conservative xcode-install
$ rm -f domain_name-0.5.99999999.gem
```

## Usage

XcodeInstall needs environment variables with your credentials to access the Apple Developer
Center, they are stored using the [CredentialsManager][1] of [fastlane][2]:

```
XCODE_INSTALL_USER
XCODE_INSTALL_PASSWORD
```

To list available versions:

```
$ xcversion list
6.0.1
6.1
6.1.1
6.2
6.3
```

Installed versions will be omitted and by default, only the latest major version is listed.

To install a certain version, simply:

```
$ xcversion install 6.3
###########################################################               82.1%
######################################################################## 100.0%
Please authenticate for Xcode installation...

Xcode 6.3
Build version 6D570
```

This will download and install that version of Xcode. It will also be automatically selected.

Note: GMs and beta versions usually have special names, e.g.

```
$ xcversion list
7 GM seed
7.1 beta
```

they have to be installed using the full name, e.g. `xcversion install '7 GM seed'`.

### Command Line Tools

XcodeInstall can also install Xcode's Command Line Tools by calling `xcversion install-cli-tools`.

### Simulators

XcodeInstall can also manage your local simulators using the `simulators` command.

```
$ xcversion simulators
Xcode 6.4 (/Applications/Xcode-6.4.app)
iOS 7.1 Simulator (installed)
iOS 8.1 Simulator (not installed)
iOS 8.2 Simulator (not installed)
iOS 8.3 Simulator (installed)
Xcode 7.2.1 (/Applications/Xcode-7.2.1.app)
iOS 8.1 Simulator (not installed)
iOS 8.2 Simulator (not installed)
iOS 8.3 Simulator (installed)
iOS 8.4 Simulator (not installed)
iOS 9.0 Simulator (not installed)
iOS 9.1 Simulator (not installed)
tvOS 9.0 Simulator (not installed)
watchOS 2.0 Simulator (installed)
```

To install a simulator, use `--install` and the beginning of a simulator name:

```
$ xcversion simulators --install='iOS 8.4'
###########################################################               82.1%
######################################################################## 100.0%
Please authenticate to install iOS 8.4 Simulator...

Successfully installed iOS 8.4 Simulator
```

## Limitations

Unfortunately, the installation size of Xcodes downloaded will be bigger than when downloading via the Mac App Store, see [#10](/../../issues/10) and feel free to dupe the radar. 📡

XcodeInstall automatically installs additional components so that it is immediately usable from the
commandline. Unfortunately, Xcode will load third-party plugins even in that situation, which leads
to a dialog popping up. Feel free to dupe [the radar][5]. 📡

XcodeInstall uses the Spotlight index to locate installed versions of Xcode. If you use it while
indexing is happening, it might show inaccurate results and it will not be able to see installed
versions on unindexed volumes.

## Thanks

[This][3] downloading script which has been used for some inspiration, also [this][4]
for doing the installation. Additionally, many thanks to everyone who has contributed to this
project, especially [@henrikhodne][6] and [@lacostej][7] for making XcodeInstall C extension free.

## Contributing

1. Fork it ( https://github.com/neonichu/xcode-install/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Help needed

Follow [@NeoNacho](https://twitter.com/NeoNacho) to help me beat [@orta](https://twitter.com/orta) in followers count.

[1]: https://github.com/fastlane/credentials_manager#using-environment-variables
[2]: http://fastlane.tools
[3]: http://atastypixel.com/blog/resuming-adc-downloads-cos-safari-sucks/
[4]: https://github.com/magneticbear/Jenkins_Bootstrap
[5]: http://www.openradar.me/22001810
[6]: https://github.com/henrikhodne
[7]: https://github.com/lacostej
