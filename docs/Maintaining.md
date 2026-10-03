# Maintaining _fastlane_

## Core contributors

We believe that our most valuable resource is the passionate community members who keep _fastlane_ running. We are always looking for active, enthusiastic members of the _fastlane_ community to become core contributors. We hope to harness the diverse experiences of our community to optimize _fastlane_ as the de facto tool to deploy betas and releases for iOS and Android apps.

### How does one become a core contributor?
Contributors who have displayed lasting commitment to the evolution and maintenance of _fastlane_ will be invited to become core contributors. For instance, contributors who:
- Love to help out other users with issues on GitHub
- Continue to make _fastlane_ a stable product and encourage features aligned with the [_fastlane_ vision](VISION.md)

### As core contributors, we:
- Review pull requests using the "Review Changes" feature in GitHub
- Merge pull requests we review, except for PRs where the author has push access. Push access to _fastlane_ repos is noted in GitHub with the `Member` tag. Merge PRs using the "Squash and Merge" feature in GitHub
- Respond to issues and help others
- Own regressions caused by our own contributions and PR approvals
- Maintain consistent coding standards
- Inform maintainers when critical fixes are merged so a release can be prepared
- Identify other _fastlane_ community members who would be effective core contributors
- Make _fastlane_ the best open source tool and community out there

### While doing these things, we make sure to:
- Ensure that new contributions fit into the [_fastlane_ vision](VISION.md)
- Adhere to the [_fastlane_ Code of Conduct](CODE_OF_CONDUCT.md)
- Maintain backwards compatibility
- Keep external dependencies to a minimum
- Keep test coverage high and ensure up-to-date documentation

### Pull Request Ownership:
We work in a high-trust environment which implies that anyone and everyone is able to merge pull requests from the community. If the PR reviewer feels strongly about seeing a PR to completion, they should assign it to themselves and request necessary changes.

### Adding Dependencies:
We want to keep _fastlane_ slim and robust. Please avoid adding new dependencies to the code base unless it is necessary. In the event that a PR does add a dependency, please ping a member of the _fastlane_ team to approve the pull request.

### Being friendly and supportive

__Most Importantly__, our community prides itself in our supportive and friendly attitude. Above all else, we are always:

- Polite
- Friendly
- Having fun
- Encouraging the use of emojis 🚀

## Responding to issues and PRs

### How we treat each other

When replying to issues and PRs, make sure you always follow our [Code of Conduct](CODE_OF_CONDUCT.md) and our [vision for fastlane](VISION.md). Make sure to read these thoroughly and understand them before you interact with any other users! In general, be nice to each other, and treat **everyone** with the same respect and dignity.

Also, whenever you submit a comment, don’t ask users for their personal information or account credentials.

### How we use GitHub Labels

Issues and PRs may get marked with labels to help the fastlane team communicate with each other and with the community as a whole. Usually most issues and PRs will get two different labels, one for the tool it affects (e.g. _fastlane_, `fastlane_core`, _supply_, ...) and one that represents some general information about the state or nature of the issue/PR.

If you identify an issue that seems interesting but not time-critical, and is simple for new contributors to dive into, we recommend adding the “you can do this” label. PRs labeled “you can do this” should have very clear descriptions of the problem and solution. Remember that someone who is new to fastlane will need some coaching to be successful!

#### Workflow Labels

| Label           | Meaning                                                                                                |
|-----------------|--------------------------------------------------------------------------------------------------------|
| action          | Applies to a fastlane action (e.g. `get_build_number`)                                                 |
| awaiting-reply  | The fastlane team is engaged in discussion, but is currently waiting for a response from the community |
| blocked         | We don't currently have a way forward, though we'd like to continue if possible                        |
| bug             | We've acknowledged the issue as a defect                                                               |
| duplicate       | Another issue/PR already exists that we think captures the problem/request                             |
| feature         | The issue represents a request for an enhancement or new feature                                       |
| you can do this | We're not actively looking at solving this issue, but community help would be appreciated              |
| question        | Someone is looking for help, but isn't describing a problem with the software                          |

