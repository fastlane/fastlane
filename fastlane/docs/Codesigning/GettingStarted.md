# Codesigning concepts

If you are just starting a new project, it's important to think about how you want to handle code signing. This guide will help you choose the best approach for you.

For existing projects it might make sense to switch from a manual process to the [match approach](https://codesigning.guide) to make it easier for new team-members to onboard.

If you are new to code signing, check out the [WWDC session](https://developer.apple.com/videos/play/wwdc2016/401/) that describes the fundamentals of code signing in Xcode.

- [Using match](#using-match)
- [Using cert and sigh](#using-cert-and-sigh)
- [Using Xcode's code signing feature](#using-xcodes-code-signing-feature)
- [Manually](#manually)

## Using [match](https://fastlane.tools/match)

The concept of [match](https://fastlane.tools/match) is described in the [codesigning guide](https://codesigning.guide). 

With [match](https://fastlane.tools/match) you store your private keys and certificates in a git repo to sync them across machines. This makes it easy to onboard new team-members and set up new Mac machines. This approach [is secure](https://github.com/fastlane/fastlane/tree/master/match#is-this-secure) and uses technology you already use.

Getting started with [match](https://fastlane.tools/match) requires you to revoke your existing certificates.

Make sure to follow [XcodeProject.md](XcodeProject.md) to set up your project properly.

## Using [cert](https://fastlane.tools/cert) and [sigh](https://fastlane.tools/sigh)

If you don't want to revoke your existing certificates, but still want an automated setup, [cert](https://fastlane.tools/cert) and [sigh](https://fastlane.tools/sigh) are for you. 

- [cert](https://fastlane.tools/cert) will make sure you have a valid certificate and its private key installed on the local machine
- [sigh](https://fastlane.tools/sigh) will make sure you have a valid provisioning profile installed locally, that matches the installed certificate

Add the following lines to your `Fastfile`

```ruby
lane :beta do
  cert
  sigh
  gym
end
```

Make sure to follow [XcodeProject.md](XcodeProject.md) to set up your project properly.

## Using Xcode's code signing feature

Occasionally the `Automatic` setting as the provisioning profile doesn't work reliably as it will just select the most recently updated provisioning profile, no matter if the certificate is installed. 

That's why it is recommended to specify a specific provisioning profile somehow:

#### Xcode 7 and lower

You should avoid clicking the `Fix Issue` button (There is an [Xcode plugin](https://github.com/neonichu/FixCode#readme) that disables the button), as it sometimes revokes existing certificates, and with it the provisioning profiles.

Unfortunately you can't specify the name of the provisioning profile in Xcode 7. Instead you can specify the UUID of the profile, which changes every time the profile gets re-generated (e.g. when you add a new device).

To work around this issue, check out [XcodeProject.md](XcodeProject.md) on how to pass a provisioning profile to Xcode when building your app.

#### Xcode 8 and up

Apple improved code signing a lot with the release of Xcode 8, the following has changed:

- No more `Fix Issue` button, instead all code signing processes run in the background and show the log right in Xcode
- You can now specify the provisioning profile by name, instead of the UUID (Check out [XcodeProject.md](XcodeProject.md) for more information)
- Improved error messages when something goes wrong. If you run into code signing errors you should always try building and signing with Xcode to get more detailed error information. (Check out [Troubleshooting.md](Troubleshooting.md) for more information)

## Manually

You can always manually create and manage your certificates and provisioning profiles using the Apple Developer Portal. Make sure to store the private key (`.p12`) of your certificates in a safe place, as they can't be restored if you lose them. 

You can always download the certificate (`.cer`) and provisioning profile (`.mobileprovision`) from the Apple Developer Portal.
