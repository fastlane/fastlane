<p align="center">
  <img src="/img/actions/supply.png" width="250">
</p>

###### Command line tool for updating Android apps and their metadata on the Google Play Store

_supply_ uploads app metadata, screenshots, binaries, and app bundles to Google Play. You can also select tracks for builds and promote builds to production.

-------

<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#setup">Setup</a> &bull;
    <a href="#quick-start">Quick Start</a> &bull;
    <a href="#available-commands">Commands</a> &bull;
    <a href="#uploading-an-apk">Uploading an APK</a> &bull;
    <a href="#uploading-an-aab">Uploading an AAB</a> &bull;
    <a href="#images-and-screenshots">Images</a>
</p>

-------

## Features
- Update existing Android applications on Google Play via the command line
- Upload new builds (APKs and AABs)
- Retrieve and edit metadata, such as title and description, for multiple languages
- Upload the app icon, promo graphics and screenshots for multiple languages
- Have a local copy of the metadata in your git repository
- Retrieve version code numbers from existing Google Play tracks


## Setup

Setup consists of setting up your Google Developers Service Account

{!docs/includes/google-credentials.md!}

### Migrating Google credential format (from .p12 key file to .json)

In previous versions of supply, credentials to your Play Console were stored as `.p12` files. Since version 0.4.0, supply now supports the recommended `.json` key Service Account credential files. If you wish to upgrade:

- follow the <a href="#setup">Setup</a> procedure once again to make sure you create the appropriate JSON file
- update your fastlane configuration or your command line invocation to use the appropriate argument if necessary.
  Note that you don't need to take note nor pass the `issuer` argument anymore.


The previous p12 configuration is still currently supported.


## Quick Start

- `cd [your_project_folder]`
- `fastlane supply init`
- Make changes to the downloaded metadata, add images, screenshots and/or an APK
- `fastlane supply`

## Available Commands

- `fastlane supply`: update an app with metadata, a build, images and screenshots
- `fastlane supply init`: download metadata for an existing app to a local directory
- `fastlane action supply`: show information on available commands, arguments and environment variables

You can either run _supply_ on its own and use it interactively, or you can pass arguments or specify environment variables for all the options to skip the questions.

## Uploading an APK

To upload a new binary to Google Play, simply run

```no-highlight
fastlane supply --apk path/to/app.apk
```

This will also upload app metadata if you previously ran `fastlane supply init`.

To gradually roll out a new build use

```no-highlight
fastlane supply --apk path/app.apk --track beta --rollout 0.5
```

### Expansion files (`.obb`)

Expansion files (obbs) found under the same directory as your APK will also be uploaded together with your APK as long as:

- they are identified as type 'main' or 'patch' (by containing 'main' or 'patch' in their file name)
- you have at most one of each type

If you only want to update the APK, but keep the expansion files from the previous version on Google Play use

```no-highlight
fastlane supply --apk path/app.apk --obb_main_references_version 21 --obb_main_file_size 666154207
```

or

```no-highlight
fastlane supply --apk path/app.apk --obb_patch_references_version 21 --obb_patch_file_size 666154207
```

## Uploading an AAB

To upload a new [Android application bundle](https://developer.android.com/guide/app-bundle/) to Google Play, simply run

```no-highlight
fastlane supply --aab path/to/app.aab
```

This will also upload app metadata if you previously ran `fastlane supply init`.

To gradually roll out a new build use

```no-highlight
fastlane supply --aab path/app.aab --track beta --rollout 0.5
```

## Images and Screenshots

After running `fastlane supply init`, you will have a metadata directory. This directory contains one or more locale directories (e.g. en-US, en-GB, etc.), and inside this directory are text files such as `title.txt` and `short_description.txt`.

Inside of a given locale directory is a folder called `images`. Here you can supply images with the following file names (extension can be png, jpg or jpeg):

- `featureGraphic`
- `icon`
- `promoGraphic`
- `tvBanner`

You can also supply screenshots by creating directories within the `images` directory with the following names, containing PNGs or JPEGs (image names are irrelevant):

- `phoneScreenshots/`
- `sevenInchScreenshots/` (7-inch tablets)
- `tenInchScreenshots/` (10-inch tablets)
- `tvScreenshots/`
- `wearScreenshots/`

Note that these will replace the current images and screenshots on the play store listing, not add to them.

## Changelogs (What's new)

You can add changelog files under the `changelogs/` directory for each locale. The filename should exactly match the [version code](https://developer.android.com/studio/publish/versioning#appversioning) of the APK that it represents. You can also provide default notes that will be used if no files match the version code by adding a `default.txt` file. `fastlane supply init` will populate changelog files from existing data on Google Play if no `metadata/` directory exists when it is run.

```no-highlight
└── fastlane
    └── metadata
        └── android
            ├── en-US
            │   └── changelogs
            │       ├── default.txt
            │       ├── 100000.txt
            │       └── 100100.txt
            └── fr-FR
                └── changelogs
                    ├── default.txt
                    └── 100100.txt
```

## Track Promotion

A common Play publishing scenario might involve uploading an APK version to a test track, testing it, and finally promoting that version to production.

This can be done using the `--track_promote_to` parameter. The `--track_promote_to` parameter works with the `--track` parameter to command the Play API to promote existing Play track APK version(s) (those active on the track identified by the `--track` param value) to a new track (`--track_promote_to` value).

## Retrieve Track Version Codes

Before performing a new APK upload you may want to check existing track version codes, or you may simply want to provide an informational lane that displays the currently promoted version codes for the production track. You can use the `google_play_track_version_codes` action to retrieve existing version codes for a package and track. For more information, see `fastlane action google_play_track_version_codes` help output.

## Migration from AndroidPublisherV2 to AndroidPublisherV3 in _fastlane_ 2.135.0

### New Options
- `:version_name`
  - Used when uploading with `:apk_path`, `:apk_paths`, `:aab_path`, and `:aab_paths`
  - Can be any string such (example: "October Release" or "Awesome New Feature")
  - Defaults to the version name in app/build.gradle or AndroidManifest.xml
- `:release_status`
  - Used when uploading with `:apk_path`, `:apk_paths`, `:aab_path`, and `:aab_paths`
  - Can set as  "draft" to complete the release at some other time
  - Defaults to "completed"
- `:version_code`
  - Used for `:update_rollout`, `:track_promote_to`, and uploading of meta data and screenshots
- `:skip_upload_changelogs`
  - Changelogs were previously included with the `:skip_upload_metadata` but is now its own option

### Deprecated Options
- `:check_superseded_tracks`
  - Google Play will automatically remove releases that are superseded now
- `:deactivate_on_promote`
  - Google Play will automatically deactive a release from its previous track on promote

:
