package tools.fastlane.screengrab;

import android.app.UiAutomation;
import android.support.test.InstrumentationRegistry;

public class UiAutomatorScreenshotStrategy implements ScreenshotStrategy {
    @Override
    public void takeScreenshot(ScreenshotCallback screenshotCallback) {
        UiAutomation uiAutomation = InstrumentationRegistry.getInstrumentation().getUiAutomation();
        screenshotCallback.screenshotCaptured(uiAutomation.takeScreenshot());
    }
}
