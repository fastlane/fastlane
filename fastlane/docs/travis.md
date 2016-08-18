# fastlane Travis config

To run fastlane on Travis as your CI, first create a `Gemfile` in the root of your project with the following content

```ruby
source "https://rubygems.org"

gem "fastlane"
```

and run

```
gem install bundler && bundle update
```

This will create a `Gemfile.lock`, that defines all Ruby dependencies. Make sure to commit both files to version control.

Next, use the following `.travis.yml` file

```yml
language: objective-c
osx_image: xcode7.3
before_install:
  bundle check --path=vendor/bundle || bundle install --path=vendor/bundle --jobs=4 --retry=3 --without development
script: bundle exec fastlane test
```
