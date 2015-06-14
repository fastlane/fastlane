<h3 align="center">
  <a href="https://github.com/KrauseFx/fastlane">
    <img src="assets/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/KrauseFx/deliver">deliver</a> &bull; 
  <a href="https://github.com/KrauseFx/snapshot">snapshot</a> &bull; 
  <a href="https://github.com/KrauseFx/frameit">frameit</a> &bull; 
  <a href="https://github.com/KrauseFx/PEM">PEM</a> &bull; 
  <a href="https://github.com/KrauseFx/sigh">sigh</a> &bull; 
  <a href="https://github.com/KrauseFx/produce">produce</a> &bull; 
  <a href="https://github.com/KrauseFx/cert">cert</a> &bull; 
  <a href="https://github.com/KrauseFx/codes">codes</a>
</p>
-------

<p align="center">
  <img src="assets/deliver.png">
</p>

TestFlight CLI
============

This gem allows you to manage all important features of Apple TestFlight using a CLI.

This includes

- Upload new builds and distribute them to all testers
- Set build information like changelog for new builds
- Add new testers to your team

To upload a new build, just run 

```
pizzacutter
```

This will automatically look for an `ipa` in your current directory and tries to fetch the login credentials from your [fastlane setup](https://fastlane.tools).

You'll be asked for any missing information. Additionally, you can pass all kinds of parameters to `pizzacutter`:

```
pizzacutter -u "felix@krausefx.com"
   --changelog "This build is better"
```

`pizzacutter` does all kinds of magic for you:

- Automatically detects the bundle identifier from your `ipa` file
- Automatically fetch the AppID of your app based on the bundle identifier

This gem uses [spaceship](https://spaceship.airforce) to submit the build metadata and iTunes Transporter to upload the binary.
