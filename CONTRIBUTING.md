# Contributing to `fastlane`

To clone the [fastlane](https://fastlane.tools) repos, use the [countdown](https://github.com/fastlane/countdown) repo. It will help you set up the development environment within minutes.

1. Create an issue to discuss about your idea.
2. Fork it (https://github.com/fastlane/fastlane/tree/master/fastlane).
3. Create your feature branch (`git checkout -b my-new-feature`).
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create a new Pull Request.

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

If you're motivated to help out at a level beyond reporting issues, we really appreciate it! :+1: A good place to start is by reviewing the list of [open issues](https://github.com/fastlane/fastlane/issues) or [open PRs](https://github.com/fastlane/fastlane/tree/master/fastlane) for things that need attention. When you find one that you'd like to help with, the [countdown](https://github.com/fastlane/countdown) repo is the best way to get set up with the source code for all of the fastlane projects. With that, working on the following things are super valuable:

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

Pull requests are always welcome :simple_smile:

If you're working on fixing a particular issue, referring to it in the description of your PR is really helpful for establishing the context needed for review.

If your PR is contributing new functionality, did you create an issue to discuss it with the community first? Great! :raised_hands: Reference that issue in your PR.

**Pro tip:** GitHub will automatically turn references to issue numbers in the form `#1234` into a link to the issue/PR with that number within the same repo.

- Adding automated tests that cover your changes and/or new functionality is important!
    - `fastlane` has a lot of moving parts and receives contributions from many developers. The best way to ensure that your contributions keep working is to ensure that there will be failing tests if something accidentally gets broken.
    - You can run the tests by executing `bundle install` and then `bundle exec rspec`.
- Your code editor should indent using spaces with a tab size of 2 spaces.

## Why Did My Issue/PR Get Closed?

It's not you, it's us! fastlane and its related tools receive a lot of issues and PRs. In order to effectively work through them and give each the prompt attention it deserves, we need to keep a sharp focus on the work we have outstanding.

One way we do this is by closing issues that we don't feel are immediately actionable. This might mean that we need more information in order to investigate (Have you provided enough information for us to reproduce the problem? The [New Issues](#new-issues) section has the details!). Or, it might mean that we haven't been able to reproduce it using the provided info. In this case we might close the issue while we wait for others to reproduce the problem and possibly provide some more info that unlocks the mystery.

In any case, **a closed issue is not necessarily the end of the story!** If more info becomes available after an issue is closed, it can be reopened for further consideration.

One of the best ways we can keep fastlane an approachable, stable, and dependable tool is to be deliberate about how we choose to modify it. If we don't adopt your changes or new feature into fastlane, that doesn't mean it was bad work! It may be that the fastlane philosophy about how to accomplish a particular task doesn't align well with your approach. The best way to make sure that your time is well spent in contributing to fastlane is to **start your work** on a modification or new feature **by opening an issue to discuss the problem or shortcoming with the community**. The fastlane maintainers will do our best to give early feedback about whether a particular goal and approach is likely to be something we want to adopt!

## Contributing New Actions

Writing a custom action is an easy way to extend the capabilities of fastlane. Actions that make good candidates for inclusion in the fastlane codebase are **flexible** and apply to **many projects, teams, and development setups**. Before working to contribute your custom action to fastlane, consider whether it is likely to solve a problem that many developers have. If not, it can still provide value for your fastlane environment! Check out the documentation for creating [local action extensions](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/README.md#extensions).

# Above All, Thanks for Your Contributions

Thank you for reading to the end, and for taking the time to contribute to the project! If you include the 🔑 emoji at the top of the body of your issue or pull request, we'll know that you've given this your full attention and are doing your best to help!
