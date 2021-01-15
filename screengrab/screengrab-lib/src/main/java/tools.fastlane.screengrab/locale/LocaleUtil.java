
package tools.fastlane.screengrab.locale;

import android.annotation.SuppressLint;
import android.content.res.Configuration;
import android.os.Build;
import android.os.LocaleList;
import android.util.Log;

import androidx.test.platform.app.InstrumentationRegistry;

import java.lang.reflect.Method;
import java.util.Locale;

public final class LocaleUtil {

    private static final String TAG =  LocaleUtil.class.getSimpleName();

    @SuppressWarnings("JavaReflectionMemberAccess")
    @SuppressLint("PrivateApi")
    public static LocaleListCompat changeDeviceLocaleTo(LocaleListCompat locale) {
        if (locale == null) {
            Log.w(TAG, "Skipping setting device locale to null");
            return null;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
            LocaleList.setDefault(locale.getLocaleList());
        else
            Locale.setDefault(locale.getLocale());

        try {
            Class<?> amnClass = Class.forName("android.app.ActivityManagerNative");

            Method methodGetDefault = amnClass.getMethod("getDefault");
            methodGetDefault.setAccessible(true);
            Object activityManagerNative = methodGetDefault.invoke(amnClass);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // getConfiguration moved from ActivityManagerNative to ActivityManagerProxy
                amnClass = Class.forName(activityManagerNative.getClass().getName());
            }

            Method methodGetConfiguration = amnClass.getMethod("getConfiguration");
            methodGetConfiguration.setAccessible(true);
            Configuration config = (Configuration) methodGetConfiguration.invoke(activityManagerNative);

            config.getClass().getField("userSetLocale").setBoolean(config, true);
            LocaleListCompat ret;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                ret = new LocaleListCompat(config.getLocales());
            } else {
                ret = new LocaleListCompat(config.locale);
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
                config.setLocales(locale.getLocaleList());
            else
                config.locale = locale.getLocale();

            config.setLayoutDirection(locale.getPreferredLocale());

            Method updateConfigurationMethod = amnClass.getMethod("updateConfiguration", Configuration.class);
            updateConfigurationMethod.setAccessible(true);
            updateConfigurationMethod.invoke(activityManagerNative, config);

            Log.d(TAG, "Locale changed to " + locale);
            return ret;
        } catch (Exception e) {
            Log.e(TAG, "Failed to change device locale to " + locale, e);
            // ignore the error, it happens for example if run from Android Studio rather than Fastlane
            return null;
        }
    }

    @Deprecated
    public static void changeDeviceLocaleTo(Locale locale) {
        changeDeviceLocaleTo(new LocaleListCompat(locale));
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
