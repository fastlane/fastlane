package tools.fastlane.screengrab;

public interface ScreenshotStrategy {
    void takeScreenshot(String screenshotName, ScreenshotCallback screenshotCallback);
}
