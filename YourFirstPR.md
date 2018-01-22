# Your first PR

## Prerequisites

Before you start working on _fastlane_, make sure you had a look at [CONTRIBUTING.md](CONTRIBUTING.md).

For working on _fastlane_ you should have [Bundler][bundler] installed. Bundler is a ruby project that allows you to specify all ruby dependencies in a file called the `Gemfile`. If you want to learn more about how Bundler works, check out [their website][bundler help].

## Finding things to work on

The core team usually tags issues that are ready to be worked on and easily accessible for new contributors with the [“you can do this” label][you can do this]. If you’ve never contributed to _fastlane_ before, these are a great place to start!

If you want to work on something else, e.g. new functionality or fixing a bug, it would be helpful if you submit a new issue, so that we can have a chance to discuss it first. We might have some pointers for you on how to get started, or how to best integrate it with existing solutions.

## Checking out the _fastlane_ repo

- Click the “Fork” button in the upper right corner of the [main _fastlane_ repo][fastlane]
- Clone your fork:
  - `git clone git@github.com:<YOUR_GITHUB_USER>/fastlane.git`
  - Learn more about how to manage your fork: https://help.github.com/articles/working-with-forks/
- Install dependencies:
  - Run `bundle install` in the project root
  - If there are dependency errors, you might also need to run `bundle update`
- Create a new branch to work on:
  - `git checkout -b <YOUR_BRANCH_NAME>`
  - A good name for a branch describes the thing you’ll be working on, e.g. `docs-fixes`, `fix-deliver-upload`, `gym-build-android-app`, etc.
- That’s it! Now you’re ready to work on _fastlane_

## Testing your local changes

### Checking it all

The `Fastfile` included at the top of the fastlane project allows you to run several validation steps, such as automated tests, code style and more.

```
bundle exec fastlane test
```

You can also run those steps independently or on a more fine grained way.

### Automated tests

Make sure to run the automated tests using `bundle exec` to ensure you’re running the correct version of `rspec` and `rubocop`

#### All unit tests

First, navigate into the root of the _fastlane_ project and run all unit tests using

```
bundle exec rspec
```

#### Unit tests for one specific tool

If you want to run tests only for one tool, use

```
bundle exec rspec [tool_name]
```

#### Unit tests in one specific test file

If you know exactly which `_spec.rb` file you want to run, use

```
bundle exec rspec ./fastlane/spec/fastlane_require_spec.rb
```

(replace `./fastlane/spec/fastlane_require_spec.rb` with the path of your test file of course)

### Code style

To verify and auto-fix the code style

```
bundle exec rubocop -a
```

If you want to run code style verification only for one tool, use `bundle exec rubocop -a [tool_name]`

### Test the changes for your application

After introducing some changes to the _fastlane_ source code, you probably want to test the changes for your application.

Copy the Gemfile [.assets/Gemfile](.assets/Gemfile) from your local _fastlane_ clone and drop it into your project's root folder.

Make sure to replace `<PATH_TO_YOUR_LOCAL_FASTLANE_CLONE>` with the path to your _fastlane_ clone, e.g. `~/fastlane`, then you can run
```
bundle update
```
in your project’s root directory. After doing so, you can verify you’re using the local version by running

```
bundle show fastlane
```

which should print out the path to your local development environment.

From now on, every time you introduce a change to your local _fastlane_ code base, you can immediately test it by running `bundle exec fastlane …`. (Note that just using `fastlane …` without `bundle exec` will **not** use your local _fastlane_ code base!)

If you want to run a command with your normal _fastlane_ installation, simply do not run the command with the `bundle exec` prefix.

To fully remove your local _fastlane_ from your local project again, delete the `Gemfile` you created above.


## Submitting the PR

When the coding is done and you’re finished testing your changes, you are ready to submit the PR to the [_fastlane_ main repo][fastlane]. Everything you need to know about submitting the PR itself is inside our [Pull Request Template][pr template]. Some best practices are:

- Use a descriptive title
- Link the issues that are related to your PR in the body

## After the review

Once a core member has reviewed your PR, you might need to make changes before it gets merged. To make it easier on us, please make sure to avoid using `git commit --amend` or force pushes to make corrections. By avoiding rewriting the commit history, you will allow each round of edits to become its own visible commit. This helps the people who need to review your code easily understand exactly what has changed since the last time they looked. Feel free to use whatever commit messages you like, as we will squash them anyway. When you are done addressing your review, also add a small comment like “Feedback addressed @<your_reviewer>”.

_fastlane_ changes a lot and is in constant flux. We usually merge multiple PRs per day, so sometimes when we are done reviewing, your code might not work with the latest master branch anymore. To prevent this, before you make any changes after your code has been reviewed, you should always rebase the latest changes from the master branch.

After your contribution is merged, it’s not immediately available to all users. Your change will be shipped as part of the next release, which is usually once per week. If your change is time critical, please let us know so we can schedule a release for your change.

<!-- Links -->
[you can do this]: https://github.com/fastlane/fastlane/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+label%3A%22complexity%3A+you+can+do+this%22+
[fastlane]: https://github.com/fastlane/fastlane
[pr template]: .github/PULL_REQUEST_TEMPLATE.md
[bundler]: https://bundler.io
[bundler help]: https://bundler.io/v1.12/#getting-started
