package tools.fastlane.screengrab;

import android.graphics.Bitmap;

public interface ScreenshotCallback {
    void screenshotCaptured(String screenshotName, Bitmap bitmap);
}
