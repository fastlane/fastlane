## Gitignore

If you use git, it is recommended to keep the `fastlane` configuration files in your repository. You may want to add the following lines to your `.gitignore` file to exclude some generated and temporary files:

```sh
# fastlane specific
fastlane/report.xml

# deliver temporary files
fastlane/Preview.html

# snapshot generated screenshots
fastlane/screenshots/*/*-portrait.png
fastlane/screenshots/*/*-landscape.png
fastlane/screenshots/screenshots.html

# frameit generated screenshots
fastlane/screenshots/*/*-portrait_framed.png
fastlane/screenshots/*/*-landscape_framed.png

# scan temporary files
fastlane/test_output
```
