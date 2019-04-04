# Authentication with spaceship

As spaceship talks to Apple's APIs, most requests need to be authenticated.

## Credentials

username + password
API token not supported yet as API access is not generally available, we are still using older APIs

## 2FA + 2SV

pushed security codes
SMS to trusted phone numbers via `sms`

### Avoid via additional Account

best way to avoid is create an additional account with required rights
not always possible for e.g. individual accounts, as Developer Portal can't create teams

### Auto-select SMS via `SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER`

If you _always_ want your security sent via SMS to a specific trusted phone number ...

