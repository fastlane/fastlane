package tools.fastlane.screengrab;

import android.annotation.TargetApi;
import android.app.UiAutomation;
import android.os.Build;
import android.support.test.InstrumentationRegistry;

/**
 * <p>Screenshot strategy that delegates to UiAutomation for screenshot capture. <b>Requires
 * API level &gt;= 18</b></p>
 *
 * <p>Advantages compared to {@link DecorViewScreenshotStrategy}:</p>
 *
 * <ul>
 *     <li>Works on Android N</li>
 *     <li>Correctly captures depth/shadows in Material UI</li>
 *     <li>Correctly captures multi-window situations (dialogs, etc.)</li>
 * </ul>
 *
 * Caveats compared to {@link DecorViewScreenshotStrategy}:
 * <ul>
 *     <li>Requires a device running API level &gt;= 18</li>
 *     <li>
 *         Is less internally synchronized with Espresso, so you will want to
 *         use Espresso matchers to ensure that the proper UI elements are
 *         visible before triggering a screenshot.
 *     </li>
 * </ul>
 */
public class UiAutomatorScreenshotStrategy implements ScreenshotStrategy {
    @Override
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    public void takeScreenshot(String screenshotName, ScreenshotCallback screenshotCallback) {
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
            throw new RuntimeException("UiAutomatorScreenshotStrategy requires API level >= 18");
        }

        UiAutomation uiAutomation = InstrumentationRegistry.getInstrumentation().getUiAutomation();
        screenshotCallback.screenshotCaptured(screenshotName, uiAutomation.takeScreenshot());
    }
}
