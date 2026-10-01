<p align="center">
  <img src="/img/actions/precheck.png" width="250">
</p>

_precheck_
============

###### Check your app using a community driven set of App Store review rules to avoid being rejected

Apple rejects builds for many avoidable metadata issues like including swear words 😮, other companies’ trademarks, or even mentioning an iOS bug 🐛. _fastlane precheck_ takes a lot of the guess work out by scanning your app’s details in App Store Connect for avoidable problems. fastlane precheck helps you get your app through app review without rejections so you can ship faster 🚀

-------

<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#example">Example</a> &bull;
    <a href="#how-does-it-work">How does it work?</a>
</p>

-------

# Features


|          |  _precheck_ Features  |
|----------|-----------------------|
🐛 |  product bug mentions
🙅 | Swear word checker
🤖 | Mentioning other platforms
😵 | URL reachability checker
📝 | Placeholder/test words/mentioning future features
📅 | Copyright date checking
🙈 | Customizable word list checking
📢 | You can decide if you want to warn about potential problems and continue or have _fastlane_ show an error and stop after all scans are done

# Usage
Run _fastlane precheck_ to check the app metadata from App Store Connect

```no-highlight
fastlane precheck
```

To get a list of available options run

```no-highlight
fastlane action precheck
```

<img src="/img/actions/precheck.gif" />
    
# Example

Since you might want to manually trigger _precheck_ but don't want to specify all the parameters every time, you can store your defaults in a so called `Precheckfile`.

Run `fastlane precheck init` to create a new configuration file. Example:

```ruby-skip-tests
# indicates that your metadata will not be checked by this rule
negative_apple_sentiment(level: :skip)

# when triggered, this rule will warn you of a potential problem
curse_words(level: :warn)

# show error and prevent any further commands from running after fastlane precheck finishes
unreachable_urls(level: :error)

# pass in whatever words you want to check for
custom_text(data: ["chrome", "webos"], 
           level: :warn)
``` 

### Use with [_fastlane_](https://fastlane.tools)

_precheck_ is fully integrated with [_deliver_](https://docs.fastlane.tools/actions/deliver/) another [_fastlane_](https://fastlane.tools) tool.

Update your `Fastfile` to contain the following code:

```ruby
lane :production do
  # ...

  # by default deliver will call precheck and warn you of any problems
  # if you want precheck to halt submitting to app review, you can pass
  # precheck_default_rule_level: :error
  deliver(precheck_default_rule_level: :error)

  # ...
end

# or if you prefer, you can run precheck alone
lane :check_metadata do
  precheck
end

```

# How does it work?

_precheck_ will access `App Store Connect` to download your app's metadata. It uses [_spaceship_](https://spaceship.airforce) to communicate with Apple's web services.

# Want to improve precheck's rules?
Please submit an issue on GitHub and provide information about your App Store rejection! Make sure you scrub out any personally identifiable information since this will be public.
