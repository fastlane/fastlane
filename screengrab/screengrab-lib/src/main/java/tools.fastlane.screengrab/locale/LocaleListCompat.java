package tools.fastlane.screengrab.locale;

import android.os.Build;
import android.os.LocaleList;

import androidx.annotation.RequiresApi;

import java.util.Locale;

class LocaleListCompat {
    private Locale mLocale = null;
    private LocaleList mLocaleList = null;

    LocaleListCompat(Locale locale) {
        mLocale = locale;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
            mLocaleList = new LocaleList(locale);
    }

    @RequiresApi(Build.VERSION_CODES.N)
    LocaleListCompat(LocaleList localeList) {
        mLocaleList = localeList;
    }

    Locale getLocale() {
        return mLocale;
    }

    @RequiresApi(Build.VERSION_CODES.N)
    LocaleList getLocaleList() {
        return mLocaleList;
    }

    Locale getPreferredLocale() {
        if (mLocaleList != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return mLocaleList.get(0);
        } else {
            return mLocale;
        }
    }
}
