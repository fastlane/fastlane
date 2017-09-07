FAQs
=====

### I'm getting an SSL error

If your output contains something like

```
SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed
```

that usually means you are using an outdated version of OpenSSL. Make sure to install the latest one using [homebrew](http://brew.sh/).

```
brew update && brew upgrade openssl
```

If you use `rvm`, try the following

```
rvm osx-ssl-certs update all
```

### fastlane is slow (to start)

If you experiennce slow launch times of `fastlane`, there are 2 solutions to solve this problem:

##### Uninstall unused gems

```
[sudo] gem cleanup
```

##### Use a Gemfile

Follow the [Gemfile Guide](https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile) to set up your initial Gemfile. From then on launch `fastlane` using:

```
bundle exec fastlane ...
```

### Error when running `fastlane` with Jenkins

This is usually caused when running Jenkins as its own user. While this is possible, you'll have to take care of creating a temporary Keychain, filling it and then using it when building your application. 

For more information about the recommended setup with Jenkins open the [Jenkins Guide](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Jenkins.md).

### Code signing issues

Check out the [codesigning.guide](https://codesigning.guide) website for more information on how to properly setup code-signing in your team using [match](https://github.com/fastlane/fastlane/tree/master/match).

### When should I use _cert_, _sigh_ and _match_?

- _cert_ allows you to create a new code signing certificate + private key (note that the private key is only stored on your machine and won't be synced to any other mac)
- _sigh_ allows you to create and download a provisioning profile (those are synced via the  developer portal)
- _match_ uses those 2 tools in combination with a git repo you provide, to sync all private key, certificates and provisioning profiles across all your team's Macs and CI servers

We recommend using _match_ as it removes the complexity out of code signing, while still being in full control. This way you can sync all the signing identities across your team and your CI server. For more information check out [codesigning.guide](https://codesigning.guide).

### Multiple targets of the same underlying app

If you have one code base, but multiple branded applications

Create different `.env` files for each environment and reference those environment variables in the `Deliverfile`, `Fastfile`, etc. 

Example: Create a `.env.app1`, `.env.app2`, and `.env.app3`. Define each of these like the following...
```
DLV_FIRST_NAME=Josh
DLV_LAST_NAME=Holtz
DLV_PRIM_CATG=Business
DLV_SCND_CATG=Games
```

Now your Deliver file should look something like this:
```ruby
app_review_information(
  first_name: ENV['DLV_FIRST_NAME'],
  last_name: ENV['DLV_LAST_NAME']
)

primary_category ENV['DLV_PRIM_CATG']
secondary_category ENV['DLV_SCND_CATG']
```

Now to run this, all you need to do is specify the environment argument when running `fastlane` and it will pull from the `.env` file that matches the same name...
Ex: `fastlane build --env app1` will use `.env.app1`
Ex: `fastlane build --env app2` will use `.env.app2`

You can also references these environment variables almost anywhere in `fastlane`. 

You can even define a lane to perform actions on multiple targets:

```ruby
desc "Deploy both versions"
lane :deploy_all do
    sh "fastlane deploy --env paid"
    sh "fastlane deploy --env free"
end
```

And you can combine multiple envs in one go
Ex: `fastlane build --env app1,env1,env2` will use `.env.app1` `.env.env1` and `.env.env2`

More on the `.env` file can be found [here](https://github.com/bkeepers/dotenv).

### Disable colored output

Set the `FASTLANE_DISABLE_COLORS` environment variable to disable ANSI colors (e.g. for CI machines)

```
export FASTLANE_DISABLE_COLORS=1
```

### "User interaction is not allowed" when using `fastlane` via SSH

This error can occur when you run `fastlane` via SSH. To fix it check out [this reply on StackOverflow](https://stackoverflow.com/a/22637896/445598).

