# Authentication with _spaceship_

As _spaceship_ talks to Apple's APIs, most requests need to be authenticated with your Apple ID that you use to log in to https://developer.apple.com/. You start the login with a simple call to `Spaceship.login`.

## Credentials

The `Spaceship.login` method accepts `username` and `password` as parameters or will ask for them interactively if not provided. It will also try to retrieve them via [`CredentialsManager`](https://github.com/fastlane/fastlane/tree/master/credentials_manager), which supports environment variables `FASTLANE_USER` and `FASTLANE_PASSWORD` .

Login with API tokens is not supported yet as API access is not generally available. `Spaceship::Tunes` and `Spaceship::TestFlight` are also still using only older APIs that do not need API tokens for authentication yet.

## Two-factor Authentication

If your developer Apple ID has [Two-factor Authentication enabled](https://developer.apple.com/support/account/authentication/) _spaceship_ will also ask you for the security code that was pushed to your devices after successfully entering username and password.

If you cannot access any of your trusted devices, or just prefer it, you can also switch to the SMS based flow by entering `sms` at this prompt. _spaceship_ will then present you with a selection of your trusted phone numbers, and after choosing you can enter the security code you were sent by SMS.

_spaceship_ also supports legacy [Two-step verification](https://support.apple.com/en-us/HT204152) that is still active for some Apple IDs.

### Avoid 2FA via additional account

If you want to avoid dealing with the required interaction of using a Two-factor Authentication enabled account (for example because you want to use _spaceship_ on an automated or CI system that does not support interaction), you have to create an additional account with the required rights.

Note that Apple does not always allow in all situations. For example for individual accounts (vs. company accounts), it is not possible to create team member accounts for the Developer Portal (where you create app IDs, certificates etc).

### Auto-select SMS via `SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER`

If you _always_ want your security sent via SMS to a specific trusted phone number you can set the `SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER` environment variable to that phone number. The phone number should be specified in the same format as it is displayed in your [Apple ID console](https://appleid.apple.com/) under `TRUSTED PHONE NUMBERS`, e.g. `+49 123 4567890`, `+1-555-123-4567` or similar. Do not leave off the country code or add or remove any numbers, otherwise fastlane will not be able to match the masked value from Apple's API and select the correct number.

## Checking if a session is valid

The `--check_session` flag can be passed if you wish to check if the locally stored session for a user is still valid. This is useful for local testing and CI workflows.
