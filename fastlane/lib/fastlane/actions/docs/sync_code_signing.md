<p align="center">
  <img src="/img/actions/match.png" width="250">
</p>

###### Easily sync your certificates and profiles across your team using git

A new approach to iOS code signing: Share one code signing identity across your development team to simplify your codesigning setup and prevent code signing issues.

_match_ is the implementation of the https://codesigning.guide concept. _match_ creates all required certificates & provisioning profiles and stores them in a separate git repository. Every team member with access to the repo can use those credentials for code signing. _match_ also automatically repairs broken and expired credentials. It's the easiest way to share signing credentials across teams

[More information on how to get started with codesigning](https://docs.fastlane.tools/codesigning/getting-started/)

-------

<p align="center">
    <a href="#why-match">Why?</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#is-this-secure">Is this secure?</a>
</p>

-------

<h5 align="center"><code>match</code> is part of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate beta deployments and releases for your iOS and Android apps.</h5>

## Why match?

Before starting to use _match_, make sure to read the [codesigning.guide](https://codesigning.guide)

> When deploying an app to the App Store, beta testing service or even installing it on a device, most development teams have separate code signing identities for every member. This results in dozens of profiles including a lot of duplicates.

> You have to manually renew and download the latest set of provisioning profiles every time you add a new device or a certificate expires. Additionally this requires spending a lot of time when setting up a new machine that will build your app.

**A new approach**

> Share one code signing identity across your development team to simplify your setup and prevent code signing issues. What if there was a central place where your code signing identity and profiles are kept, so anyone in the team can access them during the build process?

### Why not let Xcode handle all this?

- You have full control over what happens
- You have access to all the certificates and profiles, which are all securely stored in git
- You share one code signing identity across the team to have fewer certificates and profiles
- Xcode sometimes revokes certificates which breaks your setup causing failed builds
- More predictable builds by settings profiles in an explicit way instead of using the `Automatic` setting
- It just works™

### What does _match_ do for you?

|          |  match  |
|----------|---------|
🔄  | Automatically sync your iOS keys and profiles across all your team members using git
📦  | Handle all the heavy lifting of creating and storing your certificates and profiles
💻  | Setup codesigning on a new machine in under a minute
🎯 | Designed to work with apps with multiple targets and bundle identifiers
🔒 | You have full control over your files and Git repo, no third party service involved
✨ | Provisioning profile will always match the correct certificate
💥  | Easily reset your existing profiles and certificates if your current account has expired or invalid profiles
♻️  | Automatically renew your provisioning profiles to include all your devices using the `--force` option
👥  | Support for multiple Apple accounts and multiple teams
✨ | Tightly integrated with [_fastlane_](https://fastlane.tools) to work seamlessly with [_gym_](https://docs.fastlane.tools/actions/gym/) and other build tools

For more information about the concept, visit [codesigning.guide](https://codesigning.guide).

## Usage

### Setup

1. Create a **new, private Git repo** (e.g. on [GitHub](https://github.com/new) or [BitBucket](https://bitbucket.org/repo/create)) and name it something like `certificates`. **Important:** Make sure the repository is set to *private*.
2. Optional: Create a **new, shared Apple Developer Portal account**, something like `office@company.com` that will be shared across your team from now on (for more information visit [codesigning.guide](https://codesigning.guide))
3. Run the following in your project folder to start using _match_:

```no-highlight
fastlane match init
```

<img src="/img/actions/match_init.gif" width="550" />

You'll be asked to enter the URL to your Git repo. This can be either a `https://` or a `git` URL. (If your machine is currently using SSH to authenticate with GitHub, you'll want to use a `git` URL, otherwise you may see an authentication error when you attempt to use match.) `fastlane match init` won't read or modify your certificates or profiles.

This will create a `Matchfile` in your current directory (or in your `./fastlane/` folder).

Example content (for more advanced setups check out the [fastlane section](#fastlane)):

```ruby-skip-tests
git_url("https://github.com/fastlane/certificates")

app_identifier("tools.fastlane.app")
username("user@fastlane.tools")
```

#### Important: Use one git branch per team

_match_ also supports storing certificates of multiple teams in one repo, by using separate git branches. If you work in multiple teams, make sure to set the `git_branch` parameter to a unique value per team. From there, _match_ will automatically create and use the specified branch for you.

```ruby
match(git_branch: "team1", username: "user@team1.com")
match(git_branch: "team2", username: "user@team2.com")
```

### Run

> Before running _match_ for the first time, you should consider clearing your existing profiles and certificates using the [match nuke command](#nuke).

After running `fastlane match init` you can run the following to generate new certificates and profiles:

```no-highlight
fastlane match appstore
```

```no-highlight
fastlane match development
```

<img src="/img/actions/match_appstore_small.gif" width="550" />

This will create a new certificate and provisioning profile (if required) and store them in your Git repo. If you previously ran _match_ it will automatically install the existing profiles from the Git repo.

The provisioning profiles are installed in `~/Library/MobileDevice/Provisioning Profiles` while the certificates and private keys are installed in your Keychain.

To get a more detailed output of what _match_ is doing use

```no-highlight
fastlane match --verbose
```

For a list of all available options run

```no-highlight
fastlane action match
```

#### Handle multiple targets

If you have several targets with different bundle identifiers, supply them as a comma-separated list to   :

```no-highlight
fastlane match appstore -a tools.fastlane.app,tools.fastlane.app.watchkitapp
```

You can make this even easier using [_fastlane_](https://fastlane.tools) by creating a `certificates` lane like this:

```ruby
lane :certificates do
  match(app_identifier: ["com.krausefx.app1", "com.krausefx.app2", "com.krausefx.app3"], readonly: true)
end
```

Then all your team has to do is `fastlane certificates` and keys, certs and profiles for all targets will be synced.

#### Passphrase

When running _match_ for the first time on a new machine, it will ask you for the passphrase for the Git repository. This is an additional layer of security: each of the files will be encrypted using `openssl`. Make sure to remember the password, as you'll need it when you run match on a different machine.

To set the passphrase to decrypt your profiles using an environment variable, use `MATCH_PASSWORD`.

#### New machine

To set up the certificates and provisioning profiles on a new machine, you just run the same command using:

```no-highlight
fastlane match development
```

You can also run _match_ in a `readonly` mode to be sure it won't create any new certificates or profiles.

```no-highlightno-highlight
fastlane match development --readonly
```

#### Access Control

A benefit of using _match_ is that it enables you to give the developers of your team access to the code signing certificates without having to give everyone access to the Developer Portal:

1. Run _match_ to store the certificates in a Git repo
2. Grant access to the Git repo to your developers and give them the passphrase
3. The developers can now run _match_ which will install the latest code signing profiles so they can build and sign the application without having to have access to the developer portal
4. Every time you run _match_ to update the profiles (e.g. add a new device), all your developers will automatically get the latest profiles when running _match_

If you decide to run _match_ without access to the developer portal, make sure to use the `--readonly` option so that the commands don't ask you for the password to the developer portal.

The advantage of this approach is that no one in your team will revoke a certificate by mistake. Additionally it is recommended to install the [FixCode Xcode Plugin](https://github.com/neonichu/FixCode) to disable the `Fix Issue` button.

#### Git Repo

After running _match_ for the first time, your Git repo will contain 2 directories:

- The `certs` folder contains all certificates with their private keys
- The `profiles` folder contains all provisioning profiles

Additionally, _match_ creates a nice repo `README.md` for you, making it easy to onboard new team members:

<p align="center">
  <img src="/img/actions/github_repo.png" width="700" />
</p>

#### fastlane

Add _match_ to your `Fastfile` to automatically fetch the latest code signing certificates with [_fastlane_](https://fastlane.tools).

```
match(type: "appstore")

match(git_url: "https://github.com/fastlane/certificates",
      type: "development")

match(git_url: "https://github.com/fastlane/certificates",
      type: "adhoc",
      app_identifier: "tools.fastlane.app")

match(git_url: "https://github.com/fastlane/certificates",
      type: "enterprise",
      app_identifier: "tools.fastlane.app")

# _match_ should be called before building the app with _gym_
gym
# ...
```

##### Registering new devices

By using _match_, you'll save a lot of time every time you add new device to your Ad Hoc or Development profiles. Use _match_ in combination with the [`register_devices`](https://docs.fastlane.tools/actions#register_devices) action.

```ruby
lane :beta do
  register_devices(devices_file: "./devices.txt")
  match(type: "adhoc", force_for_new_devices: true)
end
```

By using the `force_for_new_devices` parameter, _match_ will check if the device count has changed since the last time you ran _match_, and automatically re-generate the provisioning profile if necessary. You can also use `force: true` to re-generate the provisioning profile on each run.

_**Important:** The `force_for_new_devices` parameter is ignored for App Store provisioning profiles since they don't contain any device information._

If you're not using _fastlane_, you can also use the `force_for_new_devices` option from the command line:

```no-highlight
fastlane match adhoc --force_for_new_devices
```

##### Multiple Targets

If your app has multiple targets (e.g. Today Widget or WatchOS Extension)

```ruby
match(app_identifier: ["tools.fastlane.app", "tools.fastlane.app.today_widget"], type: "appstore")
```

_match_ can even use the same one Git repository for all bundle identifiers.

##### Templates (aka: custom entitlements)

Match can generate profiles that contain custom entitlements by passing in the entitlement's name with the `template_name` parameter.

```
match(git_url: "https://github.com/fastlane/certificates",
      type: "development",
      template_name: "Apple Pay Pass Suppression Development")
```

### Setup Xcode project

[Docs on how to set up your Xcode project](/codesigning/xcode-project/)

#### To build from the command line using [_fastlane_](https://fastlane.tools)

_match_ automatically pre-fills environment variables with the UUIDs of the correct provisioning profiles, ready to be used in your Xcode project.

More information about how to setup your Xcode project can be found [here](/codesigning/xcode-project/)

#### To build from Xcode manually

This is useful when installing your application on your device using the Development profile.

You can statically select the right provisioning profile in your Xcode project (the name will be `match Development tools.fastlane.app`).

[Docs on how to set up your Xcode project](/codesigning/xcode-project/)

### Continuous Integration

#### Repo access
There is one tricky part of setting up a CI system to work with _match_, which is enabling the CI to access the repo. Usually you'd just add your CI's public ssh key as a deploy key to your _match_ repo, but since your CI will already likely be using its public ssh key to access the codebase repo, [you won't be able to do that](https://help.github.com/articles/error-key-already-in-use/).

Some repo hosts might allow you to use the same deploy key for different repos, but GitHub will not. If your host does, you don't need to worry about this, just add your CI's public ssh key as a deploy key for your _match_ repo and scroll down to "_Encryption password_".

There are a few ways around this:

1. Create a new account on your repo host with read-only access to your _match_ repo. Bitrise have a good description of this [here](http://devcenter.bitrise.io/faq/adding-projects-with-submodules/).
2. Some CIs allow you to upload your signing credentials manually, but obviously this means that you'll have to re-upload the profiles/keys/certs each time they change.

Neither solution is pretty. It's one of those _trade-off_ things. Do you care more about **not** having an extra account sitting around, or do you care more about having the :sparkles: of auto-syncing of credentials.

#### Encryption password
Once you've decided which approach to take, all that's left to do is to set your encryption password as secret environment variable named `MATCH_PASSWORD`. _match_ will pick this up when it's run.

### Nuke

If you never really cared about code signing and have a messy Apple Developer account with a lot of invalid, expired or Xcode managed profiles/certificates, you can use the `match nuke` command to revoke your certificates and provisioning profiles. Don't worry, apps that are already available in the App Store / TestFlight will still work. Builds distributed via Ad Hoc or Enterprise will be disabled after nuking your account, so you'll have to re-upload a new build. After clearing your account you'll start from a clean state, and you can run _match_ to generate your certificates and profiles again.

To revoke all certificates and provisioning profiles for a specific environment:

```no-highlight
fastlane match nuke development
fastlane match nuke distribution
fastlane match nuke enterprise
```

<img src="/img/actions/match_nuke.gif" width="550" />

You'll have to confirm a list of profiles / certificates that will be deleted.

### Change Password

To change the password of your repo and therefore decrypting and encrypting all files run:

```no-highlight
fastlane match change_password
```

You'll be asked for the new password on all your machines on the next run.

### Manual Decrypt

If you want to manually decrypt a file you can.

```no-highlight
openssl aes-256-cbc -k "<password>" -in "<fileYouWantToDecryptPath>" -out "<decryptedFilePath>" -a -d
```

#### Export Distribution Certificate and Private Key as Single .p12 File

_match_ stores the certificate (`.cer`) and the private key (`.p12`) files separately. The following steps will repackage the separate certificate and private key into a single `.p12` file.

Decrypt your cert found in `certs/<type>/<unique-id>.cer` as a pem file:

```no-highlight
openssl aes-256-cbc -k "<password>" -in "certs/<type>/<unique-id>.cer" -out "cert.dem" -a -d
openssl x509 -inform der -in cert.der -out cert.pem
```

Decrypt your private key found in `certs/<type>/<unique-id>.p12` as a pem file:

```no-highlight
openssl aes-256-cbc -k "<password>" -in "certs/distribution/<unique-id>.p12" -out "key.pem" -a -d
```

Generate an encrypted p12 file with the same or new password:

```no-highlight
openssl pkcs12 -export -out "cert.p12" -inkey "key.pem' -in "cert.pem" -password pass:<password>
```

## Is this secure?

Both your keys and provisioning profiles are encrypted using OpenSSL using a passphrase.

Storing your private keys in a Git repo may sound off-putting at first. We did an in-depth analysis of potential security issues and came to the following conclusions:

#### What could happen if someone stole a private key?

If attackers would have your certificate and provisioning profile, they could codesign an application with the same bundle identifier.

What's the worst that could happen for each of the profile types?

##### App Store Profiles

An App Store profile can't be used for anything as long as it's not re-signed by Apple. The only way to get an app resigned is to submit an app for review which could take anywhere from 24 hours to a few days (checkout [appreviewtimes.com](http://appreviewtimes.com) for up-to-date expectations). Attackers could only submit an app for review, if they also got access to your iTunes Connect credentials (which are not stored in git, but in your local keychain). Additionally you get an email notification every time a build gets uploaded to cancel the submission even before your app gets into the review stage.

##### Development and Ad Hoc Profiles

In general those profiles are harmless as they can only be used to install a signed application on a small subset of devices. To add new devices, the attacker would also need your Apple Developer Portal credentials (which are not stored in git, but in your local keychain).

##### Enterprise Profiles

Attackers could use an In-House profile to distribute signed application to a potentially unlimited number of devices. All this would run under your company name and it could eventually lead to Apple revoking your In-House account. However it is very easy to revoke a certificate to remotely break the app on all devices.

Because of the potentially dangerous nature of In-House profiles please use _match_ with enterprise profiles with caution, ensure your git repository is private and use a secure password.

##### To sum up

- You have full control over the access list of your Git repo, no third party service involved
- Even if your certificates are leaked, they can't be used to cause any harm without your iTunes Connect login credentials
- Use In-House enterprise profile with _match_ with caution
- If you use GitHub or Bitbucket we encourage enabling 2 factor authentication for all accounts that have access to the certificates repo
- The complete source code of _match_ is fully open source on [GitHub](https://docs.fastlane.tools/actions/match/)
