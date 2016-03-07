HexColors
=========================
![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/HexColors/badge.png)

![Badge w/ Version](https://cocoapod-badges.herokuapp.com/p/HexColors/badge.png)

HexColors is drop in category for HexColor Support for NSColor and UIColor. Support for HexColors with prefixed # and without.

#RELEASE 2.3.0
Attention the API has changed! 

#Example iOS
``` objective-c
// with hash
UIColor *colorWithHex = [UIColor colorWithHexString:@"#ff8942"];

// without hash
UIColor *secondColorWithHex = [UIColor colorWithHexString:@"ff8942"];

// short handling
UIColor *shortColorWithHex = [UIColor colorWithHexString:@"fff"];
```

#Example Mac OS X
``` objective-c
// with hash
NSColor *colorWithHex = [NSColor colorWithHexString:@"#ff8942"];

// wihtout hash
NSColor *secondColorWithHex = [NSColor colorWithHexString:@"ff8942"];

// short handling
NSColor *shortColorWithHex = [NSColor colorWithHexString:@"fff"];
```

#Installation
* `#import "HexColors.h"` where you want to use easy as pie HexColors
* `pod install HexColors`
* or just drag the source files in your project

##Requirements
HexColors requires [iOS 5.0](http://developer.apple.com/library/ios/#releasenotes/General/WhatsNewIniPhoneOS/Articles/iPhoneOS4.html) and above, and Mac OS X 10.6

##Credits
HexColors was created by [Marius Landwehr](https://github.com/mRs-) because of the pain recalculating Hex values to RGB.

HexColors was ported to Mac OS X by [holgersindbaek](https://github.com/holgersindbaek).

##Creator
[Marius Landwehr](https://github.com/mRs-) [@mariusLAN](https://twitter.com/mariusLAN)

##License
HexColors is available underthe MIT license. See the LICENSE file for more info.
