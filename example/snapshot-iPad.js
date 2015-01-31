#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

// Setting to initial orientation (not necessary unless taking screenshots in multiple orientations)
target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);

target.delay(3)

captureLocalizedScreenshot("0-LandingScreen")

target.frontMostApp().tabBar().buttons()[1].tap();
target.delay(1)
captureLocalizedScreenshot("1-SecondScreen")

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);
captureLocalizedScreenshot("2-SecondScreenSideways")

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPERIGHT);
captureLocalizedScreenshot("3-SecondScreenOtherSideways")