# Prepare and upload new device frames

Starting in October 2016 we are now using the [Facebook frameset](https://design.facebook.com/toolsandresources/devices/) and hosting the device frame resources since Apple sometimes has removed / changed some of the old images making framing a moving target.

To run the wizard to prepare new device assets, just run `rake` in this directory.

There is a `legacy` directory in this directory that contains frames that have been removed from Facebook's frameset but are still needed by users

You will need to run this wizard every time you want update the device assets

This will generate 2 directories:

- The timestamp based one which is used if the user specifies a particular version in their Framefile
- The the most recent one which will be used by default

Both directories should be uploaded to [github.com/fastlane/frameit-frames](https://github.com/fastlane/frameit-frames).
