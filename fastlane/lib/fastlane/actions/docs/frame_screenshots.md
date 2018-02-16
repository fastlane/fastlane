<p align="center">
  <img src="/img/actions/frameit.png" width="250">
</p>

###### Quickly put your screenshots into the right device frames

_frameit_ allows you to put a gorgeous device frame around your iOS and macOS screenshots just by running one simple command. Use _frameit_ to prepare perfect screenshots for the App Store, your website, QA or emails.

-------

<p align="center">
    <a href="#features">Features</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="#tips">Tips</a>
</p>

-------

<h5 align="center"><code>frameit</code> is part of <a href="https://fastlane.tools">fastlane</a>: The easiest way to automate beta deployments and releases for your iOS and Android apps.</h5>


# Features

Put a gorgeous device frame around your iOS and macOS screenshots just by running one simple command. Support for:

- iPhone, iPad and Mac
- Portrait and Landscape modes
- Several colors

The complete and updated list of supported devices and colors can be found [here](https://github.com/fastlane/frameit-frames/tree/gh-pages/latest)

Here is a nice gif, that shows _frameit_ in action:

![img/actions/FrameitGit.gif](/img/actions/FrameitGit.gif?raw=1)

### Results

![img/actions/ScreenshotsBig.png](/img/actions/ScreenshotsBig.png?raw=1)

-------

![img/actions/ScreenshotsOverview.png](/img/actions/ScreenshotsOverview.png?raw=1)

-------

![img/actions/MacExample.png](/img/actions/MacExample.png?raw=1)

<h5 align="center">The <code>frameit</code> 2.0 update was kindly sponsored by <a href="https://mindnode.com/">MindNode</a>, seen in the screenshots above.</h5>


The first time that _frameit_ is executed the frames will be downloaded automatically. Originally the frames are coming from [Facebook frameset](http://facebook.design/devices) and they are kept on [this repo](https://github.com/fastlane/frameit-frames).

More information about this process and how to update the frames can be found [here](https://github.com/fastlane/fastlane/tree/master/frameit/frames_generator)

# Usage

Why should you have to use Photoshop, just to add a frame around your screenshots?

Just navigate to your folder of screenshots and use the following command:

    fastlane frameit

To use the silver version of the frames:

    fastlane frameit silver

To download the latest frames

    fastlane frameit download_frames

When using _frameit_ without titles on top, the screenshots will have the full resolution, which means they can't be uploaded to the App Store directly. They are supposed to be used for websites, print media and emails. Check out the section below to use the screenshots for the App Store.

# Titles and Background (optional)

With _frameit_ 2.0 you are now able to add a custom background, title and text colors to your screenshots.

A working example can be found in the [fastlane examples](https://github.com/fastlane/examples/tree/master/MindNode/screenshots) project.

#### `Framefile.json`

Use it to define the general information:

```json
{
  "device_frame_version": "latest",
  "default": {
    "keyword": {
      "font": "./fonts/MyFont-Rg.otf"
    },
    "title": {
      "font": "./fonts/MyFont-Th.otf",
      "color": "#545454"
    },
    "background": "./background.jpg",
    "padding": 50,
    "show_complete_frame": false,
    "stack_title" : false,
    "title_below_image": true
  },

  "data": [
    {
      "filter": "Brainstorming",
      "keyword": {
        "color": "#d21559"
      }
    },
    {
      "filter": "Organizing",
      "keyword": {
        "color": "#feb909"
      }
    },
    {
      "filter": "Sharing",
      "keyword": {
        "color": "#aa4dbc"
      }
    },
    {
      "filter": "Styling",
      "keyword": {
        "color": "#31bb48"
      }
    }
  ]
}
```
The `stack_title` value specifies whether _frameit_ should display the keyword above the title when both keyword and title are defined.

The `show_complete_frame` value specifies whether _frameit_ should shrink the device and frame so that they show in full in the framed screenshot. If it is false, then they can hang over the bottom of the screenshot.

The `title_below_image` value specifies whether _frameit_ should place the title below the screenshot. If it is false, it will be placed above the screenshot.

The `filter` value is a part of the screenshot named for which the given option should be used. If a screenshot is named `iPhone5_Brainstorming.png` the first entry in the `data` array will be used.

You can find a more complex [configuration](https://github.com/fastlane/examples/blob/master/MindNode/screenshots/Framefile.json) to also support Chinese, Japanese and Korean languages.

The `Framefile.json` should be in the `screenshots` folder, as seen in the [example](https://github.com/fastlane/examples/tree/master/MindNode/screenshots).

#### `.strings` files

To define the title and optionally the keyword, put two `.strings` files into the language folder (e.g. [en-US in the example project](https://github.com/fastlane/examples/tree/master/MindNode/screenshots/en-US))

The `keyword.strings` and `title.strings` are standard `.strings` file you already use for your iOS apps, making it easy to use your existing translation service to get localized titles.

**Note:** These `.strings` files **MUST** be utf-16 encoded (UTF-16 BE with BOM).  They also must begin with an empty line. If you are having trouble see [issue #1740](https://github.com/fastlane/fastlane/issues/1740)

**Note:** You **MUST** provide a background if you want titles. _frameit_ will not add the tiles if a background is not specified.

#### Uploading screenshots to iTC

Use [deliver](https://docs.fastlane.tools/actions/deliver/) to upload all screenshots to iTunes Connect completely automatically 🚀

### Mac

With _frameit_ 2.0 it's possible to also frame macOS Application screenshots. You have to provide the following:

- The `offset` information so _frameit_ knows where to put your screenshots
- A path to a `background`, which should contain both the background and the Mac
- `titleHeight`: The height in px that should be used for the title

##### Example
```json
{
  "default": {
    "title": {
      "color": "#545454"
    },
    "background": "Mac.jpg",
    "offset": {
      "offset": "+676+479",
      "titleHeight": 320
    }
  },
  "data": [
    {
      "filter": "Brainstorming",
      "keyword": {
        "color": "#d21559"
      }
    }
  ]
}
```

Check out the [MindNode example project](https://github.com/fastlane/examples/tree/master/MindNode/screenshots).

# Tips

## Generate localized screenshots
Check out [_snapshot_](https://docs.fastlane.tools/actions/snapshot/) to automatically generate screenshots using ```UI Automation```.

## Alternative location to store device_frames

Device frames can also be stored in a ```./fastlane/screenshots/devices_frames``` directory if you prefer rather than in the ```~/.frameit/device_frames``` directory. If doing so please be aware that Apple's images are copyrighted and should not be redistributed as part of a repository so you may want to include them in your .gitignore file.

## White background of frames

Some stock images provided by Apple still have a white background instead of a transparent one. You'll have to edit the Photoshop file to remove the white background, delete the generated `.png` file and run `fastlane frameit` again.

## Use a clean status bar
You can use [SimulatorStatusMagic](https://github.com/shinydevelopment/SimulatorStatusMagic) to clean up the status bar.

## Gray artifacts around text

If you run into any quality issues, like having a border around the font, it usually helps to just re-install `imagemagick`. You can do so by running

```sh
brew uninstall imagemagick
brew install imagemagick
```

## Uninstall
- ```sudo gem uninstall fastlane```
- ```rm -rf ~/.frameit```
