<p align="center">
  <img src="/img/actions/cert.png" width="250">
</p>

-------
<p align="center">
    <a href="#why">Why?</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#how-does-it-work">How does it work?</a> &bull;
    <a href="#tips">Tips</a>
</p>

-------

<h5 align="center"><code>cert</code> is part of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate beta deployments and releases for your iOS and Android apps.</h5>

![/img/actions/cert.gif](/img/actions/cert.gif)

In the gif we used `cert && sigh`, which will first create an iOS code signing certificate and then a provisioning profile for your app if _cert_ succeeded.

# Usage

**Note**: It is recommended to use [_match_](/actions/match) according to the [codesigning.guide](https://codesigning.guide) for generating and maintaining your certificates. Use _cert_ directly only if you want full control over what's going on and know more about codesigning.

```no-highlight
fastlane cert
```

This will check if any of the available signing certificates is installed on your local machine.

Only if a new certificate needs to be created, _cert_ will

- Create a new private key
- Create a new signing request
- Generate, downloads and installs the certificate
- Import all the generated files into your Keychain

_cert_ will never revoke your existing certificates. If you can't create any more certificates, _cert_ will raise an exception, which means, you have to revoke one of the existing certificates to make room for a new one.


You can pass your Apple ID:

```no-highlight
fastlane cert -u cert@krausefx.com
```

For a list of available commands run

```no-highlight
fastlane action cert
```

Keep in mind, there is no way for _cert_ to download existing certificates + private keys from the Apple Developer Portal, as the private key never leaves your computer.

## Environment Variables

Run `fastlane action cert` to get a list of all available environment variables.

## Use with [_sigh_](https://docs.fastlane.tools/actions/sigh/)

_cert_ becomes really interesting when used in [_fastlane_](https://fastlane.tools) in combination with [_sigh_](https://docs.fastlane.tools/actions/sigh/).

Update your `Fastfile` to contain the following code:

```ruby
lane :beta do
  cert
  sigh(force: true)
end
```

`force: true` will make sure to re-generate the provisioning profile on each run.
This will result in _sigh_ always using the correct signing certificate, which is installed on the local machine.


## How is my password stored?
_cert_ uses the [password manager](https://github.com/fastlane/fastlane/tree/master/credentials_manager) from _fastlane_. Take a look the [CredentialsManager README](https://github.com/fastlane/fastlane/blob/master/credentials_manager/README.md) for more information.

# Tips

## Use 'ProvisionQL' for advanced Quick Look in Finder

Install [ProvisionQL](https://github.com/ealeksandrov/ProvisionQL).

It will show you `mobileprovision` files like this:
![img/actions/QuickLookScreenshot-Provision.png](/img/actions/QuickLookScreenshot-Provision.png)
