<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Gitignore](#gitignore)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Gitignore

If you use git, it is recommended to keep the `fastlane` configuration files in your repository. You may want to add the following lines to your `.gitignore` file to exclude some generated and temporary files:

```sh
# fastlane specific
fastlane/report.xml

# deliver temporary files
fastlane/Preview.html

# snapshot generated screenshots
fastlane/screenshots/**/*.png
fastlane/screenshots/screenshots.html

# scan temporary files
fastlane/test_output
```

It is recommended to not store the screenshots in the git repo. Instead, use fastlane to re-generate the screenshots whenever they are needed.
