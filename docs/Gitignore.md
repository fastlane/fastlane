## Gitignore

If you use git, it is recommended to keep the `fastlane` configuration files in your repository. You may want to add the following lines to your `.gitignore` file to exclude some generated and temporary files:

```sh
# fastlane specific
fastlane/report.xml

# deliver temporary files
fastlane/Preview.html

# snapshot generated screenshots
fastlane/screenshots

# scan temporary files
fastlane/test_output
```

It is recommended to not store the screenshots in the git repo. Instead, use fastlane to re-generate the screenshots whenever they are needed.
