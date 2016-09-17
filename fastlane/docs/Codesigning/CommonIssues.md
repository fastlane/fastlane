# Common code signing issues

## Xcode errors

> Code Sign error: No matching provisioning profiles found: No provisioning profiles with a valid signing identity (i.e. certificate and private key pair) matching the bundle identifier "X" were found.

The provisioning profile for the given app identifier "X" is not available on the local machine. Make sure you have a valid provisioning profile for the correct distribution type (App Store, Development or Ad Hoc) on the Apple Developer Portal, download and install it, and select the profile in the Xcode settings (See [XcodeProject.md](XcodeProject.md)).

You might have the provisioning profile installed locally, but miss the private key or certificate for it. 

> No matching codesigning identity found: No codesigning identities (i.e. certificate and private key pairs) matching "iPhone Distribution: X" were found

The code signing identity you specified in the Xcode project can't be found in your local keychain. Make sure to transfer the certificate and private key from another Mac (or wherever you store the private key), or to update the project file to use the correct code signing identity.

> Error Domain=IDEDistributionErrorDomain Code=1 "The operation couldn’t be completed. (IDEDistributionErrorDomain error 1.)"

This error can have a lot of reasons, some things you should try:

- Verify your Keychain is valid and you don't have an expired WWDR certificate using [this guide](Troubleshooting.md#keychain)
- Verify both your certificate and provisioning profile are valid in both your Keychain and on the Apple Developer Portal (Check out [Troubleshooting.md](Troubleshooting.md) for more information)
- If you're using [gym](https://fastlane.tools/gym), try using the `use_legacy_build_api` flag to fallback to the Xcode 6 build API
- Follow the other steps of [Troubleshooting.md](Troubleshooting.md)

> Provisioning profile does not match bundle identifier: The provisioning profile specified in your build settings ("X") has an AppID of "Y" which does not match your bundle identifier "Z"

Your project defines a provisioning profile that doesn't match the bundle identifier of your app. There is mismatch between the bundle identifiers, this might happen if you specify the wrong provisioning profile in your target.

> Your build settings specify a provisioning profile with the UUID "X", however, no such provisioning profile was found.

Your project defines a provisioning profile which doesn't exist on your local machine. Check out [XcodeProject.md](XcodeProject.md) for more information how to properly specify a provisioning profile to avoid hard coded UUIDs in your project.

> CodeSign Error: code signing is required for product type 'Application'...

Make sure to have a valid code signing identity defined in your project targets. This might happen when you select `Don't Code Sign` as Code Signing Identity.

## fastlane errors

> Could not find a matching code signing identity for type 'X'

There are no certificates available on the Apple Developer Portal. This could either mean someone revoked a certificate, or you don't have access to it. 
