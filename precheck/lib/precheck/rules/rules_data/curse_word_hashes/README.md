# Updating Curse Word Hashes for `fastlane precheck`

## What does `precheck/rules/curse_words_rule` do?

It uses the metadata fetched from the App Store by _precheck_ and reviews it word by word, failing if it matches one of the committed terms. 

## What Terms to Hash

According to "Want to improve precheck's rules?" in [precheck's docs](https://docs.fastlane.tools/actions/precheck/), phrases flagged by a reviewer in your recent App Store Rejection.

## Format

These phrases are committed in repo under https://github.com/fastlane/fastlane/tree/master/precheck/lib/precheck/rules/rules_data/curse_word_hashes as sha 256 digest (one way hash).

### Before Generating

Make sure the term you are adding is:
1. A single word phrase
2. In all lowercase letters
3. Void of punctuation 

This criteria mimics the transformations performed on the input data that is getting checked in https://github.com/fastlane/fastlane/tree/master/precheck/lib/precheck/rules/curse_words_rule.rb

### Generating a New Hash

```rb
irb(main):001:0> require 'digest'
=> true
irb(main):002:0> new_term_to_add = "oneword"
=> "oneword"
irb(main):003:0> Digest::SHA256.hexdigest(new_term_to_add)
=> "31be3624bc03aa68bc050cce316dc80cfe1ace3d0f58fa5f5b20c9e781c44a07"
irb(main):004:0> 
```

Append this to the end of the file (with a newline afterward).

## How to Test Your Newly Added Term

### Hack at the unit tests to include your phrase

Update the tests in https://github.com/fastlane/fastlane/blob/master/precheck/spec/rules/curse_words_rule_spec.rb to include your new phrase.

```diff
      let(:happy_item) { TextItemToCheck.new("tacos are really delicious, seriously, I can't even", :description, "description") }
-     let(:curse_item) { TextItemToCheck.new("please excuse the use of 'shit' in this description", :description, "description") }
+     let(:curse_item) { TextItemToCheck.new("please excuse the use of 'oneword' in this description", :description, "description") }

      it "passes for non-curse item" do
```

### Update your App's listing and run pre-check

Add your term to your App's description or keywords and run `bundle exec fastlane precheck` to ensure that it fails the check.
