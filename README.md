<h3 align="center">
  <a href="https://github.com/fastlane/fastlane">
    <img src="https://raw.githubusercontent.com/KrauseFx/fastlane/master/assets/fastlane_text.png" width=400 />
    <br />
    countdown
  </a>
</h3>

<p align="center">
  <a href="https://github.com/fastlane/deliver">deliver</a> &bull; 
  <a href="https://github.com/fastlane/snapshot">snapshot</a> &bull; 
  <a href="https://github.com/fastlane/frameit">frameit</a> &bull; 
  <a href="https://github.com/fastlane/pem">pem</a> &bull; 
  <a href="https://github.com/fastlane/sigh">sigh</a> &bull; 
  <a href="https://github.com/fastlane/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/codes">codes</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a> &bull;
  <a href="https://github.com/fastlane/gym">gym</a>
</p>
-------

countdown
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/KrauseFx/countdown/blob/master/LICENSE)

###### Get started with fastlane development the fast way

Get in contact with the developer on Twitter: [@KrauseFx](https://twitter.com/KrauseFx)

<h5 align="center"><code>countdown</code> is part of <a href="https://fastlane.tools">fastlane</a>: connect all deployment tools into one streamlined workflow.</h5>

# Getting started

Make sure you have `bundler` installed using `gem install bundler`

Clone the `countdown` repo

```
git clone https://github.com/fastlane/countdown
```

Clone all `fastlane` repos and install development dependencies

```
cd countdown
[sudo] rake bootstrap
```

If you don't use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) you might need to run `sudo rake bootstrap` to not run into a permission error.

Before working on something, make sure to have pulled the latest changes. To pull the changes of all repos, go to the `countdown` directory and run

```
rake pull
```

# Developing

When working on something, directly edit the Ruby files in the project folders. Make sure to switch to 2 spaces in your text editor.

To run the modified version of the tool, run the following in the project directory

```
./bin/[tool_name]
```

# Debugging

I personally use a plain Sublime Text with a terminal. Debugging is pretty easy, just insert the following code to where you want to jump in:

```ruby
require 'pry'
binding.pry
```

You then jump into an interactive debugger that allows you to print out variables, call methods and much more. Continue running the original script using `control` + `d`

# Running tests

In the directory of one project, run the tests using

`rake test`

This will do a few things:

- Runs the tests (you can run them via `rspec` too)
- Makes sure no debug code (like `pry`) is still there
- The `--help` command works as expected

The tests are executed using `fastlane` :rocket:

# Running the local code

Run your local copy using

```
./bin/[gem]
```

or install the local copy (might require `sudo`)

```
bundle install && rake install
```

# rubocop validation

The `fastlane` repos use [rubocop](https://github.com/bbatsov/rubocop) to validate the code style.

The style validation is automatically done when running `rake test`.

To automatically fix common code style issues (e.g. wrong spacing), run `rubocop -a`

To sync the latest `rubocop` rules to all repos, run `rake fetch_rubocop` in the `countdown` directory. Use `rake rubocop` to fetch the latest config and run the rubocop validation for all repos.

The configuration is always directly taken from the local `fastlane` repository..

# Need help?
Please submit an issue on GitHub and provide information about your setup

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
