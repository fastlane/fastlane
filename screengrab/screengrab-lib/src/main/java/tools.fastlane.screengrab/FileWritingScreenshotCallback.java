package tools.fastlane.screengrab;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import androidx.test.platform.app.InstrumentationRegistry;
import android.util.Log;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Locale;

import tools.fastlane.screengrab.file.Chmod;

/**
 * Default {@link ScreenshotCallback} implementation that stores the captured Bitmap on the file
 * system in the structure that the Screengrab command-line utility expects.
 */
public class FileWritingScreenshotCallback implements ScreenshotCallback {
    private static final String TAG = "Screengrab";

    protected static final String NAME_SEPARATOR = "_";
    protected static final String EXTENSION = ".png";
    private static final int FULL_QUALITY = 100;
    private static final String SCREENGRAB_DIR_NAME = "screengrab";
    private static final String APPEND_TIMESTAMP_CONFIG_KEY = "appendTimestamp";

    private final Context appContext;

    public FileWritingScreenshotCallback(Context appContext) {
        this.appContext = appContext;
    }

    @Override
    public void screenshotCaptured(String screenshotName, Bitmap screenshot) {
        try {
            File screenshotDirectory = getFilesDirectory(appContext, Locale.getDefault());
            File screenshotFile = getScreenshotFile(screenshotDirectory, screenshotName);

            OutputStream fos = null;
            try {
                fos = new BufferedOutputStream(new FileOutputStream(screenshotFile));
                screenshot.compress(Bitmap.CompressFormat.PNG, FULL_QUALITY, fos);
                Chmod.chmodPlusR(screenshotFile);
            } finally {
                screenshot.recycle();
                if (fos != null) {
                    fos.close();
                }
            }

            Log.d(TAG, "Captured screenshot \"" + screenshotFile.getName() + "\"");
        } catch (Exception e) {
            throw new RuntimeException("Unable to capture screenshot.", e);
        }
    }

    protected File getScreenshotFile(File screenshotDirectory, String screenshotName) {
        String screenshotFileName = screenshotName
                + (shouldAppendTimestamp() ? (NAME_SEPARATOR + System.currentTimeMillis()) : "")
                + EXTENSION;
        return new File(screenshotDirectory, screenshotFileName);
    }

    private static File getFilesDirectory(Context context, Locale locale) throws IOException {
        File directory = null;

        if (Build.VERSION.SDK_INT >= 21) {
            File internalDir = new File(context.getFilesDir(), getDirectoryName(context, locale));
            directory = initializeDirectory(internalDir);
        }

        // We can only try this fall-back before Android N, since N makes Context.MODE_WORLD_READABLE
        // result in a SecurityException
        if (directory == null && Build.VERSION.SDK_INT < 24) {
            File internalDir = new File(context.getDir(SCREENGRAB_DIR_NAME, Context.MODE_WORLD_READABLE), localeToDirName(locale));
            directory = initializeDirectory(internalDir);
        }

        if (directory == null) {
            throw new IOException("Unable to get a screenshot storage directory");
        }

        Log.d(TAG, "Using screenshot storage directory: " + directory.getAbsolutePath());
        return directory;
    }

    private static File initializeDirectory(File dir) {
        try {
            createPathTo(dir);

            if (dir.isDirectory() && dir.canWrite()) {
                return dir;
            }
        } catch (IOException e) {
            Log.e(TAG, "Failed to initialize directory: " + dir.getAbsolutePath(), e);
        }

        return null;
    }

    private static String getDirectoryName(Context context, Locale locale) {
        return context.getPackageName() + "/" + SCREENGRAB_DIR_NAME + "/" + localeToDirName(locale);
    }

    private static String localeToDirName(Locale locale) {
        StringBuilder sb = new StringBuilder(locale.getLanguage());
        String localeCountry = locale.getCountry();

        if (localeCountry != null && localeCountry.length() != 0) {
            sb.append("-").append(localeCountry);
        }

        return sb.append("/images/screenshots").toString();
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

    private static boolean shouldAppendTimestamp() {
        return Boolean.parseBoolean(InstrumentationRegistry.getArguments().getString(APPEND_TIMESTAMP_CONFIG_KEY));
    }
}
