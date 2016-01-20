package io.fabric.localetester;

import android.test.ActivityInstrumentationTestCase2;

import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.locale.LocaleUtil;
import tools.fastlane.screengrab.screen.ScreenUtil;

import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.matcher.ViewMatchers.withId;

public class JUnit3StyleTests extends ActivityInstrumentationTestCase2<MainActivity> {

    private MainActivity activity;

    public JUnit3StyleTests() {
        super(MainActivity.class);
    }

    public void setUp() {
        LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getTestLocale());
        activity = getActivity();
        ScreenUtil.activateScreenForTesting(activity);
    }

    public void tearDown() {
        activity = null;
        LocaleUtil.changeDeviceLocaleTo(LocaleUtil.getEndingLocale());
    }

    public void testTakeScreenshot() {
        Screengrab.screenshot(activity, "screenshot1");

        onView(withId(R.id.fab)).perform(click());

        Screengrab.screenshot(activity, "screenshot2");
    }

    public void testTakeMoreScreenshots() {
        Screengrab.screenshot(activity, "screenshot3");

        onView(withId(R.id.fab)).perform(click());

        Screengrab.screenshot(activity, "screenshot4");
    }
}

