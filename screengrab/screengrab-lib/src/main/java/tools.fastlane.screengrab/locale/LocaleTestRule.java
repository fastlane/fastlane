package tools.fastlane.screengrab.locale;

import org.junit.rules.TestRule;
import org.junit.runner.Description;
import org.junit.runners.model.Statement;

import java.util.Locale;

public class LocaleTestRule implements TestRule {

    private final Locale testLocale;

    public LocaleTestRule() {
        this(LocaleUtil.getTestLocale());
    }

    @SuppressWarnings({"unused", "RedundantSuppression"})
    public LocaleTestRule(Locale testLocale, @Deprecated Locale endingLocale) {
        this(testLocale);
    }

    public LocaleTestRule(Locale testLocale) {
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
