# Debugging codesigning issues

This guide will help you resolve the most common code signing errors.

## Error message

Make sure to find the exact error message in your build output. Many times the error message actually tells you how to resolve the issue. 

To get even more details, try archiving using Xcode 8. 

## Different machine

Does code signing work on a different Mac, but not on yours? If so, chances are high you don't have the latest private key, the certificate or the provisioning profile. Also follow the [Keychain](#keychain) part of this document to make sure you don't have any expired certificates installed.

## Xcode project

Make sure to follow [XcodeProject.md](XcodeProject.md) on how to properly set up your project.

A check list on what you should verify on your Xcode project

1. Make sure to have consistent code signing settings across your targets
1. Don't set any code signing settings on your project level, just on the target level
1. Make sure the bundle identifier matches the one of your provisioning profile
1. Make sure the code signing identity is set to `iOS Distribution` for `Release` builds
1. Make sure to set a provisioning profile for all your targets, e.g. Watch, Today widget, ...
1. Check your working copy in git - did you make any changes by mistake?

## Developer Portal

If a certificate gets revoked, all connected provisioning profiles get invalidated. This however might not immediately show up in your local keychain.

1. Open the [Developer Portal](https://developer.apple.com/account/ios/certificate/)
- Verify your certificates are valid, and didn't expire or get revoked
- Switch to the Provisioning Profiles and make sure the profiles you want to use are all still valid
  1. If your profile is invalid or expired, you can easily fix it:
    1. If you're using [match](https://fastlane.tools/match), run `match` with `force` enabled
    - If you're using [sigh](https://fastlane.tools/sigh), run `sigh` with `force` enabled
    - If you're doing manual code signing, edit the provisioning profile, and click on `Generate` on the bottom of the screen. Make sure to select the correct certificate, then download and open the new provisioning profile
  - If your profile is valid, but you still have issues make sure
    1. that the certificate matches the certificate you have installed locally. You can view the used certificate by editing the profile (Don't click `Generate`, unless you want to re-generate the provisioning profile)
    - that all devices you need are included (Development and Ad-Hoc only)
    - that you are actually looking at the correct provisioning profile, that matches the bundle identifier of your app. You might have multiple provisioning profiles for the same app / certificate combination. By default Xcode will use the last modified one.

## Keychain

1. Run `security find-identity -v -p codesigning` to get a list of locally installed code signing identities. Does yours show up?
1. Open the `Keychain Access` app, switch to `Certificates` and find your `iOS Developer` or `iOS Distribution` entry and unfold the entry to verify the private key is locally installed: 
<p align="center">
  <img src="assets/KeychainPrivateKey.png" width=500 />
</p>
1. Make sure to have deleted all expired WWDR certificates, more information [here](https://stackoverflow.com/questions/32821189/xcode-7-error-missing-ios-distribution-signing-identity-for/35401483#35401483). There might be 2 expired WWDR certificates, one in the `login`, and one in the `system` keychain

## Have you tried turning it off and on again?

As funny as it sounds, sometimes restarting your Mac helps.

## fastlane

Run `fastlane` in verbose mode to get even more debug information:

```
fastlane [lane] --verbose
```

## Common Issues

Check out [CommonIssues.md](CommonIssues.md) for the most common code signing issues and how you can solve them.
