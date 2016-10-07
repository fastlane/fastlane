// Derived from Spoon.java in square/spoon
// https://github.com/square/spoon/blob/94584b46f6152e7033c2e3fe9997c8491d6fedd1/spoon-client/src/main/java/com/squareup/spoon/Spoon.java
/*
   Copyright 2013 Square, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

// This file contains significant modifications from the original work
// Modifications Copyright 2015, Twitter Inc

package tools.fastlane.screengrab;

import android.content.Context;
import android.support.test.InstrumentationRegistry;

import java.util.HashMap;
import java.util.regex.Pattern;

public class Screengrab {
    private static final Pattern TAG_PATTERN = Pattern.compile("[a-zA-Z0-9_-]+");

    private static ScreenshotStrategy defaultScreenshotStrategy = new DecorViewScreenshotStrategy();

    /**
     * @return The default {@link ScreenshotStrategy} used in {@link #screenshot(String)} invocations
     */
    public static ScreenshotStrategy getDefaultScreenshotStrategy() {
        return defaultScreenshotStrategy;
    }

    /**
     * Set a {@link ScreenshotStrategy} to be used by default for subsequent {@link #screenshot(String)}
     * invocations
     *
     * @param strategy ScreenshotStrategy to use as the default
     */
    public static void setDefaultScreenshotStrategy(ScreenshotStrategy strategy) {
        defaultScreenshotStrategy = strategy;
    }

    /**
     * Capture a screenshot with the provided name using the default {@link ScreenshotStrategy}
     *
     * @param screenshotName a descriptive name for the screenshot to help you identify its context.
     *                       It may only contain the letters a-z, A-Z, the numbers 0-9, underscores,
     *                       and hyphens
     */
    public static void screenshot(String screenshotName) {
        screenshot(screenshotName, defaultScreenshotStrategy);
    }

    /**
     * @param screenshotName a descriptive name for the screenshot to help you identify its context.
     *                       It may only contain the letters a-z, A-Z, the numbers 0-9, underscores,
     *                       and hyphens
     * @param strategy The {@link ScreenshotStrategy} to use to capture this screenshot. Overrides
     *                 the default ScreenshotStrategy for this invocation
     * @see #setDefaultScreenshotStrategy(ScreenshotStrategy)
     */
    public static void screenshot(String screenshotName, ScreenshotStrategy strategy) {
        Context appContext = InstrumentationRegistry.getInstrumentation()
                .getTargetContext()
                .getApplicationContext();

        screenshot(screenshotName, strategy, new FileWritingScreenshotCallback(appContext));
    }

    /**
     * @param screenshotName a descriptive name for the screenshot to help you identify its context.
     *                       It may only contain the letters a-z, A-Z, the numbers 0-9, underscores,
     *                       and hyphens
     * @param strategy The {@link ScreenshotStrategy} to use to capture this screenshot. Overrides
     *                 the default ScreenshotStrategy for this invocation
     * @param callback The {@link ScreenshotCallback} to use to handle the captured screenshot
     * @see #setDefaultScreenshotStrategy(ScreenshotStrategy)
     */
    public static void screenshot(String screenshotName, ScreenshotStrategy strategy, ScreenshotCallback callback) {
        if (!TAG_PATTERN.matcher(screenshotName).matches()) {
            throw new IllegalArgumentException("screenshotName may only contain the letters a-z, " +
                    " A-Z, the numbers 0-9, underscores, and hyphens");
        }

        strategy.takeScreenshot(screenshotName, callback);
    }

    private Screengrab() {
    }
}