#### Tool Labels

Each tool has its own label, e.g. _fastlane_, `fastlane_core` and _gym_.

### How to review Pull Requests

#### Recommended setup for testing the code

- Clone the _fastlane_ repository by running  `git clone git@github.com:fastlane/fastlane.git` in your terminal
- For each PR you want to review, make sure to add the user’s fork as a remote
  - `git remote add <GITHUB_USERNAME> git@github.com:<GITHUB_USERNAME>/fastlane.git`
- Then, check out the branch for the user’s PR
  - Fetch all their branches `git fetch <GITHUB_USERNAME>`
  - Checkout the branch for the PR `git checkout <THEIR_PR_BRANCH>`
  - Sometimes, changes have to be split over multiple PRs - one for each tool. In that case, it is often easier to test all the changes together. To do that, create a new branch that merges all their changes:
    - Create a new branch to merge the others into `git checkout -b my_new_branch`
    - Merge the branch from one PR `git pull --rebase <GITHUB_USERNAME> <THEIR_PR_BRANCH>`
    - Repeat the last step for each of the related PRs that the user submitted.
- After checking out a user’s code, you should always make sure that the tests are still working.
  - Run `bundle install` to make sure all dependencies are installed
  - Use `bundle exec fastlane test` from the root directory to run all validation steps (tests, rubocop, etc)
  - Use `bundle exec rspec` from the root directory to run all tests
  - Use `bundle exec rspec [tool_name]` to run all tests for a specific tool
  - Use `bundle exec rubocop -a` to run the linter and autocorrect many of the issues it found

If you have commit access, instead of adding each person's fork as a remote, you can also quickly test a single PR with the following commands:

```
git fetch origin pull/1234/head:pr-1234
git checkout pr-1234
```

Or if you have GitHub CLI use - `gh pr checkout 1234`

#### Using your _fastlane_ clone in a project

First of all, since we are testing code that is considered bleeding edge and might not be stable yet, make sure to **never test with an account that is provided by your employer and/or real, live apps!** Things might break irrevocably! For that reason, we recommend setting up an entirely new account and project for testing _fastlane_ PRs.

Then follow [Testing.md](Testing.md#test-your-local-fastlane-code-base-with-your-setup) to point the project at your clone.

#### Reviewing the Code

Before diving into the source code changes of a pull request, step back and think if this change is a good change for _fastlane_, and that it follows the [fastlane vision](VISION.md). If you are not 100% certain that a pull request adds good value to _fastlane_, ask the author to clarify on why this should be included in the main code base, referring to the [Vision.md document](VISION.md). Sometimes it is also more appropriate for new features to be submitted as plugins, for example if the features are not applicable to a wide audience [as described here](../fastlane/docs/Plugins.md#submitting-the-action-to-the-fastlane-main-repo). In that case, make sure to also include a link to the [plugin documentation](../fastlane/docs/Plugins.md).

To review the code, start a new review on GitHub by going to the “Files changed” tab on the PR page. You can then add comments by tapping on the plus that appears when your mouse hovers over a line. Instead of submitting multiple comments one after another, use the `Start Review` button, so that participants don’t get flooded with multiple notifications.

When adding comments to a review, make sure they are
- *Polite*: Ask the author nicely to make the changes. We want to create an environment where our contributors like working with us and come back to submit more PRs
- *Constructive*: Don’t just say ‘This is bad’ or ‘I don’t like this’. Point the author in the right direction for changes they need to make to improve the code
- *Necessary*: It is often too easy to ask for changes on perfectly fine code because of personal opinions. If the change follows our vision, adheres to our style guides and is simple to understand, don’t ask the author to change it! You can always make follow-up on a merged PR with improvements of your own.
