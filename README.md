CredentialsManager
===================

`CredentialsManager` is used by most components in the [fastlane.tools](https://fastlane.tools) toolchain.

All code related to your username and password can be found here: [password_manager.rb](https://github.com/KrauseFx/CredentialsManager/blob/master/lib/credentials_manager/password_manager.rb)

## Storing in the keychain

By default, your Apple credentials are stored in the OS X Keychain. You can easily delete them by opening the "Keychain Access" app, switching to *All Items*, and searching for "*deliver*".

## Using environment variables

```
DELIVER_USER
DELIVER_PASSWORD
```

If you don't want to have your password stored in the Keychain use `FASTLANE_DONT_STORE_PASSWORD`.

## Implementing a custom solution

All ```fastlane``` tools are Ruby-based, and you can take a look at the source code to easily implement your own authentication solution.

Your password is only stored locally on your computer.

# License

This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.

# Contributing

1. Create an issue to discuss about your idea
2. Fork it (https://github.com/KrauseFx/CredentialsManager/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
