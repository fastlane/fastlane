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

- Open the [Google Play Console](https://play.google.com/apps/publish/)
- Open _Settings => API-Access_
- Create a new Service Account - follow the link of the dialog
- Create new Client ID
- Select _Service Account_
- Click _Generate new P12 key_ and store the downloaded file
- The _Email address_ underneath _Service account_ is the email address you have to enter as the `Issuer`
- Back on the Google Play developer console, click on _Grant Access_ for the newly added service account
- Choose _Release Manager_ from the dropdown and confirm

### Issuer

Copy and paste the email address which looks like this `137123276006-aaaeltp0aqgn2opfb7tk46ovaaa3hv1g@developer.gserviceaccount.com`

### Keyfile

Store your p12 file in a secure place and pass the path to it here

### Finishing up

You'll be asked if you want to start using [supply](https://github.com/fastlane/supply). Do it if you plan on upload screenshots or binaries to Google Play.

### Editing the configuration files

`fastlane` created 2 important files and a metadata folder for you

##### `fastlane/Fastfile`

This file contains the actual deployment process. It defines which steps to run in which order. Check out [Actions.md](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md) for a list of all available integrations.

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

For more information, visit [Actions.md](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md).
