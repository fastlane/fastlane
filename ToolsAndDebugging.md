# Tooling and Debugging

For detailed instructions on how to get started with contributing to _fastlane_, first check out [YourFirstPR.md][first-pr] and [Testing.md](Testing.md). This guide will focus on more advanced instructions on how to debug _fastlane_ and _spaceship_ issues and work on patches.

## Experiment with the _fastlane_ internals

Open a _fastlane_ console by running `fastlane console` inside or outside your project.

This will allow you to invoke any of the _fastlane_ modules and classes and test their behavior.

## Debug using [pry](https://pry.github.io/)

Before you’re able to use [pry](https://pry.github.io/), make sure to have completed the [YourFirstPR.md][first-pr] setup part, as this will install all required development dependencies.

To add a breakpoint anywhere in the _fastlane_ codebase, add the following 2 lines wherever you want to jump in

```ruby
require 'pry'
binding.pry
```

As debugging with pry requires the development dependencies, make sure to execute _fastlane_ using `bundle exec` after running `bundle install` in the project- or _fastlane_ directory.

```
bundle exec fastlane beta --verbose
```

If you need the breakpoint when running tests, make sure to have the `DEBUG` environment variable set, as the default test runner will remove all output from stdout, and therefore not showing the output of `pry`:

```
DEBUG=1 bundle exec rspec
```

You will then jump into an interactive debugger that allows you to print out variables, call methods and [much more](https://github.com/pry/pry/wiki).
To continue running the original script use `control` + `d`

## Running fastlane within a IRB console

You can open an IRB console by running `bin/console`

## Debugging and patching [_spaceship_](https://github.com/fastlane/fastlane/tree/master/spaceship) problems

### Introduction to _spaceship_

[_spaceship_](https://github.com/fastlane/fastlane/tree/master/spaceship) is fastlane's connection to Apple service. It is a Ruby library that exposes the Apple Developer Center and App Store Connect API. It’s super fast, well tested and supports all of the operations you can do via the browser. Scripting your Developer Center workflow has never been easier! 

### Verify the website works

If _spaceship_ doesn’t work, it’s best to first find out if the actual website (Developer Portal or App Store Connect) is currently working. Sometimes this might be a temporary server issue that gets resolved quickly. To gather information, make sure to check if other people are having the same issue on [GitHub](https://github.com/fastlane/fastlane/issues).
If it is a server issue, it’s best to [file a radar](https://bugreport.apple.com/) or call the [App Store Connect hotline](https://developer.apple.com/contact/phone/).

### Setting up [Charles Web Proxy](https://www.charlesproxy.com/)

<img src=".assets/ToolingCharlesEnableSSL.png" align="right" width="180" />

This section explains how you can set up [Charles Proxy](https://www.charlesproxy.com/) to track local https traffic and inspect the requests and their responses. Charles is a paid application with a free option that’s usually good enough for a quick debugging session limited to 30 minutes. If you prefer a free open source alternative, check out [mitmproxy](https://mitmproxy.org/).

First, download and install the latest version of [Charles Proxy](https://www.charlesproxy.com/). After the first launch, you’ll have to install its [Root Certificate](https://www.charlesproxy.com/documentation/using-charles/ssl-certificates/).

> In Charles go to the Help menu and choose "SSL Proxying > Install Charles Root Certificate". Keychain Access will open, and prompt you about the certificate. Click the "Always Trust" button. You will then be prompted for your Administrator password to update the system trust settings.

You might have to restart your Mac for the changes to be applied. To see if it works, relaunch Charles and Chrome/Safari and try opening [App Store Connect](https://appstoreconnect.apple.com).

If everything worked, you’ll already see a list of requests in the sidebar of Charles. Take a look at the above list of used API endpoints, and enable `SSL Proxying` and `Focus` on all endpoints you are interested in.
After doing so, refresh the App Store Connect page. You should be able to see all web requests with their responses.

We’re not using the built-in network tracker of your browser, since we also need a proxy for our local _fastlane_ install, which will be covered in the next section of this document.

<img src=".assets/ToolingCharlesRequest.png" />

### Compare the API requests

They key is to do the same action you want to test on both the website, and in _spaceship_, so you can see how the requests are different.

To pipe _spaceship_ requests through your local proxy, you need to set an environment variable:
```
SPACESHIP_DEBUG=1 bundle exec fastlane your_normal_command
```

To make it easier to run the same script again, you can temporarily edit the `Rakefile` to look like this:

```ruby
# leave existing code, and append the following

task :debug do
  require 'spaceship'

  # first login
  Spaceship::Tunes.login("apple@fastlane.tools") # use your own test account
  # or
  Spaceship::Portal.login("apple@fastlane.tools") # use your own test account

  # then add code to test whatever part of _spaceship_ needs to be tested
  # e.g.
  apps = Spaceship::Tunes::Application.all
  require 'pry'
  binding.pry
end
```

To run the newly created script, run

```
SPACESHIP_DEBUG=1 bundle exec rake debug
```

### Running the spaceship playground

You can open an interactive _spaceship_ session console by running `fastlane spaceship`

### Additional Information
See also the [Debugging _spaceship_](spaceship/docs/Debugging.md) documentation.

<!--Links-->
[first-pr]: YourFirstPR.md
