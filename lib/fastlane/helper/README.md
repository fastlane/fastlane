### fastlane Helper

You can put shared code into this folder. Use this if you need to access the same code from multiple actions or to just clean up the actual action.

To create a new helper, duplicate the `podspec_helper.rb`, rename the class and put your code inside the class. 

Make sure it's structured like this:

```ruby
module Fastlane
  module Helper
    class PodspecHelper
      ...
    end
  end
end
```

The `git_helper` and `sh_helper` are different, please make sure to build something like `podspec_helper`.

### Use of the helper class

To access the helper class use

```ruby
Helper::PodspecHelper....
```

Make sure to prefix your helper with the `Helper::` module.
