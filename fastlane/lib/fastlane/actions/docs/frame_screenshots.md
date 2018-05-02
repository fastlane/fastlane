<p align="center">
  <img src="/img/actions/frameit.png" width="250">
</p>

###### Easily put your screenshots into the right device frames

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

## Frame screenshot

Put a gorgeous device frame around your iOS and macOS screenshots just by running one simple command. Support for:

- iPhone, iPad and Mac
- Portrait and Landscape modes
- Several device frame colors

The complete and updated list of supported devices and colors can be found [here](https://github.com/fastlane/frameit-frames/tree/gh-pages/latest)

Here is a nice gif, that shows _frameit_ in action:

![img/actions/FrameitGit.gif](/img/actions/FrameitGit.gif?raw=1)

## Advanced Features

- Put framed screenshot on colored background, define padding
- add text above or under framed screenshot
  - keyword + text
  - choose text font and color
  - multi line text
  - "intelligent" positioning of text that always looks good(ish)

## Results

![img/actions/ScreenshotsBig.png](/img/actions/ScreenshotsBig.png?raw=1)

-------

![img/actions/ScreenshotsOverview.png](/img/actions/ScreenshotsOverview.png?raw=1)

-------

![img/actions/MacExample.png](/img/actions/MacExample.png?raw=1)

<h5 align="center">The <code>frameit</code> 2.0 update was kindly sponsored by <a href="https://mindnode.com/">MindNode</a>, seen in the screenshots above.</h5>


The first time that _frameit_ is executed the frames will be downloaded automatically. Originally the frames are coming from [Facebook frameset](http://facebook.design/devices) and they are kept on [this repo](https://github.com/fastlane/frameit-frames).

More information about this process and how to update the frames can be found [here](https://github.com/fastlane/fastlane/tree/master/frameit/frames_generator)

# Usage

## Basic Usage

Why should you have to use Photoshop, just to add a frame around your screenshots?

Just navigate to your folder of screenshots and use the following command:

    fastlane frameit

To use the silver version of the frames:

    fastlane frameit silver

To download the latest frames

    fastlane frameit download_frames

When using _frameit_ without titles on top, the screenshots will have the full resolution, which means they can't be uploaded to the App Store directly. They are supposed to be used for websites, print media and emails. Check out the section below to use the screenshots for the App Store.

## Advanced Usage (optional)

### Text and Background

With _frameit_ it's possible to add a custom background and text below or above the framed screenshots in fonts and colors you define.

A working example can be found in the [fastlane examples](https://github.com/fastlane/examples/tree/master/MindNode/screenshots) project.

### `Framefile.json`

The Framefile allows to define general and screenshot specific information.
It has the following JSON structure:

```json
{
  "device_frame_version": "latest",
  "default": {
    ...
  },
  "data": [
     ...
  ]
}
```

### General parameters

The general parameters are defined in the `default` key and can be:

| Key | Description | Default value |
|-----|-------------|---------------|
| `background` | The background that should be used for the framed screenshot. Specify the (relative) path to the image file (e.g. *.jpg). This parameter is mandatory. | NA |
| `keyword` | An object that contains up to 3 keys to describe the optional keyword. See [table](#keyword-and-title-parameters) below. | NA |
| `title` | An object that contains up to 3 keys to describe the mandatory title. See [table](#keyword-and-title-parameters) below. | NA |
| `stack_title` | Specifies whether _frameit_ should display the keyword above the title when both keyword and title are defined. If it is false, the title and keyword will be displayed side by side when both keyword and title are defined. | `false` |
| `title_below_image` | Specifies whether _frameit_ should place the title and optional keyword below the device frame. If it is false, it will be placed above the device frame. | `false` |
| `show_complete_frame` | Specifies whether _frameit_ should shrink the device frame so that it is completely shown in the framed screenshot. If it is false, clipping of the device frame might occur at the bottom (when `title_below_image` is `false`) or top (when `title_below_image` is `true`) of the framed screenshot. | `false` |
| `padding` | The content of the framed screenshot will be resized to match the specified `padding` around all edges. The vertical padding is also applied between the text and the top or bottom (depending on `title_below_image`) of the device frame. <p> There are 3 different options of specyfying the padding: <p> 1. Default: An integer value that defines both horizontal and vertical padding in pixels. <br> 2. A string that defines (different) padding values in pixels for horizontal and vertical padding. The syntax is `"<horizontal>x<vertical>"`, e.g. `"30x60"`. <br> 3. A string that defines (different) padding values in percentage for horizontal and vertical padding. The syntax is `"<horizontal>%x<vertical>%"`, e.g. `"5%x10%"`. <br> **Note:** The percentage is calculated from the smallest image dimension (height or width). <p> A combination of option 2 and 3 is possible, e.g. `"5%x40"`. | `50` |
| `interline_spacing` | Specifies whether _frameit_ should add or subtract this many pixels between the individual lines of text. This only applies to a multi-line `title` and/or `keyword` to expand or squash together the individual lines of text. | `0` |
| `font_scale_factor` | Specifies whether _frameit_ should increase or decrease the font size of the text. | `0.1` |

### Specific parameters

The screenshot specific parameters are related to the keyword and title texts.
These are defined in the `data` key. This is an array with the following keys for each screenshot:

| Key | Description |
|-----|-------------|
| `filter` | This is mandatory to link the individual configuration to the screenshot, based on part of the file name. <p>Example:<br>If a screenshot is named `iPhone 8-Brainstorming.png` you can use value `Brainstorming` for `filter`. All other keys from that array element will only be applied on this specific screenshot. |
| `keyword` | Similar use as in `default`, except that parameter `text` can be used here because it is screenshot specific. |
| `title` | Similar use as in `default`, except that parameter `text` can be used here because it is screenshot specific. |

### <a name="keyword-and-title-parameters"></a>Framefile `keyword` and `title` parameters

The `keyword` and `title` parameters are both used in `default` and `data`. They both consist of the following optional keys:

| Key | Description | Default value |
|-----|-------------|---------------|
| `color` | The font color for the text. Specify a hex/html color code. | `#000000` (black) |
| `font` | The font family for the text. Specify the (relative) path to the font file (e.g. an OpenType Font). | The default `imagemagick` font, which is system dependent. |
| `text` | The text that should be used for the `keyword` or `title`. <p> Note: If you want to use localised text, use [`.strings` files](#strings-files). | NA |

### Example
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

You can find a more complex [configuration](https://github.com/fastlane/examples/blob/master/MindNode/screenshots/Framefile.json) to also support Chinese, Japanese and Korean languages.

The `Framefile.json` should be in the `screenshots` folder, as seen in the [example](https://github.com/fastlane/examples/tree/master/MindNode/screenshots).

### `.strings` files

To define the title and optionally the keyword, put two `.strings` files into the language folder (e.g. [en-US in the example project](https://github.com/fastlane/examples/tree/master/MindNode/screenshots/en-US))

The `keyword.strings` and `title.strings` are standard `.strings` file you already use for your iOS apps, making it easy to use your existing translation service to get localized titles.

**Notes**

- These `.strings` files **MUST** be utf-8 (UTF-8) or utf-16 encoded (UTF-16 BE with BOM). They also must begin with an empty line. If you are having trouble see [issue #1740](https://github.com/fastlane/fastlane/issues/1740)
- You **MUST** provide a background if you want titles. _frameit_ will not add the tiles if a background is not specified.

# Mac

With _frameit_ it's possible to also frame macOS Application screenshots. You have to provide the following:

- A (relative) path to a `background` image file, which should contain both the background and the Mac.
- The `offset` information so _frameit_ knows where to position your screenshot on the `background`:
  - `offset` : A string that specifies the horizontal and vertical offset in pixels, with respect to the top left corner of the `background` image. The syntax is `"+<horizontal>+<vertical>"`, e.g. `"+200+150"`.
  - `titleHeight` : The height in pixels that should be used for the title.

## Example
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

## Upload screenshots

Use [_deliver_](https://docs.fastlane.tools/actions/deliver/) to upload iOS screenshots to iTunes Connect, or [_supply_](https://docs.fastlane.tools/actions/supply/) to upload Android screenshots to Play Store completely automatically 🚀

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
