// Copied from Chmod.java in square/spoon
// Copyright 2013 Square, Inc.

package tools.fastlane.screengrab.file;

import android.os.Build;

import java.io.File;
import java.io.IOException;

public abstract class Chmod {
    private static final Chmod INSTANCE;

    static {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.GINGERBREAD) {
            INSTANCE = new Java6Chmod();
        } else {
            INSTANCE = new Java5Chmod();
        }
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
        protected void plusR(File file) {
            file.setReadable(true, false);
        }

        @Override
        protected void plusRWX(File file) {
            file.setReadable(true, false);
            file.setWritable(true, false);
            file.setExecutable(true, false);
        }
    }
}
