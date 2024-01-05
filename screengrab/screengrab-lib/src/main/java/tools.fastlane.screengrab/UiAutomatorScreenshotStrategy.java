package tools.fastlane.screengrab;

import android.app.UiAutomation;

import androidx.test.platform.app.InstrumentationRegistry;

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
    public void takeScreenshot(String screenshotName, ScreenshotCallback screenshotCallback) {
        UiAutomation uiAutomation = InstrumentationRegistry.getInstrumentation().getUiAutomation();
        screenshotCallback.screenshotCaptured(screenshotName, uiAutomation.takeScreenshot());
    }
}
