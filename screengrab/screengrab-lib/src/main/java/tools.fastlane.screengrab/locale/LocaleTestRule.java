package tools.fastlane.screengrab.locale;

import org.junit.rules.TestRule;
import org.junit.runner.Description;
import org.junit.runners.model.Statement;

import java.util.Locale;

import tools.fastlane.screengrab.Screengrab;

public class LocaleTestRule implements TestRule {

    private final Locale testLocale;
    private final String testLocaleString;

    public LocaleTestRule() {
        this(LocaleUtil.getTestLocale());
    }

    public LocaleTestRule(String testLocale) {
        this.testLocale = LocaleUtil.localeFromString(testLocale);
        this.testLocaleString = testLocale;
    }

    @Deprecated
    public LocaleTestRule(Locale testLocale) {
        StringBuilder sb = new StringBuilder(testLocale.getLanguage());
        String localeCountry = testLocale.getCountry();

        if (localeCountry.length() != 0) {
            sb.append("-").append(localeCountry);
        }
        this.testLocaleString = sb.toString();
        this.testLocale = testLocale;
    }

    @Override
    public Statement apply(final Statement base, Description description) {
        return new Statement() {
            @Override
            public void evaluate() throws Throwable {
                LocaleListCompat original = null;
                try {
                    if (testLocale != null) {
                        original = LocaleUtil.changeDeviceLocaleTo(new LocaleListCompat(testLocale));
                        Screengrab.setLocale(testLocaleString);
                    }
                    base.evaluate();
                } finally {
                    if (original != null) {
                        LocaleUtil.changeDeviceLocaleTo(original);
                    }
                }
            }
        };
    }
}
