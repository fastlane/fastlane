package tools.fastlane.screengrab.locale;

import android.content.res.Configuration;
import android.os.Build;
import android.support.test.InstrumentationRegistry;
import android.util.Log;

import java.lang.reflect.Method;
import java.util.Locale;

public class LocaleUtil {

    private static final String TAG =  LocaleUtil.class.getSimpleName();

    public static void changeDeviceLocaleTo(Locale locale) {
        if (locale == null) {
            Log.w(TAG, "Skipping setting device locale to null");
            return;
        }

        try {
            Class amnClass = Class.forName("android.app.ActivityManagerNative");

            Method methodGetDefault = amnClass.getMethod("getDefault");
            methodGetDefault.setAccessible(true);
            Object activityManagerNative = methodGetDefault.invoke(amnClass);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // getConfiguration moved from ActivityManagerNative to ActivityManagerProxy
                amnClass = Class.forName(activityManagerNative.getClass().getName());
            }

            Method methodGetConfiguration = amnClass.getMethod("getConfiguration");
            methodGetConfiguration.setAccessible(true);
            Configuration config  = (Configuration) methodGetConfiguration.invoke(activityManagerNative);

            config.getClass().getField("userSetLocale").setBoolean(config, true);
            config.locale = locale;

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                config.setLayoutDirection(locale);
            }

            Method updateConfigurationMethod = amnClass.getMethod("updateConfiguration", Configuration.class);
            updateConfigurationMethod.setAccessible(true);
            updateConfigurationMethod.invoke(activityManagerNative, config);

            Log.d(TAG, "Locale changed to " + locale);
        } catch (Exception e) {
            Log.e(TAG, "Failed to change device locale to " + locale, e);
            throw new RuntimeException(e);
        }
    }

    public static String[] localePartsFrom(String localeString) {
        if (localeString == null) {
            return null;
        }

        String[] localeParts = localeString.split("_");

        if (localeParts.length < 1 || localeParts.length > 3) {
            return null;
        }

        return localeParts;
    }

    public static Locale localeFromParts(String[] localeParts) {
        if (localeParts == null || localeParts.length == 0) {
            return null;
        } else if (localeParts.length == 1) {
            return new Locale(localeParts[0]);
        } else if (localeParts.length == 2) {
            return new Locale(localeParts[0], localeParts[1]);
        } else {
            return new Locale(localeParts[0], localeParts[1], localeParts[2]);
        }
    }

    public static Locale getTestLocale() {
        return localeFromInstrumentation("testLocale");
    }

    public static Locale getEndingLocale() {
        return localeFromInstrumentation("endingLocale");
    }

    private static Locale localeFromInstrumentation(String key) {
        String localeString = InstrumentationRegistry.getArguments().getString(key);
        return LocaleUtil.localeFromParts(LocaleUtil.localePartsFrom(localeString));
    }

    private LocaleUtil() {}
}
