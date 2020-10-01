// Copied from Chmod.java in square/spoon
// https://github.com/square/spoon/blob/3dc3401f6857916ed57f132c90563266d6011708/spoon-client/src/main/java/com/squareup/spoon/Chmod.java

/*
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
// Copyright 2013 Square, Inc.

package tools.fastlane.screengrab.file;

import android.annotation.TargetApi;
import android.os.Build;

import java.io.File;
import java.io.IOException;

public abstract class Chmod {
    private static final Chmod INSTANCE;

    static {
        INSTANCE = new Java6Chmod();
    }

    public static void chmodPlusR(File file) {
        INSTANCE.plusR(file);
    }

    public static void chmodPlusRWX(File file) {
        INSTANCE.plusRWX(file);
    }

    protected abstract void plusR(File file);

    protected abstract void plusRWX(File file);

    private static class Java5Chmod extends Chmod {
        @Override
        protected void plusR(File file) {
            try {
                Runtime.getRuntime().exec(new String[]{"chmod", "644", file.getAbsolutePath()});
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        @Override
        protected void plusRWX(File file) {
            try {
                Runtime.getRuntime().exec(new String[]{"chmod", "777", file.getAbsolutePath()});
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private static class Java6Chmod extends Chmod {
        @Override
        @TargetApi(Build.VERSION_CODES.GINGERBREAD)
        protected void plusR(File file) {
            file.setReadable(true, false);
        }

        @Override
        @TargetApi(Build.VERSION_CODES.GINGERBREAD)
        protected void plusRWX(File file) {
            file.setReadable(true, false);
            file.setWritable(true, false);
            file.setExecutable(true, false);
        }
    }
}
