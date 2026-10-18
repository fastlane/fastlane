# Prepare and upload new device frames

Starting in October 2016 we are now using the [Facebook frameset](https://design.facebook.com/toolsandresources/devices/) and hosting the device frame resources since Apple sometimes has removed / changed some of the old images making framing a moving target.

To run the wizard to prepare new device assets, just run `rake` in this directory.

There is a `legacy` directory in this directory that contains frames that have been removed from Facebook's frameset but are still needed by users

You will need to run this wizard every time you want update the device assets

This will generate 2 directories:

- The timestamp based one which is used if the user specifies a particular version in their Framefile
- The the most recent one which will be used by default

Both directories should be uploaded to [github.com/fastlane/frameit-frames](https://github.com/fastlane/frameit-frames).

## iPhone Duo (local artwork)

This fork recognizes the outer display (1398 × 2034) and inner display
(2007 × 2853), including landscape screenshots with the dimensions reversed.
Both Night Sky and Star White are supported. Landscape framing rotates the
portrait bezel using frameit's existing orientation handling.

Download **iPhone Duo** from [Apple Design Resources](https://developer.apple.com/design/resources/),
review and accept Apple's license, then mount/extract the disk image. The artwork
remains subject to Apple's license; it is not included in this repository.

Download frameit's normal frames first, then add Duo from the root of this fork:

```sh
bundle exec fastlane frameit download_frames
ruby frameit/frames_generator/import_iphone_duo.rb \
  --source "/path/to/Bezel-iPhone-Duo" \
  --output "$HOME/.fastlane/frameit/latest"
```

The source can also be the `PNG` subdirectory. ImageMagick's `magick` executable
must be available. The importer checks the artwork dimensions, copies four
portrait bezels, generates two display masks, and merges Duo offsets into the
existing `offsets.json`. Existing device entries are preserved. Re-run the
importer after downloading a new frame cache. To keep a separate version, copy
the existing cache (including `version.txt`) into a versioned directory, import
there, and select it with `device_frame_version` in your Framefile.

Run frameit normally. Resolution detection distinguishes the two displays even
when both screenshots are named `iPhone Duo-...png`. You may also select
`iphone-duo-outer` or `iphone-duo-inner` with `force_device_type`. A Framefile
`frame` value of `NIGHT_SKY` or `STAR_WHITE` selects the finish; otherwise the
normal fallback chooses Night Sky when the requested finish is unavailable.

The portrait masks preserve asymmetric display corners and the outer camera
cutout, and are rotated with the screenshot for landscape. Apple artwork is not
redistributed, and the side-by-side outer-and-back view is not implemented.
