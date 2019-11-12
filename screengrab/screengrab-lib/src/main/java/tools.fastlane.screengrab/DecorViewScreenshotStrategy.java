package tools.fastlane.screengrab;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.os.Looper;
import androidx.test.espresso.Espresso;
import androidx.test.espresso.UiController;
import androidx.test.espresso.ViewAction;
import androidx.test.espresso.matcher.ViewMatchers;
import android.view.View;

import org.hamcrest.Matcher;

import java.io.IOException;
import java.util.concurrent.CountDownLatch;

/**
 * <p>Screenshot strategy that captures the contents of a Window's decor view.</p>
 *
 * <p>Advantages compared to {@link UiAutomatorScreenshotStrategy}:</p>
 *
 * <ul>
 *     <li>Works down to API level 8</li>
 *     <li>Uses Espresso for action synchronization internally, so requires less matching
 *         setup in your tests</li>
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
public class DecorViewScreenshotStrategy implements ScreenshotStrategy {
    @Override
    public void takeScreenshot(String screenshotName, ScreenshotCallback callback) {
        Espresso.onView(ViewMatchers.isRoot()).perform(new ScreenshotViewAction(screenshotName, callback));
    }

    static class ScreenshotViewAction implements ViewAction {
        private final String screenshotName;
        private final ScreenshotCallback callback;

        public ScreenshotViewAction(String screenshotName, ScreenshotCallback callback) {
            this.screenshotName = screenshotName;
            this.callback = callback;
        }

        @Override
        public Matcher<View> getConstraints() {
            return ViewMatchers.isDisplayed();
        }

        @Override
        public String getDescription() {
            return "taking screenshot of the Activity";
        }

        @Override
        public void perform(UiController uiController, View view) {
            final Activity activity = scanForActivity(view.getContext());

            if (activity == null) {
                throw new IllegalStateException("Couldn't get the activity from the view context");
            }

            try {
                callback.screenshotCaptured(screenshotName, takeScreenshot(activity));
            } catch (Exception e) {
                throw new RuntimeException("Unable to capture screenshot.", e);
            }
        }

        private Activity scanForActivity(Context context) {
            if (context == null) {
                return null;

            } else if (context instanceof Activity) {
                return (Activity) context;

            } else if (context instanceof ContextWrapper) {
                return scanForActivity(((ContextWrapper) context).getBaseContext());
            }

            return null;
        }

        private static Bitmap takeScreenshot(final Activity activity) throws IOException {
            View view = activity.getWindow().getDecorView();
            final Bitmap bitmap = Bitmap.createBitmap(view.getWidth(), view.getHeight(), Bitmap.Config.ARGB_8888);

            if (Looper.myLooper() == Looper.getMainLooper()) {
                // On main thread already, Just Do It™.
                drawDecorViewToBitmap(activity, bitmap);
            } else {
                // On a background thread, post to main.
                final CountDownLatch latch = new CountDownLatch(1);
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            drawDecorViewToBitmap(activity, bitmap);
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

        private static void drawDecorViewToBitmap(Activity activity, Bitmap bitmap) {
            activity.getWindow().getDecorView().draw(new Canvas(bitmap));
        }
    }
}
