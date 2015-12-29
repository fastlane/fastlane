# CodeSigning

Check out the official `fastlane` code signing guide: [https://codesigning.guide](https://codesigning.guide) for a detailed description on how to setup codesigning in teams.

It is recommended to use [match](https://github.com/fastlane/match) to generate and maintain your certificates and provisioning profiles. 

-------------------
## Deprecated

Manul code signing methods

Below some alternative methods


-------------------

There are multiple ways of doing code signing right. Letting Xcode automatically choose the provisioning profile is **not** one of them.

### (Deprecated) Easy Solution: Static Setting

In your project file set the correct `Provisioning Profile` and use the `gym` integration in `fastlane`.

**Disadvantages**: As soon as your provisioning profile changes, you'll have to update your project file. Therefore not a long-term solution.

### (Deprecated) Using environment variables

By choosing `Automatic` the underlying value in your project file is just empty. Open your `project.pbxproj` and look for
```
PROVISIONING_PROFILE = "";
```
To fill the profile in using environment variables use 
```
PROVISIONING_PROFILE = "$(PROFILE_UUID)";
```
This allows the Xcode project to use `Automatic` provisioning profiles and enables `fastlane` to set a custom profile.

In your `Fastfile`, add the following between your `sigh` and `gym` call:

```ruby
sigh

# use the UDID of the newly created provisioning profile
ENV["PROFILE_UUID"] = lane_context[SharedValues::SIGH_UDID]

gym(scheme: "Release")
```

This allows you to also support more complex setups, for example if your app supports app extensions or a Watch App.

Check out the [MindNode Setup](https://github.com/fastlane/examples/blob/master/MindNode/Fastfile) that shows you how to set different provisioning profiles for various targets.

To be sure to have a valid code signing identity installed as well, you can add a `cert` call before the `sigh` action.

### (Deprecated) Hacky Solution: Modify the Xcode project
Using the [update_project_provisioning](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md#update_project_provisioning) action you can modify your Xcode project's targets to use a specific provisioning profile. 

```ruby
update_project_provisioning(
  xcodeproj: "Project.xcodeproj",
  profile: "./watch_app_store.mobileprovision", # optional if you use sigh
  target_filter: ".*WatchKit Extension.*", # matches name or type of a target
  build_configuration: "Release"
)
```

As this will modify the project file, you should either commit the changes if you want to keep them (for your CI service to know how to code sign your app) or you should reset the git changes of the project files after successfully building your application, if you're building locally:
```ruby
ensure_git_status_clean
sigh
update_project_provisioning(...)
reset_git_repo(files: ["Project.xcodeproj/project.pbxproj"])
```
