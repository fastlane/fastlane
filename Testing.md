# Testing _fastlane_

## Testing your local changes

### Checking it all

The `Fastfile` included at the top of the fastlane project allows you to run several validation steps, such as automated tests, code style and more.

```
bundle exec fastlane test
```

You can also run those steps independently or on a more fine-grained way.

### Automated tests

Make sure to run the automated tests using `bundle exec` to ensure you’re running the correct version of `rspec` and `rubocop`.

#### All unit tests

First, navigate into the root of the _fastlane_ project and run all unit tests using

```
bundle exec rake test_all
```

You can also invoke rspec directly

```
bundle exec rspec
```

The test execution sends all standard output to a random temporary file. Prefix the command line with `DEBUG= ` to print out the output instead. E.g. `DEBUG= bundle exec rspec`

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

Replace `./fastlane/spec/fastlane_require_spec.rb` with the path of your test file of course.

#### Specific unit test (group) in a specific test file

If you know the specific unit test or unit test group you want to run, use

```
bundle exec rspec ./fastlane/spec/fastlane_require_spec.rb:17
```

The number is the line number of the unit test (`it ... do`) or unit test group (`describe ... do`) you want to run.

Instead of using the line number you can also use a filter with the `it "something", now: true` notation and then use `bundle exec rspec -t now` to run this tagged test. (Note that `now` can be any random string of your choice.)

#### Running the suite as several processes

The suite is a lot faster split across processes, and a split is also a harsher test than any seed: a worker gets a subset no random order produces, so a spec that depends on another file having run first fails there.

```
bundle exec rake test_parallel
```

`WORKERS` overrides the worker count, which otherwise is `min(cores, 8)`:

```
WORKERS=12 bundle exec rake test_parallel
```

`RSPEC_ARGS` is passed through to each worker, so the two axes can be combined:

```
RSPEC_ARGS="--order random" WORKERS=4 bundle exec rake test_parallel
```

When a worker fails, the task prints which examples failed and the path to a file listing exactly what that worker ran, so the split can be replayed:

```
rspec $(cat rspec_worker_0.units)
```

To find the best worker count for your machine:

```
bundle exec rake test_tune
```

The split is balanced from recorded per file durations. The files committed here were measured on the CI runners, and they describe those machines rather than yours: a laptop with many more cores gets a worse split from them than from the file size fallback. Record your own with

```
bundle exec rake spec_timings
```

#### Running against a throwaway home directory

The suite reads and writes your real home directory, and reads state left there by earlier runs. That is the failure mode that only shows up on someone else's machine, or on a clean CI checkout.

```
bundle exec rake test_isolated
bundle exec rake "test_isolated[spaceship/spec]"
```

It points `HOME` at a temporary directory, seeds a keychain on macOS, reports what the run wrote into it, and removes it.

#### Guards against leaking state between examples

Two guards run by default and report specs that leave state behind.

The environment guard restores `ENV` after each example and names every variable that escaped:

```
FASTLANE_SPEC_ENV_GUARD=report bundle exec rspec     # report, restore nothing
FASTLANE_SPEC_ENV_GUARD=off bundle exec rspec        # disable
FASTLANE_SPEC_ENV_GUARD_REPORT=leaks.txt bundle exec rspec
```

An example that is meant to leave something behind declares it:

```ruby
it "sets the team id", env_output: %w[FASTLANE_TEAM_ID] do
```

The singleton guard clears the tools' module level configuration after each example, so a spec that reads configuration it never set fails rather than inheriting it:

```
FASTLANE_SPEC_SINGLETON_GUARD=off bundle exec rspec
```

#### Ensuring all tests run independently

If you want to check if all the tests in the test suite can be run independently, use

```
bundle exec rake test_all_individually
```

#### Troubleshoot flickering tests

If your tests fail randomly, pass extra arguments to `test_all` and `test_all_individually` using the environment variable `RSPEC_ARGS` to isolate the test failures and reproduce them.

Here are some examples.

