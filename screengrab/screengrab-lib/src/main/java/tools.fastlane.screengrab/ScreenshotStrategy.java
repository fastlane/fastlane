package tools.fastlane.screengrab;

/**
 * Interface supporting multiple implementations for capturing screenshots
 */
public interface ScreenshotStrategy {
    /**
     * @param screenshotName The screenshot name given to {@link Screengrab#screenshot(String)}.
     *                       Should be passed through to the screenshotCallback.
     * @param screenshotCallback The callback object to notify after the screenshot is captured
     */
    void takeScreenshot(String screenshotName, ScreenshotCallback screenshotCallback);
}
