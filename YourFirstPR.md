# Your first PR


## Finding things to work on


The core team usually tags issues that are ready to be worked on and easily accessible for new contributors with the [“you can do this” label][you can do this]. If you’ve never contributed to _fastlane_ before, these are a great start!


If you want to work on something else, e.g. new functionality or fixing a bug, we kindly ask you to submit a new issue, so that we can have a chance to discuss it first. We might have some pointers for you on how to get started, or how to best integrate it with existing solutions.


## Checking out the fastlane repo


- Click the “fork” button in the upper right corner of the [main fastlane repo][fastlane]
- Clone your fork:
  - `git clone <YOUR_GITHUB_USER> git@github.com:<YOUR_GITHUB_USER>/fastlane.git`
- Create a new branch to work on:
  - `git checkout -b <YOUR_BRANCH_NAME>`
  - A good name for a branch describes the thing you’ll be working on, e.g. `docs-fixes`, `fix-deliver-upload`, `gym-build-android-app`, etc.
- That’s it! Now you’re ready to work on fastlane 


## Testing your local changes


Make sure to run the automated tests using `bundle exec` to ensure you’re running the correct version of `rspec` and `rubocop`


First, navigate into the sub-directory of the tool you want to test.


To run the automated unit tests


```
bundle exec rspec
```


To verify and auto-fix the code style


```
bundle exec rubocop -a
```


After introducing some changes to the _fastlane_ source code, you probably want to test the changes for your application. The easiest way to do so it use [bundler](https://bundler.io/).

Copy the Gemfile [.assets/Gemfile](.assets/Gemfile) from your local fastlane clone and drop it into your project's root folder.

Make sure to change the `local_fastlane_path` variable to point to your fastlane clone, e.g. `~/fastlane`, then you can run
```
bundle update
```
in your project’s root directory. After doing so, you can verify you’re using the local version by running

```
bundle show fastlane
```

which should print out the path to your local development environment.

From now on, every time you introduce a change to your local _fastlane_ code base, you can immediately test it by running `bundle exec fastlane …`


## Submitting the PR


When the coding is done and you’re finished testing your changes, you are ready to submit the PR to the [fastlane main repo][fastlane]. Everything you need to know about submitting the PR itself is inside our [Pull Request Template][pr template]. Some best practices are:


- Create a separate PR for each tool that you’ve worked on
- Use a descriptive title 
- Link the issues that are related to your PR in the body


## After the review


Once a core member has reviewed your PR, you might need to make changes before it gets merged. To make it easier on us, please make sure to avoid using `git commit --amend` and force pushes so that only the changes you did after the review will be visible on GitHub. Feel free to use whatever commit messages you like, as we will squash them anyway. When you are done addressing your review, also add a small comment like “Feedback addressed @<your_reviewer>”. 


_fastlane_ changes a lot and is in constant flux. We usually merge multiple PRs per day, so sometimes when we are done reviewing, your code might not work with the latest master branch anymore. To prevent this, before you make any changes after your code has been reviewed, you should always rebase the latest changes from the master branch.


After your contribution is merged, it’s not immediately available to all users. Your change will be shipped as part of the next release, which is usually once per week. If your change is time critical, please let us know so we can schedule a release for your change.


<!-- Links -->
[you can do this]: https://github.com/fastlane/fastlane/issues?utf8=✓&q=is%3Aopen%20is%3Aissue%20label%3A%22you%20can%20do%20this%22%20
[fastlane]: https://github.com/fastlane/fastlane
[pr template]: .github/PULL_REQUEST_TEMPLATE.md
