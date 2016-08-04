package tools.fastlane.screengrab;

import android.annotation.TargetApi;
import android.app.UiAutomation;
import android.os.Build;
import android.support.test.InstrumentationRegistry;

public class UiAutomatorScreenshotStrategy implements ScreenshotStrategy {
    @Override
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    public void takeScreenshot(ScreenshotCallback screenshotCallback) {
        if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
            throw new RuntimeException("UiAutomatorScreenshotStrategy requires API level >= 18");
        }

        UiAutomation uiAutomation = InstrumentationRegistry.getInstrumentation().getUiAutomation();
        screenshotCallback.screenshotCaptured(uiAutomation.takeScreenshot());
    }
}
