package tools.fastlane.screengrab;

import android.app.Activity;

import com.jraska.falcon.Falcon;

/**
 * <p>Screenshot strategy that delegates to Falcon for screenshot capture. <b>Requires
 * API level &gt;= 10</b></p>
 */
public class FalconScreenshotStrategy implements ScreenshotStrategy {

    private final Activity activity;

    public FalconScreenshotStrategy(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void takeScreenshot(String screenshotName, ScreenshotCallback screenshotCallback) {
        screenshotCallback.screenshotCaptured(screenshotName, Falcon.takeScreenshotBitmap(activity));
    }
}
