package tools.fastlane.localetester;

import android.test.ActivityInstrumentationTestCase2;

import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.locale.LocaleUtil;

import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.assertion.ViewAssertions.matches;
import static android.support.test.espresso.matcher.ViewMatchers.isDisplayed;
import static android.support.test.espresso.matcher.ViewMatchers.withId;

public class JUnit3StyleTests extends ActivityInstrumentationTestCase2<MainActivity> {

    public JUnit3StyleTests() {
        super(MainActivity.class);
    }

    public void setUp() {
        getActivity();
        LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getTestLocale());
    }

    public void tearDown() {
        LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getEndingLocale());
    }

    public void testTakeScreenshot() {
        Screengrab.screenshot("beforeFabClick");

        onView(withId(tools.fastlane.localetester.R.id.fab)).perform(click());

        Screengrab.screenshot("afterFabClick");
    }

    public void testTakeMoreScreenshots() {
        Screengrab.screenshot("mainActivity");

        onView(withId(tools.fastlane.localetester.R.id.nav_button)).perform(click());

        Screengrab.screenshot("anotherActivity");

        onView(withId(R.id.hello)).check(matches(isDisplayed()));
    }
}

