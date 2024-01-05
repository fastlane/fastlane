# Debugging _spaceship_

If you have a problem with _spaceship_ or its usage in _fastlane_, there are multiple way to debug what is going on:

## Logging

_spaceship_ logs all requests and their responses to logfiles in `/tmp`. They follow the naming pattern `spaceship[time]_[pid].log` and include timestamps, incoming/outgoing, request method, request params and response body.  
  
Example logfile:

```
# Logfile created on 2018-11-21 19:26:55 +0100 by logger.rb/56815
[19:26:55]: >> POST:  
[19:26:56]: << POST: : {"authType"=>"hsa2"}
[19:26:56]: >> GET:  
[19:26:56]: << GET: : {"trustedPhoneNumbers"=>[{"numberWithDialCode"=>"+49 •••• •••••85", "pushMode"=>"sms", "obfuscatedNumber"=>"•••• •••••85", "id"=>1}], "securityCode"=>{"length"=>6, "tooManyCodesSent"=>false, "tooManyCodesValidated"=>false, "securityCodeLocked"=>false}, "authenticationType"=>"hsa2", "recoveryUrl"=>"https://iforgot.apple.com/phone/add?prs_account_nm=user@example.org&autoSubmitAccount=true&appId=142", "cantUsePhoneNumberUrl"=>"https://iforgot.apple.com/iforgot/phone/add?context=cantuse&prs_account_nm=user@example.org&autoSubmitAccount=true&appId=142", "recoveryWebUrl"=>"https://iforgot.apple.com/password/verify/appleid?prs_account_nm=user@example.org&autoSubmitAccount=true&appId=142", "repairPhoneNumberUrl"=>"https://gsa.apple.com/appleid/account/manage/repair/verify/phone", "repairPhoneNumberWebUrl"=>"https://appleid.apple.com/widget/account/repair?#!repair", "aboutTwoFactorAuthenticationUrl"=>"https://support.apple.com/kb/HT204921", "autoVerified"=>false, "showAutoVerificationUI"=>false, "managedAccount"=>false, "supportsRecovery"=>true, "hsa2Account"=>true, "trustedPhoneNumber"=>{"numberWithDialCode"=>"+49 •••• •••••85", "pushMode"=>"sms", "obfuscatedNumber"=>"•••• •••••85", "id"=>1}}
```

## Proxy Support

_spaceship_ also comes with support for proxies (e.g. [Charles Web Proxy](https://www.charlesproxy.com/), free endless 30 minute trial available, available for all platforms) that listen on `https://127.0.0.1:8888`. Just set the environment variable `SPACESHIP_DEBUG` to activate.  

Read [fastlane's "Tooling and Debugging" docs](https://github.com/fastlane/fastlane/blob/master/ToolsAndDebugging.md) for information on how to set it up.

If your proxy is listening on another port or address, you can use `SPACESHIP_PROXY` to set this. Use `SPACESHIP_PROXY_SSL_VERIFY_NONE` to additionally disable certificate checking.

## Client configuration

- If you have timeout problems, you can use `SPACESHIP_TIMEOUT` to set any timeout (in seconds)
- If your session cookie is saved at a different path, use `SPACESHIP_COOKIE_PATH` to specify it
- Set [`SPACESHIP_AVOID_XCODE_API`](https://github.com/fastlane/fastlane/pull/8359) to use the Apple Developer Portal API instead of the Xcode API. (You probably want the Xcode API unless you have a reason not to.)

## Further instructions

You can also check [ToolsAndDebugging.md](https://github.com/fastlane/fastlane/blob/master/ToolsAndDebugging.md#debugging-and-patching-spaceship-issues) for further debugging instructions.
