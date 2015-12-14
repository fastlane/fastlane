# Contributing to `fastlane`

To clone the [fastlane](https://fastlane.tools) repos, use the [countdown](https://github.com/fastlane/countdown) repo. It will help you set up the development environment within minutes.

1. Create an issue to discuss about your idea.
2. Fork it (https://github.com/KrauseFx/fastlane/fork).
3. Create your feature branch (`git checkout -b my-new-feature`).
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create a new Pull Request.

## New Issues

Before submitting a new issue, do the following:

- Verify you're runing the latest version by running `fastlane -v` and compare it with the [project page on GitHub](https://github.com/KrauseFx/fastlane).
- Verify you have Xcode tools installed by running `xcode-select --install`.
- Make sure to read through the [README](https://github.com/KrauseFx/fastlane) of the project.


When submitting a new issue, please provide the following information:

- The full stack trace and output when running `fastlane`.
- The command and parameters you used to launch it.
- Your `Fastfile` and all other configuration files you are using. 

*By providing this information it's much faster and easier to help you*

## Pull Requests

Pull requests are always welcome :simple_smile:

- Your code editor should use the tab spaces of 2.
- Make sure to test the changes yourself before submitting.
- Run the tests by executing `bundle install` and then `bundle exec rspec`.
