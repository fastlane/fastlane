package tools.fastlane.screengrab;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.os.Looper;
import android.view.View;

import java.util.concurrent.CountDownLatch;

/**
 * <p>Screenshot strategy that captures the contents of a Window's decor view.</p>
 *
 * <p>Advantages compared to {@link UiAutomatorScreenshotStrategy}:</p>
 *
 * <ul>
 *     <li>Works down to API level 8</li>
 * </ul>
 *
 * Known limitations:
 * <ul>
 *     <li>Does not work on Android N</li>
 *     <li>Does not correctly capture depth/shadows in Material UI</li>
 *     <li>Does not correctly capture multi-window situations (dialogs, etc.)</li>
 *     <li>Does not correctly capture specialized surface views (Google Maps, video players, etc.)</li>
 * </ul>
 */
public final class DecorViewScreenshotStrategy implements ScreenshotStrategy {
    private final Activity mActivity;

    public DecorViewScreenshotStrategy(Activity activity) {
        mActivity = activity;
    }

    @Override
    public void takeScreenshot(String screenshotName, ScreenshotCallback callback) {
        try {
            callback.screenshotCaptured(screenshotName, takeScreenshot(mActivity));
        } catch (Exception e) {
            throw new RuntimeException("Unable to capture screenshot.", e);
        }
    }

    private static Bitmap takeScreenshot(final Activity activity) {
        final View view = activity.getWindow().getDecorView();
        final Bitmap bitmap = Bitmap.createBitmap(view.getWidth(), view.getHeight(), Bitmap.Config.ARGB_8888);

        if (Looper.myLooper() == Looper.getMainLooper()) {
            // On main thread already, Just Do It™.
            drawViewToBitmap(view, bitmap);
        } else {
            // On a background thread, post to main.
            final CountDownLatch latch = new CountDownLatch(1);
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        drawViewToBitmap(view, bitmap);
                    } finally {
                        latch.countDown();
                    }
                }
            });
            try {
                latch.await();
            } catch (InterruptedException e) {
                throw new RuntimeException("Unable to capture screenshot", e);
            }
        }

        return bitmap;
    }

    private static void drawViewToBitmap(View decorView, Bitmap bitmap) {
        decorView.draw(new Canvas(bitmap));
    }
}
