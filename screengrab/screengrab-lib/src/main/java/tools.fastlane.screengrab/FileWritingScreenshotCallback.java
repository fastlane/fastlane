package tools.fastlane.screengrab;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Environment;
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

    private static final String NAME_SEPARATOR = "_";
    private static final String EXTENSION = ".png";
    private static final int FULL_QUALITY = 100;
    private static final String SCREENGRAB_DIR_NAME = "screengrab";

    private final Context appContext;

    public FileWritingScreenshotCallback(Context appContext) {
        this.appContext = appContext;
    }

    @Override
    public void screenshotCaptured(String screenshotName, Bitmap screenshot) {
        try {
            File screenshotDirectory = getFilesDirectory(appContext, Locale.getDefault());
            String screenshotFileName = screenshotName + NAME_SEPARATOR + System.currentTimeMillis() + EXTENSION;
            File screenshotFile = new File(screenshotDirectory, screenshotFileName);

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

            Log.d(TAG, "Captured screenshot \"" + screenshotFileName + "\"");
        } catch (Exception e) {
            throw new RuntimeException("Unable to capture screenshot.", e);
        }
    }

    private static File getFilesDirectory(Context context, Locale locale) throws IOException {
        File directory = null;

        if (Build.VERSION.SDK_INT >= 21) {
            File externalDir = new File(Environment.getExternalStorageDirectory(), getDirectoryName(context, locale));
            directory = initializeDirectory(externalDir);
        }

        if (directory == null) {
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
        } catch (IOException ignored) {}

        return null;
    }

    private static String getDirectoryName(Context context, Locale locale) {
        return context.getPackageName() + "/" + SCREENGRAB_DIR_NAME + "/" + localeToDirName(locale);
    }

    private static String localeToDirName(Locale locale) {
        return locale.getLanguage() + "-" + locale.getCountry() + "/images/screenshots";
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
}
