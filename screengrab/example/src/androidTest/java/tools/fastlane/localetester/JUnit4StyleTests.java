package tools.fastlane.localetester;

import android.support.test.rule.ActivityTestRule;

import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.locale.LocaleTestRule;

import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.assertion.ViewAssertions.matches;
import static android.support.test.espresso.matcher.ViewMatchers.isDisplayed;
import static android.support.test.espresso.matcher.ViewMatchers.withId;

@RunWith(JUnit4.class)
public class JUnit4StyleTests {
    @ClassRule
    public static final LocaleTestRule localeTestRule = new LocaleTestRule();

    @Rule
    public ActivityTestRule<MainActivity> activityRule = new ActivityTestRule<>(MainActivity.class);

    @Test
    public void testTakeScreenshot() {
        Screengrab.screenshot("beforeFabClick");

        onView(withId(tools.fastlane.localetester.R.id.fab)).perform(click());

        Screengrab.screenshot("afterFabClick");
    }

    @Test
    public void testTakeMoreScreenshots() {
        Screengrab.screenshot("mainActivity");

        onView(withId(tools.fastlane.localetester.R.id.nav_button)).perform(click());

        Screengrab.screenshot("anotherActivity");

        onView(withId(R.id.hello)).check(matches(isDisplayed()));
    }
}
