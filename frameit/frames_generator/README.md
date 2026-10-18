# Prepare and upload new device frames

Starting in October 2016 we are now using the [Facebook frameset](https://design.facebook.com/toolsandresources/devices/) and hosting the device frame resources since Apple sometimes has removed / changed some of the old images making framing a moving target.

To run the wizard to prepare new device assets, just run `rake` in this directory.

There is a `legacy` directory in this directory that contains frames that have been removed from Facebook's frameset but are still needed by users

You will need to run this wizard every time you want update the device assets

This will generate 2 directories:

- The timestamp based one which is used if the user specifies a particular version in their Framefile
- The the most recent one which will be used by default

Both directories should be uploaded to [github.com/fastlane/frameit-frames](https://github.com/fastlane/frameit-frames).

## iPhone Duo

_frameit_ recognizes the outer display (1398 × 2034) and inner display
(2007 × 2853), including landscape screenshots with the dimensions reversed.
Both Night Sky and Star White are supported. Landscape framing rotates the
portrait bezel using frameit's existing orientation handling.

Install the latest device frame collection:

```sh
bundle exec fastlane frameit download_frames
```

Run frameit normally. Resolution detection distinguishes the two displays even
when both screenshots are named `iPhone Duo-...png`. You may also select
`iphone-duo-outer` or `iphone-duo-inner` with `force_device_type`. A Framefile
`frame` value of `NIGHT_SKY` or `STAR_WHITE` selects the finish; otherwise the
normal fallback chooses Night Sky when the requested finish is unavailable.

The Duo bezels and portrait screen masks are provided by
[frameit-frames](https://github.com/fastlane/frameit-frames). The masks preserve
asymmetric display corners and the outer camera cutout, and are rotated with
the screenshot for landscape. The side-by-side outer-and-back view is not implemented.
Apple artwork remains subject to the license supplied with the original
[Apple Design Resources](https://developer.apple.com/design/resources/) download.
