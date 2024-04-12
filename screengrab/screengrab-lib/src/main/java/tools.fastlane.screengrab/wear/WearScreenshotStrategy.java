package tools.fastlane.screengrab.wear;

import android.app.UiAutomation;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.os.Build;

import androidx.annotation.RequiresApi;
import androidx.test.platform.app.InstrumentationRegistry;

import tools.fastlane.screengrab.ScreenshotCallback;
import tools.fastlane.screengrab.ScreenshotStrategy;

/**
 * <p>Screenshot strategy that delegates to UiAutomation for screenshot capture.</p>
 *
 * <p>
 * It takes into account the Wear Screenshot policies which require removing the
 * device frame and any avoiding transparent pixels.
 * <p>
 * https://support.google.com/googleplay/android-developer/answer/9866151#zippy=%2Cscreenshots
 * </p>
 */
@RequiresApi(api = Build.VERSION_CODES.O)
public class WearScreenshotStrategy implements ScreenshotStrategy {
    private final boolean screenRound;

    public WearScreenshotStrategy(Context context) {
        this(context.getResources().getConfiguration().isScreenRound());
    }

    public WearScreenshotStrategy(boolean screenRound) {
        this.screenRound = screenRound;
    }

    @Override
    public void takeScreenshot(String screenshotName, ScreenshotCallback screenshotCallback) {
        UiAutomation uiAutomation = InstrumentationRegistry.getInstrumentation().getUiAutomation();

        Bitmap screenshot = uiAutomation.takeScreenshot();

        if (screenRound) {
            screenshot = circularClip(screenshot);
        }

        screenshotCallback.screenshotCaptured(screenshotName, screenshot);
    }

    public Bitmap circularClip(Bitmap image) {
        // Derived from https://github.com/coil-kt/coil/blob/2.0.0-rc01/coil-base/src/main/java/coil/transform/CircleCropTransformation.kt
        // Copyright 2021 Coil Contributors
        // Licensed under the Apache License, Version 2.0 (the "License");

        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);

        int minSize = Math.min(image.getWidth(), image.getWidth());
        Bitmap output = Bitmap.createBitmap(image.getWidth(), image.getHeight(), Bitmap.Config.ARGB_8888);

        Canvas c = new Canvas(output);
        float radius = minSize / 2.0f;
        c.drawCircle(radius, radius, radius, paint);
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        c.drawBitmap(image, radius - image.getWidth() / 2f, radius - image.getHeight() / 2f, paint);
        c.drawColor(Color.WHITE, PorterDuff.Mode.DST_OVER);

        return output;
    }
}
