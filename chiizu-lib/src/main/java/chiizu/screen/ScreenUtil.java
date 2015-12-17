package chiizu.screen;

import android.app.Activity;
import android.support.test.InstrumentationRegistry;
import android.view.WindowManager;

public class ScreenUtil {

    public static void activateScreenForTesting(final Activity activity) {
        InstrumentationRegistry.getInstrumentation().runOnMainSync(new Runnable() {
            @Override
            public void run() {
                activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                        | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                        | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);
            }
        });
    }

    private ScreenUtil() {}
}
