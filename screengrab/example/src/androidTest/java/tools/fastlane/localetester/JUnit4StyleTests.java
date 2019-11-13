package tools.fastlane.localetester;

import androidx.test.rule.ActivityTestRule;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import tools.fastlane.screengrab.Screengrab;
import tools.fastlane.screengrab.UiAutomatorScreenshotStrategy;
import tools.fastlane.screengrab.cleanstatusbar.BluetoothState;
import tools.fastlane.screengrab.cleanstatusbar.CleanStatusBar;
import tools.fastlane.screengrab.cleanstatusbar.MobileDataType;
import tools.fastlane.screengrab.locale.LocaleTestRule;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withText;

@RunWith(JUnit4.class)
public class JUnit4StyleTests {
    @ClassRule
    public static final LocaleTestRule localeTestRule = new LocaleTestRule();

    @Rule
    public ActivityTestRule<MainActivity> activityRule = new ActivityTestRule<>(MainActivity.class);

    @BeforeClass
    public static void beforeAll() {
        Screengrab.setDefaultScreenshotStrategy(new UiAutomatorScreenshotStrategy());

        new CleanStatusBar()
                .setMobileNetworkDataType(MobileDataType.THREEG)
                .setBluetoothState(BluetoothState.DISCONNECTED)
                .enable();
    }

    @AfterClass
    public static void afterAll() {
        CleanStatusBar.disable();
    }

    @Test
    public void testTakeScreenshot() {
        onView(withId(R.id.greeting)).check(matches(isDisplayed()));

        Screengrab.screenshot("beforeFabClick");

        onView(withId(R.id.fab)).perform(click());

        Screengrab.screenshot("afterFabClick");
    }

    @Test
    public void testTakeMoreScreenshots() {
        onView(withId(R.id.nav_button)).perform(click());

        Screengrab.screenshot("anotherActivity");

        onView(withId(R.id.show_dialog_button)).perform(click());

        Screengrab.screenshot("anotherActivity-dialog");

        onView(withText(android.R.string.ok)).perform(click());
    }
}
