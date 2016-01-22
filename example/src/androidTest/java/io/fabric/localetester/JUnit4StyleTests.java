package io.fabric.localetester;

import android.support.test.rule.ActivityTestRule;

import org.junit.After;
import org.junit.Before;
import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.locale.LocaleTestRule;
import tools.fastlane.screengrab.screen.ScreenUtil;

import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.matcher.ViewMatchers.withId;

@RunWith(JUnit4.class)
public class JUnit4StyleTests {

    @ClassRule
    public static final LocaleTestRule localeTestRule = new LocaleTestRule();

    @Rule
    public ActivityTestRule<MainActivity> activityRule = new ActivityTestRule<>(MainActivity.class);

    private MainActivity activity;

    @Before
    public void setUp() {
        activity = activityRule.getActivity();
        ScreenUtil.activateScreenForTesting(activity);
    }

    @After
    public void tearDown() {
        activity = null;
    }

    @Test
    public void testTakeScreenshot() {
        Screengrab.screenshot(activity, "screenshot1");

        onView(withId(R.id.fab)).perform(click());

        Screengrab.screenshot(activity, "screenshot2");
    }

    @Test
    public void testTakeMoreScreenshots() {
        Screengrab.screenshot(activity, "screenshot3");

        onView(withId(R.id.fab)).perform(click());

        Screengrab.screenshot(activity, "screenshot4");
    }
}
