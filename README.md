<h3 align="center">
  <img src="fastlane/assets/fastlane_text.png" alt="fastlane Logo" width=500 />
</h3>

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/fastlane/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/fastlane.svg?style=flat)](https://rubygems.org/gems/fastlane)
[![Build Status](https://img.shields.io/circleci/project/fastlane/fastlane/master.svg?style=flat)](https://circleci.com/gh/fastlane/fastlane)

`fastlane` is a tool for iOS and Android developers to automate tedious tasks like generating screenshots, dealing with provisioning profiles, and releasing your application.

<hr />
<h2 align="center">
  ✨ All fastlane docs were moved to <a href="https://docs.fastlane.tools/">docs.fastlane.tools</a> ✨
</h2>
<hr />

## Need Help?

Before submitting a new GitHub issue, please make sure to

- Check out [docs.fastlane.tools](https://docs.fastlane.tools)
- Search for [existing GitHub issues](https://github.com/fastlane/fastlane/issues)

If the above doesn't help, please [submit an issue](https://github.com/fastlane/fastlane/issues) on GitHub and provide information about your setup, in particular the output of the `fastlane env` command.

**Note**: If you want to report a regression in _fastlane_ (something that has worked before, but broke with a new release), please mark your issue title as such using `[Regression] Your title here`. This enables us to quickly detect and fix regressions.

## _fastlane_ team

<table>
<tr>
<td>
<a href='https://twitter.com/hjanuschka'><img src='https://github.com/hjanuschka.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/hjanuschka'>Helmut Januschka</a></h4>
</td>
<td>
<a href='https://twitter.com/KrauseFx'><img src='https://github.com/KrauseFx.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/KrauseFx'>Felix Krause</a></h4>
</td>
<td>
<a href='https://twitter.com/lacostej'><img src='https://github.com/lacostej.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/lacostej'>Jérôme Lacoste</a></h4>
</td>
<td>
<a href='https://twitter.com/Sujan'><img src='https://github.com/janpio.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/Sujan'>Jan Piotrowski</a></h4>
</td>
<td>
<a href='https://twitter.com/lmirosevic'><img src='https://github.com/lmirosevic.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/lmirosevic'>Luka Mirosevic</a></h4>
</td>
</tr>
<tr>
<td>
<a href='https://twitter.com/aligatr'><img src='https://github.com/AliSoftware.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/aligatr'>Olivier Halligon</a></h4>
</td>
<td>
<a href='#'><img src='https://github.com/jdee.png?size=200' width=140></a>
<h4 align='center'><a href='#'>Jimmy Dee</a></h4>
</td>
<td>
<a href='https://twitter.com/Revolt666'><img src='https://github.com/revolter.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/Revolt666'>Iulian Onofrei</a></h4>
</td>
<td>
<a href='https://twitter.com/DanToml'><img src='https://github.com/DanToml.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/DanToml'>Danielle Tomlinson</a></h4>
</td>
<td>
<a href='https://twitter.com/getaaron'><img src='https://github.com/getaaron.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/getaaron'>Aaron Brager</a></h4>
</td>
</tr>
<tr>
<td>
<a href='https://twitter.com/giginet'><img src='https://github.com/giginet.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/giginet'>Kohki Miki</a></h4>
</td>
<td>
<a href='https://twitter.com/snatchev'><img src='https://github.com/snatchev.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/snatchev'>Stefan Natchev</a></h4>
</td>
<td>
<a href='https://twitter.com/mgrebenets'><img src='https://github.com/mgrebenets.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/mgrebenets'>Maksym Grebenets</a></h4>
</td>
<td>
<a href='https://twitter.com/taquitos'><img src='https://github.com/taquitos.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/taquitos'>Joshua Liebowitz</a></h4>
</td>
<td>
<a href='https://twitter.com/acrooow'><img src='https://github.com/milch.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/acrooow'>Manu Wallner</a></h4>
</td>
</tr>
<tr>
<td>
<a href='https://twitter.com/nafu003'><img src='https://github.com/nafu.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/nafu003'>Fumiya Nakamura</a></h4>
</td>
<td>
<a href='https://twitter.com/mellis1995'><img src='https://github.com/matthewellis.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/mellis1995'>Matthew Ellis</a></h4>
</td>
<td>
<a href='https://twitter.com/joshdholtz'><img src='https://github.com/joshdholtz.png?size=200' width=140></a>
<h4 align='center'><a href='https://twitter.com/joshdholtz'>Josh Holtz</a></h4>
</td>
</table>

## Contribute to _fastlane_

Check out [CONTRIBUTING.md](CONTRIBUTING.md) for more information on how to help with _fastlane_.

## Code of Conduct

Help us keep `fastlane` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/fastlane/blob/master/CODE_OF_CONDUCT.md).

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.

<hr />
<h2 align="center">
  ✨ All fastlane docs were moved to <a href="https://docs.fastlane.tools/">docs.fastlane.tools</a> ✨
</h2>
<hr />
