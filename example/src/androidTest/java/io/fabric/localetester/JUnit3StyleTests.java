package io.fabric.localetester;

import android.test.ActivityInstrumentationTestCase2;

import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.locale.LocaleUtil;
import tools.fastlane.screengrab.screen.ScreenUtil;

import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.matcher.ViewMatchers.withId;

public class JUnit3StyleTests extends ActivityInstrumentationTestCase2<MainActivity> {

    public JUnit3StyleTests() {
        super(MainActivity.class);
    }

    public void setUp() {
        LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getTestLocale());
        ScreenUtil.activateScreenForTesting(getActivity());
    }

    public void tearDown() {
        LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getEndingLocale());
    }

    public void testTakeScreenshot() {
        Screengrab.screenshot("beforeFabClick");

        onView(withId(R.id.fab)).perform(click());

        Screengrab.screenshot("afterFabClick");
    }

    public void testTakeMoreScreenshots() {
        Screengrab.screenshot("mainActivity");

        onView(withId(R.id.nav_button)).perform(click());

        Screengrab.screenshot("anotherActivity");
    }
}

