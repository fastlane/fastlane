# Contributing to `fastlane`

## Getting started

Make sure you have `bundler` installed using `gem install bundler`

- Open the GitHub page of the `fastlane`repository  (e.g. [https://github.com/fastlane/fastlane](https://github.com/fastlane/fastlane))
- Create an issue to discuss your idea/feature/enhancement.
- Click on `Fork` on the top right
- Then clone your new repo locally `git clone https://github.com/[my_user]/fastlane.git`
- On your terminal, navigate to the project and run `git remote add upstream https://github.com/fastlane/fastlane` (or use the `git` URL if you use private key auth)
- Create your feature branch (`git checkout -b my-new-feature`).
- Commit your changes (`git commit -am 'Add some feature'`).
- Push to the branch (`git push origin my-new-feature`).
- Create a new Pull Request.

Before working on something, make sure to have pulled the latest changes. To pull the changes run

```
git pull master
```

## New Issues

Before submitting a new issue, do the following:

- Verify you're running the latest version by running `fastlane -v` and compare it with the [project page on GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
- Verify you have Xcode tools installed by running `xcode-select --install`.
- Make sure to read through the [README](https://github.com/fastlane/fastlane/tree/master/fastlane) of the project.

When submitting a new issue, please provide the following information:

- The full stack trace and output when running `fastlane`.
- The command and parameters you used to launch it.
- Your `Fastfile` and all other configuration files you are using.

*By providing this information it's much faster and easier to help you*

## Helping to Resolve Existing Issues

If you're motivated to help out at a level beyond reporting issues, we really appreciate it! :+1: We use the [`help wanted`](https://github.com/fastlane/fastlane/labels/help%20wanted) label to mark things that we think it would be great to have community help in resolving, so that's a great place to start! In addition, working on the following things are super valuable:

### Verifying Bug Reports

Are you able to reproduce this problem on your computer? If so, chime in! If the original issue report is a bit vague, but you have some additional details, please contribute them! If you find a bug report without an example script or configuration, contribute one that can be used to reproduce it.

If you're comfortable diving into the code a bit, see if you can produce a failing test that illustrates the bad behavior in the problematic area of the code! Tests live in the `spec/` directory, and are generally named relative to the source code files whose functionality they test. Once you are done, `git diff > my_patch.diff` can be used to produce a patch file containing the details of your changes, which can be added to the issue.

### Testing Proposed Fixes

Another way to help out is to verify submitted pull requests. To do that, you'll need to be able to get the author's proposed changes onto your machine. Start by giving yourself a new branch to work in:

```
git checkout -b testing_branch
```

Next, you'll need to tell git where to find this contributor's fastlane fork and branch. Let's say that the contributor's username is **JohnSmith** and their topic branch is called `new_fastlane_action` located at **https://github.com/JohnSmith/fastlane**. You can use the following commands to pull their work:

```
git remote add JohnSmith https://github.com/JohnSmith/fastlane.git
git pull JohnSmith new_fastlane_action
```

Once you have their changes locally, there's many things worth checking on:

* Does the change work?
* Are there adequate tests to cover the changes or new functionality? Are the tests clear and testing the right things?
* Is the related documentation updated? New actions get described in `docs/Actions.md`, for example.
* How does the code look to you? Can you think of a nicer or more performant way to implement part of it?

If you're happy with what you see, leave a comment on the GitHub issue stating your approval. If not, leave a polite suggestion for what you think could be improved and how. The more you can show that you've reviewed the content seriously, the more valuable it will be to the author and other reviewers!

## Pull Requests (PRs)

Pull requests are always welcome :smile:

PRs should reference an open GitHub issue (preferably those marked with the [help wanted](https://github.com/fastlane/fastlane/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22) label). Referring to the issue in the description of your PR is required and is really helpful for establishing the context needed for review.

If you're considering contributing new functionality, please open a new issue explaining the functionality desired first so that we can discuss as a community. We'll add the [help wanted](https://github.com/fastlane/fastlane/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22) label if we believe this to be a meaningful contribution that will benefit other fastlane users and you go ahead with the pull request. :raised_hands:

- Adding automated tests that cover your changes and/or new functionality is important!
    - `fastlane` has a lot of moving parts and receives contributions from many developers. The best way to ensure that your contributions keep working is to ensure that there will be failing tests if something accidentally gets broken.
    - You can run the tests by executing `bundle install`, then:
        - Run tests only for a given tool by `cd` in that tool subdirectory (e.g. `cd pilot`) then running `bundle exec rspec`,
        - Or test all `fastlane` tools by running `rake test_all` from the root of your working copy.
- Your code editor should indent using spaces with a tab size of 2 spaces.

To submit the changes to the fastlane repo, you have to do the following:

- Run `git push origin master` (replace `master` with the name of the branch you made your modifications onto in your fork when appropriate).
- Open `https://github.com/fastlane/fastlane` in your browser and click the green "Create Pull Request" button

## What Do All These Labels Mean?

Great question! Check out the [GitHub Labels](GitHubLabels.md) document for a quick summary of the labels we use and what they mean.

## Why Did My Issue/PR Get Closed?

It's not you, it's us! fastlane and its related tools receive a lot of issues and PRs. In order to effectively work through them and give each the prompt attention it deserves, we need to keep a sharp focus on the work we have outstanding.

One way we do this is by closing issues that we don't feel are immediately actionable. This might mean that we need more information in order to investigate (Have you provided enough information for us to reproduce the problem? The [New Issues](#new-issues) section has the details!). Or, it might mean that we haven't been able to reproduce it using the provided info. In this case we might close the issue while we wait for others to reproduce the problem and possibly provide some more info that unlocks the mystery.

In any case, **a closed issue is not necessarily the end of the story!** If more info becomes available after an issue is closed, it can be reopened for further consideration.

One of the best ways we can keep fastlane an approachable, stable, and dependable tool is to be deliberate about how we choose to modify it. If we don't adopt your changes or new feature into fastlane, that doesn't mean it was bad work! It may be that the fastlane philosophy about how to accomplish a particular task doesn't align well with your approach. The best way to make sure that your time is well spent in contributing to fastlane is to **start your work** on a modification or new feature **by opening an issue to discuss the problem or shortcoming with the community**. The fastlane maintainers will do our best to give early feedback about whether a particular goal and approach is likely to be something we want to adopt!

## Contributing New Actions

There are different approaches to build your own `fastlane` actions. You can either build your own local actions, or provide your own fastlane plugin. For more information, check out [Plugins.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md#readme).

## Developing

When working on something, directly edit the Ruby files in the project folders. Make sure to switch your text editor to use spaces and indentations should be 2 spaces.

To run the modified version of the tool, run the following in the project directory

```
.[tool_name]/bin/[tool_name]
```

or install the local copy (might require `sudo`)

```
bundle install && rake install
```

## Debugging

I personally use a plain Sublime Text with a terminal. Debugging is pretty easy, just insert the following code to where you want to jump in:

```ruby
require 'pry'
binding.pry
```

You then jump into an interactive debugger that allows you to print out variables, call methods and much more. Continue running the original script using `control` + `d`

## Running tests

In the directory of one project, run the tests using

`rake test_all`

This will do a few things:

- Runs the tests (you can run them via `rspec` too)
- Makes sure no debug code (like `pry`) is still there
- The `--help` command works as expected

The tests are executed using `fastlane` :rocket:

To run only a subset of the tests, you can add the `now: true` keyword to the test

```ruby
it "raises an exception if it rains", now: true do
  ...
end
```

and then run these tests only using

```sh
rspec -t now
```

## rubocop validation

The `fastlane` repos use [rubocop](https://github.com/bbatsov/rubocop) to validate the code style.

The style validation is automatically done when running `rake test_all`.

To automatically fix common code style issues (e.g. wrong spacing), run `rubocop -a`

## Need help?
Please submit an [issue](https://github.com/fastlane/fastlane/issues) on GitHub and provide information about your setup

## Code of Conduct
Help us keep `fastlane` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).


# Above All, Thanks for Your Contributions

Thank you for reading to the end, and for taking the time to contribute to the project! If you include the 🔑 emoji at the top of the body of your issue or pull request, we'll know that you've given this your full attention and are doing your best to help!

## License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