Randomize the order of tests for the full suite:
```
RSPEC_ARGS="--order rand" bundle exec rake test_all
```

A randomized run reports the seed it used twice, once as it starts and again as its last line:

```
Randomized with seed 8347
```

That number is what makes the run repeatable. Passing it back replays the same order, so a failure that only happens in one order can be reproduced rather than waited for:

```
RSPEC_ARGS="--seed 8347" bundle exec rake test_all
```

A seed only pins the order. A failure that depends on something outside the process, such as a file an earlier run left in your home directory, reproduces on your machine and not on a colleague's whatever seed you use. `rake test_isolated` above is for that case.

Run each test file independently and randomize within each run:
```
RSPEC_ARGS="--bisect random" bundle exec rake test_all_individually
```

Run the specific tests in bisect mode with a given seed:
```
bundle exec rspec --seed 1234 bisect your/list/of/tests.rb
```

If `plugin_generator_spec` fails with a bare `expected 0, got 1` and no other detail, that is usually not a real failure. The plugin template's `.rubocop.yml` is generated and gitignored, so a working copy can be left holding one from an older _fastlane_, and the generated plugin's gemspec and rubocop config then disagree about the Ruby version. `bundle exec rake prepare_rubocop_config` regenerates it, and the test tasks run that first so it should not happen.

For more information, see [rspec command line documentation](https://rspec.info/features/3-13/rspec-core/command-line/)


### Code style

To verify and auto-fix the code style

```
bundle exec rubocop -a
```

If you want to run code style verification only for one tool, use `bundle exec rubocop -a [tool_name]`

### FastlaneSwiftRunner

If you'd like to see your changes reflect on `FastlaneSwiftRunner`, the Swift set of APIs, you need to update the auto-generated Swift APIs locally. You can do that by running `bundle exec fastlane generate_swift_api`. Once this is done, you can [test your local _fastlane_ code base with your setup](#test-your-local-fastlane-code-base-with-your-setup).

Do not commit the changes generated by the `generate_swift_api` command, as this is part of the release process of a new version of _fastlane_, so your PR shouldn't include those changes.

If you need to see any output from FastlaneSwiftRunner, activate the flag `--verbose` when launching `FastlaneSwiftRunner` or any of its lanes.

Remember that to debug `FastlaneSwiftRunner` on Xcode, you can set a flag to wait for the executable to be launched by _fastlane_. You can go to next path and set a tick on Scheme → `FastlaneSwiftRunner` → Run → Launch → Wait for the executable to be launched.

<!-- Make sure that this section is the same as the one in `ToolsAndDebugging.md` -->

## Test your local _fastlane_ code base with your setup

After introducing some changes to the _fastlane_ source code, you probably want to test the changes for your application. The easiest way to do so it use [bundler](https://bundler.io/).

Edit your `Gemfile` in your project's root folder and replace the `gem 'fastlane'` line with:

```
gemspec path: File.expand_path("<PATH_TO_YOUR_LOCAL_FASTLANE_CLONE>")
```

If you don't have a `Gemfile` yet, copy the `Gemfile` [.assets/Gemfile](.assets/Gemfile) from your local _fastlane_ clone and drop it into your project's root folder.

Make sure to replace `<PATH_TO_YOUR_LOCAL_FASTLANE_CLONE>` with the path to your _fastlane_ clone, e.g. `~/fastlane`, then you can run

```
bundle update
```

in your project’s root directory. After doing so, you can verify you’re using the local version by running

```
bundle info fastlane
```

which should print out the path to your local development environment.

From now on, every time you introduce a change to your local _fastlane_ code base, you can immediately test it by running `bundle exec fastlane …`. (Note that just using `fastlane …` without `bundle exec` will **not** use your local _fastlane_ code base!)

If you want to run a command with your normal _fastlane_ installation, simply do not run the command with the `bundle exec` prefix.

To completely remove _fastlane_ from your local project, delete the `Gemfile` you created earlier, or undo the changes you made to match the `Gemfile` template.
