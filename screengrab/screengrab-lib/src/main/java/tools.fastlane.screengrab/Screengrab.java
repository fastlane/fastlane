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

import java.util.regex.Pattern;

public class Screengrab {
    private static final Pattern TAG_PATTERN = Pattern.compile("[a-zA-Z0-9_-]+");

    private static ScreenshotStrategy defaultScreenshotStrategy = new DecorViewScreenshotStrategy();

    public static ScreenshotStrategy getDefaultScreenshotStrategy() {
        return defaultScreenshotStrategy;
    }

    public static void setDefaultScreenshotStrategy(ScreenshotStrategy strategy) {
        defaultScreenshotStrategy = strategy;
    }

    public static void screenshot(String screenshotName) {
        screenshot(defaultScreenshotStrategy, screenshotName);
    }

    public static void screenshot(ScreenshotStrategy strategy, String screenshotName) {
        if (!TAG_PATTERN.matcher(screenshotName).matches()) {
            throw new IllegalArgumentException("Tag may only contain the letters a-z, A-Z, the " +
                    "numbers 0-9, underscores, and hyphens");
        }

        final Context appContext = InstrumentationRegistry.getInstrumentation()
                .getTargetContext()
                .getApplicationContext();

        strategy.takeScreenshot(new FileWritingScreenshotCallback(appContext, screenshotName));
    }

    private Screengrab() {
    }
}
