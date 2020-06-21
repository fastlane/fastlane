---
name: ‼️ Release Candidate (Deliver) Issue (2.150.0.rc1)
about: This is a temporary but highly imporant issue for the 2.150.0 release candidate

---

<!-- Thanks for helping _fastlane_! Before you submit your issue, please make sure to check the following boxes by putting an x in the [ ] (don't: [x ], [ x], do: [x]) -->

### New Release Candidate Issue Checklist

- [ ] Updated fastlane to the latest release candidate version (2.150.0.rcX)
- [ ] I read the [Contribution Guidelines](https://github.com/fastlane/fastlane/blob/master/CONTRIBUTING.md)
- [ ] I read [docs.fastlane.tools](https://docs.fastlane.tools)
- [ ] I searched for [existing GitHub issues](https://github.com/fastlane/fastlane/issues)

### Issue Information
<!-- Knowing the breaking versions and last working versions helps us track down the regression easier -->
- Breaking version: [e.g. `2.x.x`]
- Last working version: [e.g. `2.x.x`]
- State of app: [e.g. `Prepare for Submission`, `Developer Rejected`]
- First version of app?: [e.g. `Yes`]

### Issue Description
<!-- Please include what's happening, expected behavior, and any relevant code samples -->

##### Complete output when running fastlane, including the stack trace and command used
<!-- You can use: `--capture_output` as the last commandline argument to get that collected for you -->

<!-- The output of `--capture_output` could contain sensitive data such as application ids, certificate ids, or email addresses, Please make sure you double check the output and replace anything sensitive you don't wish to submit in the issue -->

<details>
  <pre>[INSERT OUTPUT HERE]</pre>
</details>

### Spaceship Logs
<!-- Having logs of the API requets that Spaceship made can help in solving issues -->
<!-- Run `bundle exec fastalane run spaceship_logs copy_to_clipboard:true` to copy the latest Spaceship logs and past below -->

<details>
  <pre>[INSERT OUTPUT HERE]</pre>
</details>

### Environment

<!-- Please run `fastlane env` and copy the output below. This will help us help you :+1:
If you used `--capture_output` option, please remove this block as it is already included there. -->

<details>
  <pre>[INSERT OUTPUT HERE]</pre>
</details>

### Mentioning
<!-- Mentioning @joshdholtz so he gets a notification of this as soon as its created -->
cc: @joshdholtz
