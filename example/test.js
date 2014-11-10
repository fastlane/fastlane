#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();


target.delay(3)
captureLocalizedScreenshot("0-LandingScreen")

target.frontMostApp().tabBar().buttons()[1].tap();
target.delay(1)
captureLocalizedScreenshot("1-SecondScreen")

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);
target.delay(1)
captureLocalizedScreenshot("3-RotatedScreen")