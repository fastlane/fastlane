// Derived from Spoon.java in square/spoon
// Copyright 2013 Square, Inc.

package tools.fastlane.screengrab;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.os.Build;
import android.os.Environment;
import android.os.Looper;
import android.support.test.espresso.Espresso;
import android.support.test.espresso.UiController;
import android.support.test.espresso.ViewAction;
import android.support.test.espresso.matcher.ViewMatchers;
import android.util.Log;
import android.view.View;

import org.hamcrest.Matcher;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;
import java.util.concurrent.CountDownLatch;
import java.util.regex.Pattern;

import tools.fastlane.screengrab.file.Chmod;

public class Screengrab {
    private static final Set<Locale> accessedLocales = new HashSet<Locale>();

    private static final Pattern TAG_PATTERN = Pattern.compile("[a-zA-Z0-9_-]+");

    static final String NAME_SEPARATOR = "_";

    private static final String EXTENSION = ".png";
    private static final String TAG = "Screengrab";
    private static final int FULL_QUALITY = 100;
    private static final String SCREENGRAB_DIR_NAME = "screengrab";

    public static void screenshot(final String screenshotName) {
        // Use Espresso to find the Activity of the Root View. Using a ViewMatcher guarantees that
        // the Activity of the view is RESUMED before taking the screenshot
        Espresso.onView(ViewMatchers.isRoot()).perform(new ViewAction() {
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
                final Activity activity = (Activity) view.getContext();

                if (!TAG_PATTERN.matcher(screenshotName).matches()) {
                    throw new IllegalArgumentException("Tag may only contain the letters a-z, A-Z, the numbers 0-9, " +
                            "underscores, and hyphens");
                }
                try {
                    File screenshotDirectory = getFilesDirectory(activity.getApplicationContext(), Locale.getDefault());
                    String screenshotFileName = System.currentTimeMillis() + NAME_SEPARATOR + screenshotName + EXTENSION;
                    File screenshotFile = new File(screenshotDirectory, screenshotFileName);
                    takeScreenshot(activity, screenshotFile);
                    Log.d(TAG, "Captured screenshot \"" + screenshotFileName + "\"");
                } catch (Exception e) {
                    throw new RuntimeException("Unable to capture screenshot.", e);
                }
            }
        });
    }

    private static void takeScreenshot(final Activity activity, File file) throws IOException {
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
                String msg = "Unable to get screenshot " + file.getAbsolutePath();
                Log.e(TAG, msg, e);
                throw new RuntimeException(msg, e);
            }
        }

        OutputStream fos = null;
        try {
            fos = new BufferedOutputStream(new FileOutputStream(file));
            bitmap.compress(Bitmap.CompressFormat.PNG, FULL_QUALITY, fos);
            Chmod.chmodPlusR(file);
        } finally {
            bitmap.recycle();
            if (fos != null) {
                fos.close();
            }
        }
    }

    private static void drawDecorViewToBitmap(Activity activity, Bitmap bitmap) {
        activity.getWindow().getDecorView().draw(new Canvas(bitmap));
    }

    private static File getFilesDirectory(Context context, Locale locale) throws IOException {
        File directory;
        if (Build.VERSION.SDK_INT >= 21) {
            // Use external storage.
            directory = new File(Environment.getExternalStorageDirectory(), getDirectoryName(context, locale));
        } else {
            // Use internal storage.
            directory = new File(context.getDir(SCREENGRAB_DIR_NAME, Context.MODE_WORLD_READABLE), localeToDirName(locale));
        }

        Log.d(TAG, "Using files directory: " + directory.getAbsolutePath());

        synchronized (accessedLocales) {
            if (!accessedLocales.contains(locale)) {
                deletePath(directory, false);
                accessedLocales.add(locale);
            }
        }

        createPathTo(directory);
        return directory;
    }

    private static String getDirectoryName(Context context, Locale locale) {
        return context.getPackageName() + "/" + SCREENGRAB_DIR_NAME + "/" + localeToDirName(locale);
    }

    private static String localeToDirName(Locale locale) {
        return locale.getLanguage() + "-" + locale.getCountry();
    }

    private static void createPathTo(File dir) throws IOException {
        File parent = dir.getParentFile();
        if (!parent.exists()) {
            createPathTo(parent);
        }
        if (!dir.exists() && !dir.mkdirs()) {
            throw new IOException("Unable to create output dir: " + dir.getAbsolutePath());
        }
        Chmod.chmodPlusRWX(dir);
    }

    private static void deletePath(File path, boolean inclusive) {
        for (File child : listChildrenOf(path)) {
            deletePath(child, true);
        }

        if (inclusive) {
            path.delete();
        }
    }

    private static File[] listChildrenOf(File file) {
        File[] children = file.listFiles();
        return children == null ? new File[0] : children;
    }

    private Screengrab() {
    }
}
