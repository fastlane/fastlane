# Contributing to _fastlane_

## I want to report a problem or ask a question

Before submitting a new GitHub issue, please make sure to

- Check out [docs.fastlane.tools](https://docs.fastlane.tools)
- Check out the README pages on [this repo](https://github.com/fastlane/fastlane)
- Search for [existing GitHub issues](https://github.com/fastlane/fastlane/issues)

If the above doesn't help, please [submit an issue](https://github.com/fastlane/fastlane/issues) on GitHub and provide information about your setup, in particular the output of the `fastlane env` command.

**Note**: If you want to report a regression in _fastlane_ (something that has worked before, but broke with a new release), please mark your issue title as such using `[Regression] Your title here`. This enables us to quickly detect and fix regressions.

Some people might also use the [_fastlane_ tag on StackOverflow](https://stackoverflow.com/questions/tagged/fastlane), however we don’t actively monitor issues submitted there.

## I want to contribute to _fastlane_

- To start working on _fastlane_, check out [YourFirstPR.md][firstpr]
- You will need a Google account to sign the CLA when you make your first PR
- For some more advanced tooling and debugging tips, check out [ToolsAndDebugging.md](ToolsAndDebugging.md)

### New Actions

Please be aware that we don’t accept submissions for new actions at the moment. You can find more information about that [here][submit action].

## I want to help work on _fastlane_ by reviewing issues and PRs

Thanks! We would really appreciate the help! Feel free to read our document on how to [respond to issues and PRs][responding to prs] and also check out how to become a [core contributor][core contributor].

## Why did my issue/PR get closed?

It's not you, it's us! _fastlane_ and its related tools receive a lot of issues and PRs. In order to effectively work through them and give each the prompt attention it deserves, we need to keep a sharp focus on the work we have outstanding.

One way we do this is by closing issues that we don't feel are immediately actionable. This might mean that we need more information in order to investigate. Or, it might mean that we haven't been able to reproduce it using the provided info. In this case we might close the issue while we wait for others to reproduce the problem and possibly provide some more info that unlocks the mystery.

<a id="fastlane-bot"/>

Another way we do this is by having an [automated bot](https://github.com/fastlane/issue-bot) go through our issues and PRs. The main goal of the bot is to ensure that the issues are still relevant and reproducible. Issues can be opened, and later fall idle for a variety of reasons:

* The user later decided not to use _fastlane_
* A workaround was found, making it a low priority for the user
* The user changed projects and/or companies
* A new version of _fastlane_ has been released that fixed the problem

No matter the reason, the _fastlane_ bot will ask for confirmation that an issue is still relevant after two months of inactivity. If the ticket becomes active again, it will remain open. If another 10 days pass with no activity, however, the ticket will be automatically closed.

In any case, **a closed issue is not necessarily the end of the story!** If more info becomes available after an issue is closed, it can be reopened for further consideration.

One of the best ways we can keep _fastlane_ an approachable, stable, and dependable tool is to be deliberate about how we choose to modify it. If we don't adopt your changes or new feature into _fastlane,_ that doesn't mean it was bad work! It may be that the _fastlane_ philosophy about how to accomplish a particular task doesn't align well with your approach. The best way to make sure that your time is well spent in contributing to _fastlane_ is to **start your work** on a modification or new feature **by opening an issue to discuss the problem or shortcoming with the community**. The _fastlane_ maintainers will do our best to give early feedback about whether a particular goal and approach is likely to be something we want to adopt!

## Code of Conduct

Help us keep _fastlane_ open and inclusive. Please read and follow our [Code of Conduct][code of conduct].

## Branding

We have a few guidelines for how to refer to _fastlane_ and its tools:

- _fastlane_ and its actions should be written in all lowercase, even at the beginning of a sentence:
    - ❌ "Use Fastlane to automate your screenshots."
    - ❌ "Use _Fastlane_ to automate your screenshots."
    - ❌ "Fastlane helps you deliver faster."
    - ❌ "Match makes code signing management easy."
    - ✅ "Use _fastlane_ to automate your screenshots."
    - ✅ "_fastlane_ helps you deliver faster."
    - ✅ "_match_ makes code signing management easy."
- _fastlane_ and all of its actions should be italicized when written in prose:
    - ❌ "`fastlane` is an all-in-one tool for app automation."
    - ❌ "**fastlane** is an all-in-one tool for app automation."
    - ❌ "fastlane is an all-in-one tool for app automation."
    - ❌ "<ins>fastlane</ins> is an all-in-one tool for app automation."
    - ❌ "`match` makes code signing management easy."
    - ✅ "_fastlane_ is an all-in-one tool for app automation."
    - ✅ "_match_ makes code signing management easy."

Please use these guidelines when writing about _fastlane_ and its tools, be it when contributing to the project or writing about it elsewhere.

## Above All, Thanks for Your Contributions

Thank you for reading to the end, and for taking the time to contribute to the project! If you include the 🔑 emoji at the top of the body of your issue or pull request, we'll know that you've given this your full attention and are doing your best to help!

## License

This project is licensed under the terms of the MIT license. See the [LICENSE][license] file.

> This project and all _fastlane_ tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All _fastlane_ tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use _fastlane_ tools.

<!-- Links: -->
[code of conduct]: CODE_OF_CONDUCT.md
[core contributor]: CORE_CONTRIBUTOR.md
[license]: LICENSE
[tools and debugging]: ToolsAndDebugging.md
[vision]: VISION.md
[responding to prs]: RespondingToIssuesAndPullRequests.md
[plugins]: https://docs.fastlane.tools/plugins/create-plugin/
[firstpr]: YourFirstPR.md
[submit action]: https://docs.fastlane.tools/plugins/create-plugin/#submitting-the-action-to-the-fastlane-main-repo
