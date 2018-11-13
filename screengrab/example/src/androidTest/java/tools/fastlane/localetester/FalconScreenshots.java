package tools.fastlane.localetester;

import android.support.test.rule.ActivityTestRule;

import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import tools.fastlane.screengrab.FalconScreenshotStrategy;
import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.locale.LocaleTestRule;

import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.assertion.ViewAssertions.matches;
import static android.support.test.espresso.matcher.ViewMatchers.isDisplayed;
import static android.support.test.espresso.matcher.ViewMatchers.withId;
import static android.support.test.espresso.matcher.ViewMatchers.withText;

@RunWith(JUnit4.class)
public class FalconScreenshots {

    @ClassRule
    public static final LocaleTestRule localeTestRule = new LocaleTestRule();

    @Rule
    public ActivityTestRule<MainActivity> activityRule = new ActivityTestRule<>(MainActivity.class, false, false);


    @Test
    public void testTakeScreenshot() {
        activityRule.launchActivity(null);
        Screengrab.setDefaultScreenshotStrategy(new FalconScreenshotStrategy(activityRule.getActivity()));

        onView(withId(R.id.greeting)).check(matches(isDisplayed()));

        Screengrab.screenshot("falcon_beforeFabClick");

        onView(withId(R.id.fab)).perform(click());

        Screengrab.screenshot("falcon_afterFabClick");
    }

    @Test
    public void testTakeMoreScreenshots() {
        activityRule.launchActivity(null);
        Screengrab.setDefaultScreenshotStrategy(new FalconScreenshotStrategy(activityRule.getActivity()));

        onView(withId(R.id.nav_button)).perform(click());

        Screengrab.screenshot("falcon_anotherActivity");

        onView(withId(R.id.show_dialog_button)).perform(click());

        Screengrab.screenshot("falcon_anotherActivity-dialog");

        onView(withText(android.R.string.ok)).perform(click());
    }
}
