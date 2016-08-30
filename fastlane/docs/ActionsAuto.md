# fastlane actions

This page contains a list of all built-in fastlane actions and their available options.

To get the most up-to-date information from the command line on your current version you can also run

```sh
fastlane actions # list all available fastlane actions
fastlane action [action_name] # more information for a specific action
```

You can import another `Fastfile` by using the `import` action. This is useful if you have shared lanes across multiple apps and you want to store a `Fastfile` in a separate folder. The path must be relative to the `Fastfile` this is called from.

```ruby
import './path/to/other/Fastfile'
```

- [Testing](#testing)
- [Building](#building)
- [Screenshots](#screenshots)
- [Project](#project)
- [Beta](#beta)
- [Releasing your app](#releasing-your-app)
- [Source Control](#source-control)
- [Notifications](#notifications)
- [Misc](#misc)




# Testing


# Building

### adb

Run ADB Actions

> see adb --help for more details

adb | 
-----|----
Supported platforms | android
Author | @hjanuschka
Returns | The output of the adb command



##### Example

```ruby
adb(
  command: "shell ls"
)
```




<details>
  <summary>Parameters</summary>

Key | Description
----|------------
  `serial` | Android serial, which device should be used for this command
  `command` | All commands you want to pass to the adb command, e.g. `kill-server`
  `adb_path` | The path to your `adb` binary

</details>






# Screenshots


# Project


# Beta


# Releasing your app


# Source Control

### add_git_tag

This will add an annotated git tag to the current branch

> This will automatically tag your build with the following format: `<grouping>/<lane>/<prefix><build_number>`, where:
- `grouping` is just to keep your tags organised under one 'folder', defaults to 'builds'
- `lane` is the name of the current fastlane lane
- `prefix` is anything you want to stick in front of the version number, e.g. 'v'
- `build_number` is the build number, which defaults to the value emitted by the `increment_build_number` action
For example for build 1234 in the 'appstore' lane it will tag the commit with `builds/appstore/1234`

add_git_tag | 
-----|----
Supported platforms | ios, android, mac
Author | @lmirosevic, @maschall



##### Examples

```ruby
add_git_tag # simple tag with default values
```

```ruby
add_git_tag(
  grouping: "fastlane-builds",
  prefix: "v",
  build_number: 123
)
```

```ruby
# Alternatively, you can specify your own tag. Note that if you do specify a tag, all other arguments are ignored.
add_git_tag(
  tag: "my_custom_tag"
)
```




<details>
  <summary>Parameters</summary>

Key | Description
----|------------
  `tag` | Define your own tag text. This will replace all other parameters
  `grouping` | Is used to keep your tags organised under one 'folder'. Defaults to 'builds'
  `prefix` | Anything you want to put in front of the version number (e.g. 'v')
  `build_number` | The build number. Defaults to the result of increment_build_number if you're using it
  `message` | The tag message. Defaults to the tag's name
  `commit` | The commit or object where the tag will be set. Defaults to the current HEAD
  `force` | Force adding the tag

</details>






# Notifications

### twitter

Post a tweet on Twitter.com

> Post a tweet on twitter. Requires you to setup an app on twitter.com and obtain consumer and access_token.

twitter | 
-----|----
Supported platforms | ios, android, mac
Author | @hjanuschka



##### Example

```ruby
twitter(
  message: "You rock!",
  access_token: "XXXX",
  access_token_secret: "xxx",
  consumer_key: "xxx",
  consumer_secret: "xxx"
)
```




<details>
  <summary>Parameters</summary>

Key | Description
----|------------
  `consumer_key` | Consumer Key
  `consumer_secret` | Consumer Secret
  `access_token` | Access Token
  `access_token_secret` | Access Token Secret
  `message` | The tweet

</details>






# Misc

### adb_devices

Get an Array of Connected android device serials

> Fetches device list via adb, e.g. run an adb command on all connected devices.

adb_devices | 
-----|----
Supported platforms | android
Author | @hjanuschka
Returns | Returns an array of all currently connected android devices



##### Example

```ruby
adb_devices.each  do |device|
  model = adb(command: "shell getprop ro.product.model",
    serial: device.serial
   ).strip

  puts "Model #{model} is connected"
end
```




<details>
  <summary>Parameters</summary>

Key | Description
----|------------
  `adb_path` | The path to your `adb` binary

</details>





### zip

Compress a file or folder to a zip

> 

zip | 
-----|----
Supported platforms | ios, android, mac
Author | @KrauseFx
Returns | The path to the output zip file



##### Examples

```ruby
zip
```

```ruby
zip(
  path: "MyApp.app",
  output_path: "Latest.app.zip"
)
```




<details>
  <summary>Parameters</summary>

Key | Description
----|------------
  `path` | Path to the directory or file to be zipped
  `output_path` | The name of the resulting zip file

</details>






