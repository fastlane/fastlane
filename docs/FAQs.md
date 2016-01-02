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

### Error when running `fastlane` with Jenkins

This is usually caused when running Jenkins as its own user. While this is possible, you'll have to take care of creating a temporary Keychain, filling it and then using it when building your application. 

For more information about the recommended setup with Jenkins open the [Jenkins Guide](https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md).

### Code signing issues

There is a separate [guide](https://github.com/KrauseFx/fastlane/blob/master/docs/CodeSigning.md) available about how to setup code signing.

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
```
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

```
desc "Deploy both versions"
lane :deploy_all do
    sh "fastlane deploy --env paid"
    sh "fastlane deploy --env free"
end
```

More on the `.env` file can be found [here](https://github.com/bkeepers/dotenv).

### Disable colored output

Set the `FASTLANE_DISABLE_COLORS` environment variable to disable ANSI colors (e.g. for CI machines)

```
export FASTLANE_DISABLE_COLORS=1
```

### "User interaction is not allowed" when using `fastlane` via SSH

This error can occur when you run `fastlane` via SSH. To fix it check out [this reply on StackOverflow](http://stackoverflow.com/a/22637896/445598).

