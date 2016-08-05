package tools.fastlane.screengrab;

import android.graphics.Bitmap;

/**
 * Callback interface that allows the handling of captured screenshots to happen asynchronous to
 * the test runner
 *
 * Implementations must dispose of the Bitmap passed to {@link #screenshotCaptured(String, Bitmap)}
 */
public interface ScreenshotCallback {
    /**
     * @param screenshotName The name of the screenshot passed to {@link Screengrab#screenshot(String)}
     * @param screenshot Bitmap representing the captured screenshot. Must be disposed of by this
     *                   method after handling is complete.
     */
    void screenshotCaptured(String screenshotName, Bitmap screenshot);
}
