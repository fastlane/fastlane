# Codesigning concepts

If you are just starting a new project, it's important to think about how you want to handle code signing. This guide will help you choose the best approach for you.

For existing projects it might make sense to switch from a manual process to the [match appraoch](https://codesigning.guide) to make it easier for new team-members to onboard.

## Using [match](https://fastlane.tools/match)

The concept of [match](https://fastlane.tools/match) is described in the [codesigning guide](https://codesigning.guide). 

With [match](https://fastlane.tools/match) you store your private keys and certificates in a git repo to sync them across machines. This makes it easy to onboard new team-members and set up new Mac machines. This approach [is secure](https://github.com/fastlane/fastlane/tree/master/match#is-this-secure) and uses technology you already use.

Getting started with [match](https://fastlane.tools/match) requires you to revoke your existing certificates.

**TODO: Insert link to XcodeProject.md here**

## Using [cert](https://fastlane.tools/cert) and [sigh](https://fastlane.tools/sigh)

If you don't want to revoke your existing certificates, but still want an automated setup, [cert](https://fastlane.tools/cert) and [sigh](https://fastlane.tools/sigh) are for you. 

- [cert](https://fastlane.tools/cert) will make sure you have a valid certificate and its private key installed on the local machine
- [sigh](https://fastlane.tools/sigh) will make sure you have a valid provisioning profile installed locally, that matches the installed certificate

You basically add the following lines to your `Fastfile`

```ruby
lane :beta do
  cert
  sigh
  gym
end
```

**TODO: Insert link to XcodeProject.md here**

## Using Xcode's code signing feature

Sometimes the `Automatic` setting as the provisioning profile doesn't work reliably as it will just select the most recent provisioning profile, no matter if the certificate is installed. 

#### Xcode 7.3 and lower

You should avoid clicking the `Fix Issue` button (There is an [Xcode plugin](https://github.com/neonichu/FixCode#readme) that disables the button), as it sometimes revokes existing certificates, and with it the provisioning profiles.

Unfortunately you can't specify the name of the provisioning profile in Xcode 7.3. Instead you can specify the UUID of the profile, which changes every time the profile gets re-generated (e.g. when you add a new device).


#### Xcode 8 and up

Apple improved code signing a lot with the release of Xcode 8, the following has changed:

- No more `Fix Issue` button, instead all code signing processes run in the background and show the log right in Xcode
- You can now specify the provisioning profile by name, instead of the UUID (this is used in **TODO**)
- Improved error messages when something goes wrong. If you run into code signing errors you should always try building and signing with Xcode to get more detailed error information.

## Manually

You can always manually manage your certificates and provisoining profiles using the Apple Developer Portal. Make sure to store the private key of your certificates in a safe place, as they can't be restored if you lose them. 
