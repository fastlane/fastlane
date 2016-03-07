package tools.fastlane.screengrab.locale;

import org.junit.rules.TestRule;
import org.junit.runner.Description;
import org.junit.runners.model.Statement;

import java.util.Locale;

public class LocaleTestRule implements TestRule {

    private final Locale testLocale;
    private final Locale endingLocale;

    public LocaleTestRule() {
        this(LocaleUtil.getTestLocale(), LocaleUtil.getEndingLocale());
    }

    public LocaleTestRule(Locale testLocale, Locale endingLocale) {
        this.testLocale = testLocale;
        this.endingLocale = endingLocale;
    }

    @Override
    public Statement apply(final Statement base, Description description) {
        return new Statement() {
            @Override
            public void evaluate() throws Throwable {
                try {
                    if (testLocale != null) {
                        LocaleUtil.changeDeviceLocaleTo(testLocale);
                    }
                    base.evaluate();
                } finally {
                    if (endingLocale != null) {
                        LocaleUtil.changeDeviceLocaleTo(endingLocale);
                    }
                }
            }
        };
    }
}
