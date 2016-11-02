# fastlane for Android

This guide will show you step by step how to get started with `fastlane` for your Android project.

## Initial setup

Install `fastlane` if you haven't already

    sudo gem install fastlane --verbose

Navigate your terminal to your project directory and run

```
fastlane init
```

Feel free to skip any of these inputs by submitting with empty without entering anything.

### Package Name

That's your package name, which usually looks something like `com.krausefx.app`

### Google Play Access

To enable `fastlane` to access Google Play you have to follow these steps:

1. Open the [Google Play Console](https://play.google.com/apps/publish/)
1. Select **Settings** tab, followed by the **API access** tab
1. Click the **Create Service Account** button and follow the **Google API Console** link in the dialog
1. Click the **Create Service account** button at the top of the developers console screen
1. Provide a name for the service account
1. Click **Select a role** and choose **Project > Service Account Actor**
1. Check the **Furnish a new private key** checkbox
1. Select **JSON** as the Key type
1. Click **Create** to close the dialog
1. Make a note of the file name of the JSON file downloaded to your computer
1. Back on the Google Play developer console, click **Done** to close the dialog
1. Click on **Grant Access** for the newly added service account
1. Choose **Release Manager** from the **Role** dropdown
1. Click **Add user** to close the dialog

### JSON Key

The path to the json secret file that you're asked for should be the JSON file you downloaded from Google Play Console

### Finishing up

You'll be asked if you want to start using [supply](https://github.com/fastlane/fastlane/tree/master/supply). Do it if you plan on upload screenshots or binaries to Google Play.

### Editing the configuration files

`fastlane` created 2 important files and a metadata folder for you

##### `fastlane/Fastfile`

This file contains the actual deployment process. It defines which steps to run in which order. Check out [Actions.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Actions.md) for a list of all available integrations.

##### `fastlane/Appfile`

Contains basic metadata of your app that can be used by the actions you define in your `Fastfile`

##### `fastlane/metadata/android`

This folder contains the metadata fetched from Google Play. You can modify any values here and run `supply` to upload the updated metadata.

### Next Steps

Go ahead and modify the `Fastfile` to fit your needs. You might want to add the API Keys to your `crashlytics` action or your Slack URL to show notifications in your Slack room.

To get a list of all available integrations run

```
fastlane actions --platform android
```

and to get more information about what a specific action does and the available parameters use

```
fastlane action [action_name]
```

For more information, visit [Actions.md](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Actions.md).
