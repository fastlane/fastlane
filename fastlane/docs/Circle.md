# fastlane circle config

To run fastlane on Circle as your CI, first create a `Gemfile` in the root of your project with the following content

```ruby
source "https://rubygems.org"

gem "fastlane"
```

and run

```
gem install bundler && bundle update
```

This will create a `Gemfile.lock`, that defines all Ruby dependencies. Make sure to commit both files to version control.

Next, use the following `circle.yml` file

```yml
machine:
  xcode:
    version: "7.3"
dependencies:
  override:
    - bundle check --path=vendor/bundle || bundle install --path=vendor/bundle --jobs=4 --retry=3 --without development
  cache_directories:
    - vendor/bundle
test:
  override:
    - bundle exec fastlane test
```

This will automatically cache the installed gems on Circle, making your CI builds much faster :rocket:
