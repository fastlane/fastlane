package io.fabric.localetester;

import android.test.ActivityInstrumentationTestCase2;

import chiizu.lens.Lens;
import chiizu.locale.LocaleUtil;
import chiizu.screen.ScreenUtil;

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
        Lens.screenshot(activity, "screenshot1");

        onView(withId(R.id.fab)).perform(click());

        Lens.screenshot(activity, "screenshot2");
    }

    public void testTakeMoreScreenshots() {
        Lens.screenshot(activity, "screenshot3");

        onView(withId(R.id.fab)).perform(click());

        Lens.screenshot(activity, "screenshot4");
    }
}

